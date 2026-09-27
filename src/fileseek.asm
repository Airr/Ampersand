OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; SEEK
;   Sets the file offset of a file descriptor.
;
; Parameters:
;   fileHandle:qword - The file descriptor to seek on.
;   fileOffset:qword - The new position in bytes from the origin.
;   seekFlags:qword - Indicates where the offset is relative to (e.g., start, current position).
;
; Returns:
;   rax = New file offset on success,
;         a negative error code on failure.
;==============================================================================

PUBLIC SEEK
SEEK PROC fileHandle:qword, fileOffset:qword, seekFlags:qword
    mov     rdi, fileHandle
    mov     rsi, fileOffset
    mov     rdx, seekFlags
    mov     rax, 8                ; SYS_LSEEK syscall number
    syscall
    ret 
SEEK ENDP

END