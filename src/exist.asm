OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; Name:         EXIST
; Description:  Checks for the existence of a file path using the Linux 
;               sys_faccessat system call (269) with AT_FDCWD (-100). Evaluates 
;               accessibility via F_OK (0) without opening or altering the file.
; Parameters:   rdi = pointer to null-terminated file path string (Linux ABI)
; Returns:      rax = 1 (TRUE) if the file exists and is accessible, 
;                     0 (FALSE) if it does not exist or an error occurs.
; -----------------------------------------------------------------------------
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