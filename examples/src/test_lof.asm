AMP_MAIN = 1

include amp.inc

.data

.code

main proc argc:dword, argv:ptr
    local fSize:qword, Path:ptr

    CLS()                           ; clear the screen

    mov Path, EXEPATH$()            ; full path to executable
    mov fSize, LOF(Path)            ; size of the executable in bytes

    PRINT("'%s': File Size = %d bytes\n", Path, fSize)

    EXIT(0)                         ; cleanly exit program
main endp


end