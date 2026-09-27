AMP_MAIN = 1

include amp.inc

.data

.code

main proc argc:dword, argv:ptr
    CLS()                           ; clear the screen
    PRINT("Screen was cleared.\n")  ; informational message
    EXIT(0)                         ; cleanly exit program
main endp

end