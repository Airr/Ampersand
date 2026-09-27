AMP_MAIN = 1

AMP_MAIN = 1

include amp.inc

.data

.code

main proc
    local appStr:ptr                            ; variable on stack

    CLS()                                       ; clear the screen
    mov appStr, APPNAME$()                       ; assign application name to appStr variable
    PRINT("Application Name: '%s'\n", appStr)   ; print the application name
    EXIT(0)                                     ; clean exit
main endp

end    