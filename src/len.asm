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
    mov     rsi, text
    test    rsi, rsi
    jz      strlen_zero         ; Guard against NULL pointer

    mov     rdi, rsi            ; rdi required by scasb
    xor     al, al              ; Clear al to search for null terminator (0)
    or      rcx, -1             ; Initialize rcx to -1 (max countdown)
    repnz   scasb               ; Hardware-accelerated byte scan loop

    not     rcx                 ; Invert bits to convert countdown to positive count
    sub     rcx, 1              ; Subtract 1 to exclude the null terminator
    mov     rax, rcx            ; Return length in rax
    ret

    strlen_zero:
        xor     rax, rax        ; Return 0 for NULL inputs
    ret
LEN endp
end