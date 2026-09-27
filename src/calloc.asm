OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

PUBLIC CALLOC
CALLOC PROC USES rbx rdi rsi count:qword, elem_size:qword
    ; rdi = count, rsi = elem_size
    mov     rax, count
    mov     rbx, elem_size
    mul     rbx                 ; rax = count * elem_size, RDX = overflow
    test    rdx, rdx
    jnz     alloc_overflow      ; return 0 if integer wrapped

    ; Allocate from arena
    mov     rdi, rax
    mov     rsi, offset arena
    call    arena_alloc
    test    rax, rax
    jz      alloc_done

    ; Optional: Zero-fill the array (like calloc)
    ; rdi = rax, rcx = total_bytes, al = 0, rep stosb

alloc_done:
    ret

alloc_overflow:
    xor     rax, rax
    ret
CALLOC ENDP

END