AMP_MAIN = 1

include amp.inc


.data
    tmpStr dq 0
.code

main proc argc:dword, argv:ptr
    local str_buf:ptr

    CLS()

    mov str_buf, STR$(123)              ; convert the number to an arena-allocated string, assigning to local 'str_buf' variable
    PRINT("Number1: %s\n", str_buf)     ; print the converted number
    
    mov tmpStr, STR$(65535)             ; convert the number to an arena-allocated string, assigning to global 'tmpStr' variable
    PRINT("Number2: %s\n", tmpStr)      ; print the converted number

    EXIT(0)                             ; exit cleanly
main endp

end