OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

SYS_MKDIR       equ 83
PATH_MAX        equ 4096
EEXIST          equ 17
ENAMETOOLONG    equ 36

.code

;
;==============================================================================
; MKDIR
;   Creates a directory and any missing parent directories (like mkdir -p)
;   with the specified path and mode.
;
; Parameters:
;   pathPtr:ptr - Pointer to a null-terminated string representing the path of the new directory.
;   dirMode:dword - The mode (permissions) for the new directory, as per the mkdir system call.
;
; Returns:
;   rax = 0 on success,
;         or an error code if an error occurs during the directory creation process.
;==============================================================================

PUBLIC MKDIR
MKDIR PROC USES rbx r12 r13 r14 pathPtr:ptr, dirMode:dword
    local pathBuf[PATH_MAX]:byte

    mov     r12, pathPtr            ; read params before any syscall
    mov     r13d, dirMode
    lea     r14, pathBuf            ; r14 = working copy

    xor     ebx, ebx
    copy_loop:
        cmp     rbx, PATH_MAX
        jae     too_long
        mov     al, [r12 + rbx]
        mov     [r14 + rbx], al
        inc     rbx
        test    al, al
        jnz     copy_loop

        xor     ebx, ebx                ; rbx = scan index
    walk:
        mov     al, [r14 + rbx]
        test    al, al
        jz      final
        cmp     al, '/'
        jne     next
        test    rbx, rbx
        jz      next                    ; leading '/', nothing to create

        mov     byte ptr [r14 + rbx], 0 ; cut the path at this separator
        mov     rdi, r14
        mov     esi, r13d
        mov     eax, SYS_MKDIR
        syscall
        mov     byte ptr [r14 + rbx], '/'   ; restore separator
        cmp     rax, -EEXIST
        je      next                    ; already there, keep going
        test    rax, rax
        js      done                    ; real error, return it
    next:
        inc     rbx
        jmp     walk

    final:
        mov     rdi, r14                ; full path
        mov     esi, r13d
        mov     eax, SYS_MKDIR
        syscall
        cmp     rax, -EEXIST
        jne     done
        xor     eax, eax                ; already exists counts as success
        jmp     done

    too_long:
        mov     rax, -ENAMETOOLONG
    done:
        ret
MKDIR endp
END
