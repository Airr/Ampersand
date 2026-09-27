OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
EXTERN strlen       :PROC

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; Name:         WRITE$
; Description:  Writes data to an open file descriptor using the Linux 
;               sys_write system call (1).
; Parameters:   rdi = file descriptor (fd)
;               rsi = pointer to data buffer
;               rdx = number of bytes to write
; Returns:      rax = number of bytes written, or negative error code on failure
; -----------------------------------------------------------------------------
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