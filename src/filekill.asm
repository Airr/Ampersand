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
; Name:         KILL
; Description:  Deletes a file path using the Linux sys_unlink system call (87).
; Parameters:   rdi = pointer to null-terminated file path string (Linux ABI)
; Returns:      rax = 0 on success, or a negative error code on failure
; -----------------------------------------------------------------------------
PUBLIC KILL

KILL PROC filePath:ptr
    mov rdi, filePath    
    mov       rax, 87               ; SYS_UNLINK syscall number
    syscall
    ret 
KILL ENDP

END