AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "I think I could do it.",0

.code

main proc
    local  tmpStr:ptr

    CLS()

    mov tmpStr, REVERSE$(addr tstStr)
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Reversed String: '%s'\n", tmpStr)

    EXIT(0)                         
main endp

end