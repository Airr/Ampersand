AMP_MAIN = 1

include amp.inc

.data

    text    db "Armando",0
    text_len equ $-text
.code

main proc 
    ; lea     rdi, text 
    ; xor     esi, esi
    ; call ENC$
    ENC$(addr text, 0)
    PRINT("%s\n", rax)


    EXIT(0)
main endp

end