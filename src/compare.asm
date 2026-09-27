OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;==============================================================================
; COMPARE
;   Compares two null-terminated strings lexicographically.
;
; Parameters:
;   str1:ptr - Pointer to the first string.
;   str2:ptr - Pointer to the second string.
;
; Returns:
;   rax = Result of the comparison:
;         0 if the strings are equal
;         Positive value if str1 is lexicographically greater than str2
;         Negative value if str1 is lexicographically less than str2
;==============================================================================

PUBLIC COMPARE 

COMPARE PROC str1:ptr, str2:ptr
    mov rdi, str1
    mov rsi, str2
    
    cmp_loop:
        movzx   rax, byte ptr [rdi]     ; Load byte from str1 and zero-extend (unsigned)
        movzx   rdx, byte ptr [rsi]     ; Load byte from str2 and zero-extend (unsigned)
        
        cmp     rax, rdx                ; Compare the two bytes
        jne     mismatch                
        
        test    rax, rax                ; Check if we hit the null terminator (0)
        jz      match                   
        
        inc     rdi
        inc     rsi
        jmp     cmp_loop

    mismatch:
        sub     rax, rdx                ; Returns positive (>0) or negative (<0) difference
        ret

    match:
        xor     rax, rax                ; Returns 0 for identical strings
        ret
COMPARE endp

end
