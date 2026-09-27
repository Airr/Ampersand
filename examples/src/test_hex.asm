AMP_MAIN = 1

include amp.inc


.data


.code

main proc argc:dword, argv:ptr
    local hexNum:QWORD

    mov hexNum, 0x00FF
    PRINT("Decimal Value: %s\n", STR$(hexNum))
    PRINT("Hex Value:     %s\n", HEX$(hexNum))
    EXIT(0)
main endp

end