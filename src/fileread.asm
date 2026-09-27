OPTION LITERALS:ON
option casemap:none
option frame:auto 


`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; READ
;   Reads data from a file descriptor into a buffer.
;
; Parameters:
;   fileHandle:qword - The file descriptor to read from.
;   buffer:ptr - Pointer to the buffer where the data will be stored.
;   numBytes:qword - Number of bytes to read.
;
; Returns:
;   rax = Number of bytes actually read on success,
;         a negative error code on failure.
;==============================================================================

PUBLIC READ

READ PROC   fileHandle:qword, buffer:ptr, numBytes:qword
    ; Incoming: rdi = fd, rsi = buffer pointer, rdx = count
    mov rdi, fileHandle
    mov rsi, buffer
    mov rdx, numBytes
    
    mov       rax, 0                ; SYS_READ syscall number
    syscall
    ret 
READ ENDP

END