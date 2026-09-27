OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; EXIST
;   Checks if a file or directory exists at the given path.
;
; Parameters:
;   filePath:ptr - Pointer to a string containing the path to check.
;
; Returns:
;   rax = 1 (TRUE) if the file or directory exists,
;         0 (FALSE) if it does not exist or an error occurs.
;==============================================================================

PUBLIC EXIST

EXIST PROC filePath:ptr
    ; Incoming: rdi holds the filePath pointer from the caller (Linux ABI)
    
    
    mov       rsi, filePath         ; Move filePath pointer into rsi (faccessat path argument)
    mov       rdi, -100             ; AT_FDCWD (-100)
    mov       rax, 269              ; SYS_FACCESSAT syscall number
    xor       rdx, rdx              ; mode = 0 (F_OK, check existence)
    xor       r10, r10              ; flags = 0
    syscall

    test      rax, rax
    js        exist_error

    mov       rax, 1                ; Return TRUE (exists)
    ret

exist_error:
    xor       rax, rax              ; Return FALSE (does not exist or error)
    ret 
EXIST ENDP

END