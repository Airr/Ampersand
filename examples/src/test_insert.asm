AMP_MAIN = 1

include amp.inc

.data
    original_string db "Today is a good day",0

.code

main proc USES r12
    local  msg:ptr
    local a$:ptr, b$:ptr

    PRINT("Original String: '%s'\n", addr original_string)
    mov a$, INSERT$(addr original_string, 11, " very")
    PRINT("Modified String: '%s'\n", a$)
    
    EXIT(0)                         
main endp

end