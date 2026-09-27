AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "Hello, World",0

.code

main proc
    local  tmpStr:ptr

    CLS()

    mov tmpStr, RIGHT$(addr tstStr, 5)
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Modified String: '%s'\n", tmpStr)

    EXIT(0)                         
main endp

end