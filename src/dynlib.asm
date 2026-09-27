
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