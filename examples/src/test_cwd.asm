AMP_MAIN = 1

include amp.inc

.data

.code

main proc USES r12
    local currentDir:ptr

    mov currentDir, CURDIR$()
    ; assign msg, join, 3, "Current Dir: ", curDir, "\n"
    PRINT("Current Working Dir: %s\n", currentDir)

    EXIT(0)                       
main endp

end