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
; Name:         SEEK
; Description:  Reposition read/write file offset using the Linux 
;               sys_lseek system call (8).
; Parameters:   rdi = file descriptor (fd)
;               rsi = offset value
;               rdx = whence (0 = SEEK_SET, 1 = SEEK_CUR, 2 = SEEK_END)
; Returns:      rax = resulting offset location from start of file, 
;                     or negative error code on failure
; -----------------------------------------------------------------------------
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