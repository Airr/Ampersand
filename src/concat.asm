OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

.code

PUBLIC CONCAT$
CONCAT$ PROC USES rbx r12 r13 r14 r15 str1:ptr, str2:ptr
    mov     r14, str1            ; r14 = s1
    mov     r15, str2            ; r15 = s2

    ; len1 (rbx), treating NULL as length 0
    xor     rbx, rbx
    test    r14, r14
    jz      @cat_len1_done
    mov     rdi, r14
    xor     al, al
    or      rcx, -1
    repnz   scasb
    not     rcx
    dec     rcx
    mov     rbx, rcx
@cat_len1_done:

    ; len2 (r12), treating NULL as length 0
    xor     r12, r12
    test    r15, r15
    jz      @cat_len2_done
    mov     rdi, r15
    xor     al, al
    or      rcx, -1
    repnz   scasb
    not     rcx
    dec     rcx
    mov     r12, rcx
@cat_len2_done:

    lea     r13, [rbx + r12 + 1]   ; r13 = total size needed (incl. NUL)

    ; Allocate directly from the arena instead of throwaway mmap/strdup/munmap
    mov     rdi, r13
    lea     rsi, [arena]
    call    arena_alloc

    test    rax, rax
    jz      @cat_fail

    mov     r10, rax            ; r10 = arena destination buffer

    ; copy s1 (rbx bytes)
    test    rbx, rbx
    jz      @cat_skip1
    mov     rdi, r10
    mov     rsi, r14
    mov     rcx, rbx
    rep     movsb
@cat_skip1:

    ; copy s2 (r12 bytes) immediately after
    lea     rdi, [r10 + rbx]
    test    r12, r12
    jz      @cat_skip2
    mov     rsi, r15
    mov     rcx, r12
    rep     movsb
@cat_skip2:
    mov     byte ptr [rdi], 0   ; NUL-terminate

    mov     rax, r10            ; rax = arena-allocated result
    ret

@cat_fail:
    xor     rax, rax
    ret
CONCAT$ endp
end