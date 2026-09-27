AMP_MAIN = 1

include amp.inc

.data
    divider db "--------------------------------",0

.code

main proc USES r12
    local  homePath:ptr, filePath:ptr, fileContent:ptr

    CLS()

    mov homePath, ENV$("HOME")
    mov filePath, CONCAT$(homePath, "/.bashrc")
    mov fileContent, LOADFILE$(filePath)


    PRINT("Contents of: %s\n", filePath)
    PRINT("%s\n%s\n", addr divider, fileContent)
    EXIT(0)                        
main endp

end