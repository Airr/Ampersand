AMP_MAIN = 1

include amp.inc

.data
    a$ db "The start of the first instance of the word 'position' is:",0

.code

main proc USES r12
    local  position:qword, msg:ptr


    ; assign position, indexof, addr a$, "position"
    ; puts(addr a$)
    ; putn(position)
    ; puts("\n")
    mov position, INDEXOF(addr a$, "position")
    PRINT("%s %d\n", addr a$, position)



    EXIT(0)                         
main endp

end