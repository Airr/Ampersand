OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn g_envp    :qword


`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.data
	szProcEnviron   db "/PROC/self/environ", 0
	
.code

;
;==============================================================================
; ENV$
;   Retrieves the value of an environment variable by name.
;
; Parameters:
;   namePtr:ptr - Pointer to a string representing the name 
;   of the environment variable to retrieve.
;
; Returns:
;   rax = Pointer to a string containing the value of the environment variable,
;         or null if the environment variable is not found.
;==============================================================================

PUBLIC ENV$
ENV$ PROC USES rbx r12 namePtr:ptr
    mov     r8, namePtr             ; r8 = wanted name
    mov     r12, g_envp             ; r12 = walks envp entries
    test    r12, r12
    jz      not_found

    next_entry:
        mov     rbx, [r12]              ; rbx = "NAME=value" string
        test    rbx, rbx
        jz      not_found               ; NULL terminator: no match

        xor     ecx, ecx                ; compare name against entry prefix
    cmp_loop:
        mov     al, [r8 + rcx]
        test    al, al
        jz      name_end                ; whole name matched, check for '='
        cmp     al, [rbx + rcx]
        jne     advance
        inc     rcx
        jmp     cmp_loop

    name_end:
        cmp     byte ptr [rbx + rcx], '='
        jne     advance                 ; e.g. wanted "PATH", entry "PATHEXT=..."
        lea     rax, [rbx + rcx + 1]    ; value starts after '='
        ret

    advance:
        add     r12, sizeof qword
        jmp     next_entry

    not_found:
        xor     eax, eax
        ret
ENV$ endp

END