AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "I think I could do it.",0

.code

main proc
    local  result:ptr

    CLS()

    mov result, REPLACE$(addr tstStr, "think", "thought")
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Modified String: '%s'\n", result)

    EXIT(0)                         
main endp

end