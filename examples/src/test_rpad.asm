AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "Any exclamation points? ",0

.code

main proc
    local  tmpStr:ptr

    CLS()

    mov tmpStr, RPAD$(addr tstStr, 5, '!')
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Modified String: '%s'\n", tmpStr)

    EXIT(0)                         
main endp

end