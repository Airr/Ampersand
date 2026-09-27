OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

SYS_MKDIR       equ 83
PATH_MAX        equ 4096
EEXIST          equ 17
ENAMETOOLONG    equ 36

.code

;==============================================================================
; ENC$
;   Returns a new arena-allocated copy of a string enclosed in quotation
;   marks, or in an optional enclosing character.
;
; Parameters:
;   srcPtr  (rdi)  NUL-terminated source string. Must not be NULL.
;   encChar (esi)  Enclosing character (ASCII code). 0 = default '"'.
;
; Returns:
;   rax = pointer to the new NUL-terminated string (length + 2 characters),
;         or 0 if arena_alloc fails.
;==============================================================================
PUBLIC ENC$
ENC$ PROC USES rbx r12 r13 r14 srcPtr:ptr, encChar:dword

    mov     r12, srcPtr             ; r12 = source
    mov     r13d, encChar           ; r13b = enclosing char
    test    r13d, r13d
    jnz     have_char
    mov     r13d, '"'
have_char:

    xor     ebx, ebx                ; rbx = source length
len_loop:
    cmp     byte ptr [r12 + rbx], 0
    je      len_done
    inc     rbx
    jmp     len_loop
len_done:

    lea     rdi, [rbx + 3]          ; open + text + close + NUL
    lea     rsi, qword ptr [arena]
    call    arena_alloc
    test    rax, rax
    jz      done                    ; allocation failed, return 0

    mov     r14, rax                ; r14 = destination
    mov     [r14], r13b             ; opening character

    xor     ecx, ecx
copy_loop:
    cmp     rcx, rbx
    jae     copy_done
    mov     dl, [r12 + rcx]
    mov     [r14 + rcx + 1], dl
    inc     rcx
    jmp     copy_loop
copy_done:

    mov     [r14 + rbx + 1], r13b   ; closing character
    mov     byte ptr [r14 + rbx + 2], 0
    mov     rax, r14                ; return the new string
done:
    ret
ENC$ endp
END
