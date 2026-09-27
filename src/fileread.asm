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
; Name:         READ
; Description:  Reads data from an open file descriptor using the Linux 
;               sys_read system call (0).
; Parameters:   rdi = file descriptor (fd)
;               rsi = pointer to destination buffer
;               rdx = maximum number of bytes to read
; Returns:      rax = number of bytes read on success, 0 on EOF, 
;                     or a negative error code on failure
; -----------------------------------------------------------------------------
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