;===================================
;NOTE: This file must be compiled
;      using gcc option in make file
;===================================

AMP_MAIN = 1

AMP_MAIN equ 1
include amp.inc

.data

.code
main proc argc:qword, argv:ptr

    local lib:qword, cosine:qword, result:ptr, cosOut:ptr

    mov     lib, LOADLIB("libm.so.6")           ; open libm

    .if lib
        mov     cosine, LOADFUNC(lib, "cos")    ; load the cosine function        
        LOADSD  xmm0, 1.0                       ; Load 1.0 directly into xmm0
        call    cosine                          ; call the loaded cosine function          

        PRINT("cos(1.0) = '%s'\n", STRL$(xmm0))

        FREELIB(lib)
    .endif
    EXIT(0)
main endp

end