AMP_MAIN = 1

include amp.inc

.data
    tstStr		db "String to extract things from.",0

.code

main proc USES rbx
    local result:ptr

    CLS()

    mov result, MID$(addr tstStr, 10, 7)
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Extracted String: '%s'\n", result)

    EXIT(0)                         
main endp

end