AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "Are there any trailing spaces?    ",0

.code

main proc
    local  tmpStr:ptr, result:ptr, original:ptr

    CLS()

    mov tmpStr, RTRIM$(addr tstStr)
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Modified String: '%s'\n", tmpStr)

    EXIT(0)                         
main endp

end