AMP_MAIN = 1

include amp.inc

.data

.code

main proc argc:dword, argv:ptr
    local number:qword, a$:ptr

    mov a$, ENC$("A",0)
    mov number, ASC("A")    ; convert the character, assigning to 'number' variable
    PRINT("ASC(%s) = '%d'\n", a$, number)

    EXIT(0)                     ; cleanly exit program
main endp

end