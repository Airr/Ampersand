OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; OPEN
;   Opens a file and returns a file descriptor.
;
; Parameters:
;   filePath:ptr - Pointer to a string containing the path of the file to open.
;   fileFlags:qword - Flags indicating the mode in which to open the file (e.g., read, write).
;   fileMode:qword - Permissions to set if creating the file (if applicable).
;
; Returns:
;   rax = File descriptor on success,
;         a negative error code on failure.
;==============================================================================

PUBLIC OPEN

OPEN PROC filePath:ptr, fileFlags:qword, fileMode:qword
    mov     rax, 2                ; SYS_OPEN syscall number
    mov     rdi, filePath
    mov     rsi, fileFlags
    mov     rdx, fileMode
    syscall
    ret 
OPEN ENDP

END