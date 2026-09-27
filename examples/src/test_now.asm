AMP_MAIN = 1

include amp.inc

.data


.code

main proc USES rbx
    local result:ptr

    CLS()
    mov result, NOW$()
    PRINT("Current Date/Time: %s\n", result)

    EXIT(0)                         
main endp

end