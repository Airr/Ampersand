OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

; =====================================================================
; Function: COMPARE
; Description: Compares two null-terminated strings lexicographically 
;              using unsigned byte values.
; Inputs:
;   rdi - Pointer to the first string (str1)
;   rsi - Pointer to the second string (str2)
; Returns:
;   rax - 0 if strings are identical, 
;         >0 if str1 is greater than str2, 
;         <0 if str1 is less than str2
; ABI: System V AMD64 (Linux)
; =====================================================================
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
