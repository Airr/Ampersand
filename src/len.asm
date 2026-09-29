OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;
;==============================================================================
; LEN
;   Calculates the length of a null-terminated string.
;
; Parameters:
;   text:ptr - Pointer to the null-terminated string whose length will be calculated.
;
; Returns:
;   rax = Number of characters in the string (excluding the null terminator),
;         or 0 if the input pointer is null.
;==============================================================================

PUBLIC LEN
LEN PROC USES rsi rdi rcx text:ptr
    mov     rdi, text
    .if rdi == 0                        ; NULL guard, same as LEN
        xor     eax, eax
        ret
    .endif
    mov     rax, rdi
    and     rax, -16                    ; start of the aligned block holding text
    pxor    xmm0, xmm0
    movdqa  xmm1, [rax]
    pcmpeqb xmm1, xmm0
    pmovmskb edx, xmm1                  ; bit i set = byte i of the block is NUL
    mov     ecx, edi
    and     ecx, 15                     ; offset of text inside the block
    shr     edx, cl                     ; drop bytes that come before text
    .if edx != 0
        bsf     eax, edx                ; first NUL, already relative to text
        ret
    .endif
    .while 1
        add     rax, 16                 ; next aligned block
        movdqa  xmm1, [rax]
        pcmpeqb xmm1, xmm0
        pmovmskb edx, xmm1
        .break .if edx != 0
    .endw
    bsf     edx, edx
    add     rax, rdx                    ; address of the NUL
    sub     rax, rdi                    ; minus start = length
    ret
LEN endp
end