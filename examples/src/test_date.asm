AMP_MAIN = 1

include amp.inc

.data

.code

main proc
    local curDate:ptr, isoDate:ptr

    mov curDate, DATE$()
    mov isoDate, ISODATE$()
    PRINT("Current Date:\t  %s\n", curDate)
    PRINT("Current ISO Date: %s\n", isoDate)

    EXIT(0)                         
main endp

end