OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn g_argv        :qword
extrn g_argc        :qword
extrn szEmpty       :byte

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;==============================================================================
; COMMAND$
;   Returns argv[argnum] (like BCX COMMAND$).
;
; Parameters:
;   argnum (rdi)  0 = program name, 1 = first argument, ...
;
; Returns:
;   rax = pointer to the argument string (not a copy), or 0 if argnum is
;         out of range or g_argv was never set.
;==============================================================================
PUBLIC COMMAND$
COMMAND$ PROC argnum:qword
    mov     rax, g_argv             ; rax = argv array base
    test    rax, rax
    jz      no_arg                  ; g_argv never stored

    mov     rcx, argnum             ; rcx = wanted index
    xor     edx, edx                ; rdx = current index
    scan:
        cmp     qword ptr [rax + rdx * sizeof(qword)], 0
        je      no_arg                  ; hit the NULL terminator first
        cmp     rdx, rcx
        je      found
        inc     rdx
        jmp     scan

    found:
        mov     rax, [rax + rdx * sizeof(qword)]
        ret

    no_arg:
        xor     eax, eax
        ret
COMMAND$ ENDP

end