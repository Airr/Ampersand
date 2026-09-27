OPTION LITERALS:ON
option casemap:none
option frame:auto

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

PUBLIC puts
puts PROC text:ptr
    mov     rsi, text
    test    rsi, rsi
    jz      PUTS_done           ; Guard against NULL pointer

    ; Optimized inline length calculation using scasb
    mov     rdi, rsi            ; Copy string pointer from rsi to rdi (required by scasb)
    xor     al, al              ; Clear al register to 0 (the null-terminator byte we are searching for)
    or      rcx, -1             ; Initialize rcx to -1 (all bits set to 1) to act as a countdown register
    repnz   scasb               ; Scan memory at rdi byte-by-byte for al (0), decrementing rcx each step
    not     rcx                 ; Invert all bits of rcx to convert the negative countdown into a positive byte count
    sub     rcx, 1              ; Subtract 1 to exclude the null terminator from the final length count
    
    test    rcx, rcx            ; Test rcx against itself to update CPU flags (without changing its value)
    jle     PUTS_done           ; Jump to exit if the resulting length is less than or equal to zero
    
    mov     rdx, rcx            ; Length to rdx for syscall
    ; rsi already holds text buffer pointer
    mov     rdi, 1              ; File descriptor: 1 = stdout
    mov     rax, 1              ; 64-bit sys_write syscall number
    syscall                     ; Invoke Linux kernel 64-bit syscall

    PUTS_done:
        ret
puts endp

END