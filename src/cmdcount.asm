OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn g_argc    :qword
`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;==============================================================================
; CMDCOUNT
;   Retrieves the number of command-line arguments provided to the program, 
;   excluding the executable itself.
;
; Parameters:
;   None
;
; Returns:
;   rax = The number of command-line arguments (excluding argv[0]).
;==============================================================================

PUBLIC CMDCOUNT
CMDCOUNT PROC USES r12
    mov r12, g_argc
    lea rax, [r12 -1]   ; don't count argv[0] (executable)
    ret
CMDCOUNT ENDP

end