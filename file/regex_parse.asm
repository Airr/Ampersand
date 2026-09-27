OPTION LITERALS:ON
option casemap:none
option frame:auto

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

extrn malloc   :proc
extrn strncpy  :proc
extrn regcomp  :proc
extrn regexec  :proc
extrn regfree  :proc
extrn free      :proc
extern ALLOC    :proto :qword

REG_EXTENDED equ 1

.code

PUBLIC regex_parse

; -----------------------------------------------------------------------------
; regex_parse
;
; C-style interface:
;
;   int regex_parse(
;       const char *pattern,
;       const char *input,
;       char      **item1Out,
;       char      **item2Out,
;       char      **restOut
;   );
;
; SysV AMD64:
;
;   RDI = pattern
;   RSI = input
;   RDX = item1Out
;   RCX = item2Out
;   R8  = restOut
;
; Returns:
;
;   RAX = 0  success
;   RAX = 1  regex compile/match failure
;   RAX = 2  malloc failure
;
; Caller owns the returned strings and must free() them.
;
; NOTE ON FIX: rdx/rcx/rax/rsi/rdi/r8-r11 are all caller-saved (volatile)
; under the SysV AMD64 ABI, so a callee such as malloc() or strncpy() is
; free to clobber them. The original code computed each match's start
; offset into rdx, then called malloc(), then tried to reuse that same
; rdx to build the strncpy() source pointer -- by then rdx no longer held
; the offset, producing a wild pointer and a SIGSEGV. Each block below now
; reloads the start offset from matchArr (stack memory, untouched by the
; calls) immediately before it's needed for strncpy.
; -----------------------------------------------------------------------------

regex_parse proc USES rbx r12 r13 r14 r15

    local regexBuf[16]:qword
    local matchArr[5]:qword

    local item1Len:qword
    local item2Len:qword
    local restLen:qword

    local item1Ptr:qword
    local item2Ptr:qword
    local restPtr:qword

    ; Preserve arguments in nonvolatile registers.

    mov r12, rdi                    ; pattern
    mov r13, rsi                    ; input
    mov r14, rdx                    ; item1Out
    mov r15, rcx                    ; item2Out
    mov rbx, r8                     ; restOut

    ; Initialize output pointers.

    mov qword ptr [r14], 0
    mov qword ptr [r15], 0
    mov qword ptr [rbx], 0

    ; -------------------------------------------------------------------------
    ; Compile regex
    ; -------------------------------------------------------------------------

    lea rdi, regexBuf
    mov rsi, r12
    mov edx, REG_EXTENDED
    call regcomp

    test eax, eax
    jnz regex_fail

    ; -------------------------------------------------------------------------
    ; Execute regex
    ;
    ; We need groups:
    ;
    ;   0 = entire match
    ;   1 = SPRINT
    ;   2 = PROC
    ;   3 = repeated USES argument(s)
    ;   4 = rest
    ;
    ; Five regmatch_t entries are therefore required.
    ; -------------------------------------------------------------------------

    lea rdi, regexBuf
    mov rsi, r13
    mov edx, 5
    lea rcx, matchArr
    xor r8d, r8d
    call regexec

    test eax, eax
    jnz regex_match_fail

    ; -------------------------------------------------------------------------
    ; Group 1
    ; -------------------------------------------------------------------------

    lea rax, matchArr

    movsxd rdx, dword ptr [rax + 8]
    movsxd rcx, dword ptr [rax + 12]

    sub rcx, rdx
    mov item1Len, rcx

    ; malloc(length + 1)

    mov rdi, rcx
    inc rdi
    ; call malloc

    ; test rax, rax
    ; jz malloc_fail

    mov item1Ptr, ALLOC(rdi)

    ; Reload start offset -- rdx does not survive across call.

    lea rax, matchArr
    movsxd rdx, dword ptr [rax + 8]

    ; strncpy(destination, input + offset, length)

    mov rdi, item1Ptr
    mov rsi, r13
    add rsi, rdx
    mov rdx, item1Len
    call strncpy

    ; Null terminate.

    mov rax, item1Ptr
    mov rcx, item1Len
    mov byte ptr [rax + rcx], 0

    mov rax, item1Ptr
    mov [r14], rax

    ; -------------------------------------------------------------------------
    ; Group 2
    ; -------------------------------------------------------------------------

    lea rax, matchArr

    movsxd rdx, dword ptr [rax + 16]
    movsxd rcx, dword ptr [rax + 20]

    sub rcx, rdx
    mov item2Len, rcx

    mov rdi, rcx
    inc rdi
    call malloc

    test rax, rax
    jz malloc_fail

    mov item2Ptr, rax

    ; Reload start offset -- rdx does not survive across call.

    lea rax, matchArr
    movsxd rdx, dword ptr [rax + 16]

    mov rdi, item2Ptr
    mov rsi, r13
    add rsi, rdx
    mov rdx, item2Len
    call strncpy

    mov rax, item2Ptr
    mov rcx, item2Len
    mov byte ptr [rax + rcx], 0

    mov rax, item2Ptr
    mov [r15], rax

    ; -------------------------------------------------------------------------
    ; Group 4
    ; -------------------------------------------------------------------------

    lea rax, matchArr

    movsxd rdx, dword ptr [rax + 32]
    movsxd rcx, dword ptr [rax + 36]

    sub rcx, rdx
    mov restLen, rcx

    mov rdi, rcx
    inc rdi
    call malloc

    test rax, rax
    jz malloc_fail

    mov restPtr, rax

    ; Reload start offset -- rdx does not survive across call.

    lea rax, matchArr
    movsxd rdx, dword ptr [rax + 32]

    mov rdi, restPtr
    mov rsi, r13
    add rsi, rdx
    mov rdx, restLen
    call strncpy

    mov rax, restPtr
    mov rcx, restLen
    mov byte ptr [rax + rcx], 0

    mov rax, restPtr
    mov [rbx], rax

    ; -------------------------------------------------------------------------
    ; Cleanup
    ; -------------------------------------------------------------------------

    lea rdi, regexBuf
    call regfree

    xor eax, eax
    ret


regex_match_fail:

    lea rdi, regexBuf
    call regfree

regex_fail:

    mov eax, 1
    ret


malloc_fail:

    ; Free anything that was already allocated.

    mov rdi, item1Ptr
    test rdi, rdi
    jz @F
    call free
@@:

    mov rdi, item2Ptr
    test rdi, rdi
    jz @F
    call free
@@:

    mov rdi, restPtr
    test rdi, rdi
    jz @F
    call free
@@:

    mov qword ptr [r14], 0
    mov qword ptr [r15], 0
    mov qword ptr [rbx], 0

    lea rdi, regexBuf
    call regfree

    mov eax, 2
    ret

regex_parse endp

end