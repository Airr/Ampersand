; -----------------------------------------------------------------------------
; Name: EIXT
; C Prototype: void EXIT(int code);
; Description: Pure JWASM x86_64 exit PROCedure using flat offset addressing 
;              for correct PIE linking compatibility under Linux.
; -----------------------------------------------------------------------------
OPTION LITERALS:ON
option casemap:none
option frame:auto


`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

PUBLIC EXIT

EXIT PROC code:qword
    mov rdi, code           ; Exit code
    mov rax, 60             ; sys_exit
    syscall
EXIT endp
END