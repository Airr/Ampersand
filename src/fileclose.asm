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
; CLOSE
;   Closes a file descriptor.
;
; Parameters:
;   fileHandle:qword - The file descriptor to close.
;
; Returns:
;   rax = 0 on success,
;         a negative error code on failure.
;==============================================================================

PUBLIC CLOSE

CLOSE PROC fileHandle:qword
    mov       rax, 3                ; SYS_CLOSE syscall number
    mov       rdi, fileHandle
    syscall
    ret 
CLOSE ENDP

END