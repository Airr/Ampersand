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
; Name:         OPEN
; Description:  Opens a file path using the Linux sys_open system call (2).
; Parameters:   rdi = pointer to null-terminated file path string
;               rsi = flags (e.g., 0 for O_RDONLY, 1 for O_WRONLY, 64 for O_CREAT)
;               rdx = mode (permissions if creating, e.g., 0644)
; Returns:      rax = file descriptor (> 0) on success, or negative error code on failure
; -----------------------------------------------------------------------------
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