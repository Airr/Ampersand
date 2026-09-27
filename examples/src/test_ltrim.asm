AMP_MAIN = 1

include amp.inc

.data
    tstStr		db "   String with no leading spaces.",0

.code

main proc
    local  result:ptr

    CLS()

    mov result, LTRIM$(addr tstStr)
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Trimmed String: '%s'\n", result)

    EXIT(0)                         
main endp

end