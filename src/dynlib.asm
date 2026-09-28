
OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn dlopen  :PROC
extrn dlsym   :PROC
extrn dlclose :PROC
extrn dlerror :PROC
extrn printf  :proto :ptr, :VARARG

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.data
  errfmt      db  "error: %s", 10, 0

.code
;
;==============================================================================
; LOADLIB
;   Loads a shared library using dlopen().
;
; Parameters:
;   filename (ptr): A pointer to the ASCII string representing the path to the 
;                    shared library.
;
; Returns:
;   rax: Pointer to the handle of the loaded library, 
;        or NULL if the library could not be opened.
;
; Notes:
;   - This function requires linking against libc with the option "-lc".
;==============================================================================

PUBLIC LOADLIB
LOADLIB PROC filename:ptr

    call    dlerror

    mov     rdi, filename         ; Argument for dlopen
    mov     rsi, 1                ; RTLD_LAZY
    
    call    dlopen

    test    rax, rax
    jnz     loadlib_done

    call    dlerror
    mov     rsi, rax
    lea     rdi, errfmt
    xor     rax, rax
    call    printf

    xor     rax, rax

    loadlib_done:
        ret
LOADLIB endp

;
;==============================================================================
; FREELIB
;   Closes a previously loaded shared library using dlclose().
;
; Parameters:
;   handle (qword): The handle of the shared library to close.
;
; Returns:
;   rax: 0 on success, non-zero value on failure.
;
; Notes:
;   - This function requires linking against libc with the option "-lc".
;==============================================================================

public FREELIB
FREELIB PROC handle:qword
    mov     rbx, handle            ; Capture handle from RDI

    call    dlclose

    test    rax, rax
    jz      freelib_done

    call    dlerror
    mov     rsi, rax
    lea     rdi, errfmt
    xor     rax, rax
    call    printf

    freelib_done:
        ret
FREELIB endp

;
;==============================================================================
; LOADFUNC
;   Retrieves a function pointer from a previously loaded shared library 
;   using dlsym().
;
; Parameters:
;   libHandle (qword): The handle of the shared library.
;   funcname (ptr): A pointer to the ASCII string representing the name of the function.
;
; Returns:
;   rax: Pointer to the function, or NULL if the function could not be found in the library.
;
; Notes:
;   - This function requires linking against libc with the option "-lc".
;==============================================================================

PUBLIC LOADFUNC
LOADFUNC PROC libHandle:qword, funcname:ptr

    call    dlerror

    mov     rdi, libHandle            ; Restore handle
    mov     rsi, funcname            ; Restore symbol pointer
    call    dlsym
    
    test    rax, rax
    jnz     loadfunc_done

    call    dlerror
    mov     rsi, rax
    lea     rdi, errfmt
    xor     rax, rax
    call    printf
    xor     rax, rax

    loadfunc_done:
        ret
LOADFUNC endp

end