AMP_MAIN = 1

include amp.inc

.data


.code

main proc
    local  a$:ptr

    CLS()

    mov a$, TIME$()
    PRINT("The Current Time is: %s\n\n", a$)

    EXIT(0)                         
main endp

end