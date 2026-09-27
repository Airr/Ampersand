AMP_MAIN = 1

include amp.inc


.data
    tstStr db "   This   string had   multiple and duplicate      spaces in it.   ",0

.code

main proc
    local  a$:ptr

    CLS()

    mov a$, TRIM$(addr tstStr)
    PRINT("Original String: '%s'\n", addr tstStr)
    PRINT("Modified String: '%s'\n", a$)

    EXIT(0)                         
main endp

end