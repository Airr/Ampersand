OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; WRITE$
;   Writes data from a buffer to a file descriptor.
;
; Parameters:
;   fileHandle:qword - The file descriptor to write to.
;   buffer:ptr - Pointer to the buffer containing the data to write.
;   numBytes:qword - Number of bytes to write.
;
; Returns:
;   rax = Number of bytes actually written on success,
;         a negative error code on failure.
;==============================================================================

PUBLIC WRITE$

WRITE$ PROC fileHandle:qword, buffer:ptr, numBytes:qword
    mov       rdi, fileHandle
    mov       rsi, buffer
    mov       rdx, numBytes
    mov       rax, 1                ; SYS_WRITE syscall number
    syscall
    ret 
WRITE$ ENDP

END