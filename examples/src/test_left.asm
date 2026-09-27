AMP_MAIN = 1

include amp.inc

.data
    a$ db "Hello, this is a string.",0

.code

main proc USES r12
    local  res1:ptr, msg:ptr

    mov res1, LEFT$(addr a$, 5)
    PRINT("Original String: '%s'\n", addr a$)
    PRINT("Modified String: '%s'\n", res1)

    EXIT(0)                         
main endp

end