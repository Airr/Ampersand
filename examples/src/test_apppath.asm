AMP_MAIN = 1

include amp.inc

.data
    NULLPTR dq 0
.code

main proc
    local appStr:ptr, appPathStr:ptr, fullPath:ptr, nul:qword                   ; variables on stack

    ; CLS()   
    mov nul, 0001                                          ; clear the screen
    mov appStr, APPNAME$()
    mov appPathStr, APPPATH$()

    PRINT("Application Name: \t%s\n", appStr)
    PRINT("Application Path: \t%s\n", appPathStr)

    mov fullPath, SPRINT("Full Application Path: \t%s/%s\n", appPathStr, appStr)
    PRINT(fullPath)
    EXIT(0)                                                 
main endp

end    