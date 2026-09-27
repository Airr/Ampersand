OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn APPNAME$     :proto
extrn APPPATH$     :proto
extrn SPRINT       :proto :PTR, :VARARG

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; EXEPATH$
;   Constructs the full path of the executable from the application name and path.
;
; Parameters:
;   None
;
; Returns:
;   rax = Pointer to a string containing the full path of the executable,
;         or null if an error occurs during construction.
;==============================================================================

PUBLIC EXEPATH$
EXEPATH$ PROC USES rbx r12 r13

    mov r12, APPNAME$()
    mov r13, APPPATH$()
    mov rbx, SPRINT("%s/%s", r13, r12)
    mov rax, rbx
    ret
EXEPATH$ endp

END