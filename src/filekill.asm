OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
EXTERN strlen       :PROC

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; KILL
;   Deletes a file or symbolic link.
;
; Parameters:
;   filePath:ptr - Pointer to a string containing the path of the file 
;                  or symbolic link to delete.
;
; Returns:
;   rax = 0 on success,
;         a negative error code on failure.
;==============================================================================

PUBLIC KILL

KILL PROC filePath:ptr
    mov rdi, filePath    
    mov       rax, 87               ; SYS_UNLINK syscall number
    syscall
    ret 
KILL ENDP

END