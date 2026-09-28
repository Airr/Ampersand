AMP_MAIN = 1

include amp.inc

.data

.code

main proc USES r12
    local cmdStr:ptr, numStr:ptr, count:qword, result:ptr

    mov count, CMDCOUNT()

    .if count
        .for (r12 = 1 : r12 <= count : r12++)
            mov cmdStr, COMMAND$(r12)
            PRINT("Argument Number %d: %s\n", r12, cmdStr)
        .endfor
        EPAUSE()
        EXIT(0)
    .endif

    PRINT("No Argument(s) provided.\n")
    EXIT(1)                         
main endp

end