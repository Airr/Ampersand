AMP_MAIN = 1

include amp.inc

.data

.code

main proc USES r12
    local envPath:ptr, msg:ptr

    mov envPath, ENV$("HOME")
    PRINT("$HOME = %s\n", envPath)
    EXIT(0)                       
main endp

end