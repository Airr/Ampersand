OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn g_argv    :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; APPNAME$
;   Retrieves the name of the current application (usually argv[0]).
;
; Parameters:
;   None
;
; Returns:
;   rax = Pointer to a string containing the name of the application,
;         or null if an error occurs.
;==============================================================================

PUBLIC APPNAME$
APPNAME$ PROC
    mov     rax, g_argv
    mov     rax, [rax]              ; rax = argv[0]
    mov     rdx, rax                ; rdx = start of string (also the result if no slash)

scan:
    mov     cl, [rax]
    test    cl, cl
    jz      done                    ; hit the NUL
    inc     rax
    cmp     cl, '/'
    jne     scan
    mov     rdx, rax                ; slash seen: name starts right after it
    jmp     scan

done:
    mov     rax, rdx
    ret
APPNAME$ ENDP



end