OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn g_argv    :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;==============================================================================
; APPNAME$
;   Returns the application name from argv[0], without the directory.
;   "/usr/bin/ls" -> "ls"
;
; Returns:
;   rax = pointer into argv[0] just past the last '/', or the start of the
;         string if there is no slash. Not a copy, so don't modify it.
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