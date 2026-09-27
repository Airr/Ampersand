OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn LEN        :proto :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; Name:         TALLY
; Description:  Counts occurrences of a regular null-terminated string 'target' 
;               in a string 's', using external LEN.
; C Prototype:  int64_t TALLY(const char* s, const char* target);
; Parameters:   rdi = pointer to source string (s)
;               rsi = pointer to regular null-terminated C string (target)
; Returns:      rax = total count of occurrences
; -----------------------------------------------------------------------------
PUBLIC TALLY

TALLY PROC USES rbx r12 r13 r14 r15 srcString:ptr, matchStr:ptr
    local src_ptr:qword
    local tgt_ptr:qword
    local src_len:qword
    local tgt_len:qword
    local count_acc:qword
    local src_idx:qword

    mov       src_ptr, srcString
    mov       rbx, srcString                 ; rbx = source string s
    mov       tgt_ptr, matchStr              ; r12 = regular target string pointer
    mov       r12, matchStr

    ; Guard against null or empty pointers
    test      rbx, rbx
    jz        tally_zero
    test      r12, r12
    jz        tally_zero

    ; 1. Get length of source string using external LEN
    mov       rdi, rbx
    call      LEN
    mov       src_len, rax              ; r14 = len(s)
    mov       r14, rax

    ; 2. Get length of regular target string using external LEN
    mov       rdi, r12
    call      LEN
    mov       tgt_len, rax              ; r15 = len(target)
    mov       r15, rax

    ; If target is empty or longer than source, count is 0
    mov       rax, tgt_len
    test      rax, rax
    jz        tally_zero
    mov       rax, tgt_len
    cmp       rax, src_len
    jg        tally_zero

    xor       rax, rax                  ; rax = count accumulator
    mov       count_acc, rax
    mov       r13, rax
    xor       rcx, rcx                  ; rcx = current index i in source (s)
    mov       src_idx, rcx

tally_outer_loop:
    ; Check if remaining source bytes are enough to fit the target substring
    mov       rax, src_len
    mov       rcx, src_idx
    sub       rax, rcx
    mov       rdx, rax
    mov       rax, tgt_len
    cmp       rdx, rax
    jl        tally_exit

    ; Compare regular target string with source starting at [rbx + rcx]
    xor       r8, r8                    ; r8 = target index j = 0

tally_inner_loop:
    mov       rax, src_idx
    add       rax, r8
    mov       rdx, src_ptr
    mov       dl, byte ptr [rdx + rax]    ; Load source byte using single index register
    mov       rax, tgt_ptr
    mov       al, byte ptr [rax + r8]     ; Load target byte
    cmp       dl, al
    jne       tally_no_match

    inc       r8
    mov       rax, tgt_len
    cmp       r8, rax
    jl        tally_inner_loop

    ; Full match found! Increment accumulator
    jmp       tally_found_match

tally_no_match:
    mov       rax, src_idx
    inc       rax                       ; Advance index by 1 character
    mov       src_idx, rax
    mov       rcx, rax
    jmp       tally_outer_loop

tally_found_match:
    mov       rax, count_acc
    inc       rax                       ; Increment our dedicated count register (r13)
    mov       count_acc, rax
    mov       r13, rax

    mov       rax, src_idx
    mov       rdx, tgt_len
    add       rax, rdx                  ; Advance index past current match
    mov       src_idx, rax
    mov       rcx, rax
    jmp       tally_outer_loop

tally_zero:
    xor       rax, rax
    mov       count_acc, rax
    mov       r13, rax

tally_exit:
    mov       rax, count_acc            ; Move final count into rax for return value
    ret
TALLY ENDP

END