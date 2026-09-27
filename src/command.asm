OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn g_argv        :qword
extrn g_argc        :qword
extrn szEmpty       :byte

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; COMMAND$
;   Retrieves a command-line argument from the program's arguments.
;
; Parameters:
;   argnum:qword - The zero-based index of the desired command-line argument.
;
; Returns:
;   rax = Pointer to the string containing the specified command-line argument,
;         or null if the specified index is out of bounds or an error occurs.
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