AMP_MAIN = 1

include amp.inc


.data

.code

main proc
    local  homePath:ptr, filePath:ptr

    CLS()

    mov homePath, ENV$("HOME")
    mov filePath, CONCAT$(homePath, "/.bashrc")
    
    .if EXIST(filePath)
        PRINT("%s exists!\n", filePath)
    .else
        PRINT("%s does not exist.\n", filePath)
    .endif

    EXIT(0)                         
main endp

end