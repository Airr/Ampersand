AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "I think that I think that I know",0

.code

main proc USES rbx
    local result:ptr

    CLS()

    mov result, REMOVE$(addr tstStr, "think")
    PRINT("Original String: '%s\n", addr tstStr)
    PRINT("With 'think' removed: '%s'\n", result)

    EXIT(0)                         
main endp

end