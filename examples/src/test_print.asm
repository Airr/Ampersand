AMP_MAIN = 1

include amp.inc


.data


.code

main proc argc:qword, argv:ptr
    local hexNum:qword, decNum:qword, homeDir:ptr, char:ptr

    mov hexNum, 0x00FF
    mov decNum, 65535
    mov homeDir, ENV$("HOME")
    mov char, 'Z'

    PRINT("Home Dir: '%s'\nDEC Number: '%d'\nHEX Number: '%x'\nCHAR: '%c'\n", homeDir, decNum, hexNum, char)
    PRINT("Number of Command Line Arguments: '%d'\n", CMDCOUNT())

    EXIT(0)
main endp

end