AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "=  Program Banner  =",0

.code

main proc USES rbx
    local  banner:ptr

    CLS()

    mov banner, REPEAT$(20, "=")
    PRINT("%s\n%s\n%s\n", banner, addr tstStr, banner)

    EXIT(0)                         
main endp

end