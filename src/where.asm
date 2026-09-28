OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn ENV$    :proto  :ptr
extrn SPLIT$  :proto  :ptr, :ptr
extrn JOIN$   :proto  :qword, :VARARG
extrn EXIST   :proto  :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; WHERE$
;   Searches for an executable in the system's PATH.
;
; Parameters:
;   argv (ptr): A pointer to the ASCII string representing the filename to search for.
;
; Returns:
;   rax: Pointer to an arena-allocated string containing the full path of the executable,
;        or NULL if no such file is found in the PATH directories.
;==============================================================================

PUBLIC WHERE$
WHERE$ PROC USES rbx r12 r13 r14 argv:ptr
    mov     r14, argv
    mov     r12, ENV$("PATH")
    mov     r13, SPLIT$(r12, ":")

    .while qword ptr [r13]
        mov     rbx, [r13]
        mov     rbx, JOIN$(3, rbx, "/", r14)
        .if EXIST(rbx)
            mov     rax, rbx            ; found: return the joined path
            ret
        .endif
        add     r13, sizeof qword
    .endw
    xor     eax, eax                    ; not found: return NULL
    ret
WHERE$ endp

end