OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

PUBLIC LEN
;==============================================================================
; LEN
;   Returns the length of a NUL-terminated string (like C strlen).
;
; Parameters:
;   text (rdi)  Pointer to a NUL-terminated string. NULL is accepted.
;
; Returns:
;   rax = string length in bytes (0 for NULL or an empty string).
;
; Notes:
;   - Preserves rsi, rdi, rcx (via USES). Safe to call without saving
;     registers around it. Clobbers only rax and flags.
;==============================================================================
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