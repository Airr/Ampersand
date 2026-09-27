AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "'Savefile.txt' saved successfully.",0

.code

main proc
    local  result:qword

    CLS()

    mov result, SAVEFILE("Savefile.txt", addr tstStr)
    .if result == 1
        PRINT("%s\n", addr tstStr)
    .endif

    EXIT(result)                         
main endp

end