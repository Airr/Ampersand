; -----------------------------------------------------------------------------
; Name: PAUSE
; C Prototype: void PAUSE(void);
; Description: Pure JWASM x86_64 pause PROCedure using flat offset addressing 
;              for correct PIE linking compatibility under Linux.
; -----------------------------------------------------------------------------
OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.data
    pause_msg   db  10,"Press [ENTER] to continue . . . ", 0
    pause_msg_len equ $ - pause_msg - 1


.code

;
;==============================================================================
; EPAUSE
;   Pauses the execution of a program until the user presses the Enter key.
;
; Parameters:
;   None
;
; Returns:
;   None
;
; Notes:
;   This procedure temporarily modifies the terminal settings to enable raw mode,
;   allowing character-by-character input without echoing. It then reads characters
;   from standard input until it encounters an Enter key press ('\n' or '\r'), at which
;   point it restores the original terminal settings and prints a clean trailing newline.
;
;   The procedure does not return any value as it is intended to be used for pausing
;   the program temporarily without affecting its execution flow.
;
;==============================================================================

PUBLIC EPAUSE
EPAUSE PROC USES rbx r12 r13 r14 r15
    local orig_term[64]:byte
    local new_term[64]:byte
    local key_buf:byte
    local newline_byte:byte

    ; 1. Get current terminal settings (TCGETS = 0x5401)
    mov     rax, 16                 ; sys_ioctl
    mov     rdi, 0                  ; stdin
    mov     rsi, 05401h             ; TCGETS
    lea     rdx, orig_term
    syscall

    ; 2. Copy settings to new_term and modify for raw mode
    lea     rsi, orig_term
    lea     rdi, new_term
    mov     rcx, 64
    rep     movsb                   ; Copy orig to new

    ; Modify c_lflag (offset 12): clear ICANON (0x10) and ECHO (0x8)
    ; Mask: ~(0x10 | 0x8) = ~0x18 = 0xE7
    lea     rax, new_term
    and     byte ptr [rax + 12], 0E7h

    ; 3. Set new terminal settings (TCSETS = 0x5402)
    mov     rax, 16                 ; sys_ioctl
    mov     rdi, 0                  ; stdin
    mov     rsi, 05402h             ; TCSETS
    lea     rdx, new_term
    syscall

    ; 4. Print prompt message
    mov     rax, 1                  ; sys_write
    mov     rdi, 1                  ; stdout
    lea     rsi, pause_msg
    mov     rdx, pause_msg_len
    syscall

    ; 5. Read loop capturing bytes until ENTER ('\n' or '\r')
_read_loop:
    mov     rax, 0                  ; sys_read
    mov     rdi, 0                  ; stdin
    lea     rsi, key_buf
    mov     rdx, 1
    syscall

    test    rax, rax
    jle     _restore_terminal

    lea     rax, key_buf
    movzx   eax, byte ptr [rax]
    cmp     eax, 10                 ; '\n'
    je      _restore_terminal
    cmp     eax, 13                 ; '\r'
    je      _restore_terminal
    jmp     _read_loop

_restore_terminal:
    ; 6. Restore original terminal settings
    mov     rax, 16                 ; sys_ioctl
    mov     rdi, 0                  ; stdin
    mov     rsi, 05402h             ; TCSETS
    lea     rdx, orig_term
    syscall

    ; 7. Print clean trailing newline
    mov     rax, 1                  ; sys_write
    mov     rdi, 1                  ; stdout
    mov     byte ptr [newline_byte], 10 ; '\n'
    lea     rsi, newline_byte
    mov     rdx, 1
    syscall

    ret
EPAUSE ENDP

END