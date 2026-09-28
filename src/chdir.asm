OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

SYS_CHDIR             EQU 80

.code

;
;==============================================================================
; CHDIR - Change the current working directory to the specified folder.
;
; Parameters:
;   folder (ptr): A pointer to a null-terminated ASCII string representing 
;                 the new working directory path.
;
; Returns:
;   rax: 1 if successful, 0 if an error occurred.
;==============================================================================

PUBLIC CHDIR
CHDIR proc folder:ptr
    mov  eax, SYS_CHDIR
    mov  rdi, folder
    syscall
    test rax, rax
    setz al                     ; 1 = success, 0 = failure
    movzx eax, al
    ret
CHDIR endp
END