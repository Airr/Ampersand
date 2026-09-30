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

;
;==============================================================================
; EXIT
;   Exits the program with a given exit code.
;
; Parameters:
;   code:qword - The exit code to return to the operating system.
;
; Returns:
;   None (exits the program immediately)
;==============================================================================

PUBLIC EXIT
EXIT PROC code:qword
    mov rdi, code           ; Exit code
    mov rax, 231            ; sys_exit_group
    syscall
EXIT endp
END