OPTION LITERALS:ON
option casemap:none
option frame:auto

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

SYS_RENAME            EQU 82

.code

;
;==============================================================================
; RENAME
;   Rename a file or directory from oldpath to newpath.
;
; Parameters:
;   oldpath (ptr): A pointer to a null-terminated ASCII string representing 
;                  the current path of the file or directory.
;   newpath (ptr): A pointer to a null-terminated ASCII string representing 
;                  the new path for the file or directory.
;
; Returns:
;   rax: 1 if successful, 0 if an error occurred.
;
; Notes:
;   - This function will fail if attempting to rename a directory and
;     the newpath already exists and contains files.
;==============================================================================

PUBLIC RENAME
RENAME PROC oldpath:ptr, newpath:ptr
    mov  eax, SYS_RENAME        ; 82 on x86-64
    mov  rdi, oldpath
    mov  rsi, newpath
    syscall
    test rax, rax
    setz al                     ; 1 = success, 0 = failure
    movzx eax, al
    ret
RENAME endp

END
