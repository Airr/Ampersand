AMP_MAIN = 1

include amp.inc

.data

.code

main proc
    local tmpStr:ptr

    mov tmpStr, EXTRACT$("This is a Long String", "Long")
    PRINT("Extracted String: '%s'\n", tmpStr)
    EXIT(0)                         
main endp

end