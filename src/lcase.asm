OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

PUBLIC LCASE$
LCASE$ PROC USES rsi rdi str_buf:PTR
    mov     rsi, str_buf
    test    rsi, rsi
    jz      @strlwr_done
    mov     rdi, rsi

    @strlwr_loop:
        mov     al, [rdi]
        test    al, al
        jz      @strlwr_done

        cmp     al, 'A'
        jb      @strlwr_next
        cmp     al, 'Z'
        ja      @strlwr_next
        or      al, 20h             ; Convert uppercase to lowercase
        mov     [rdi], al

    @strlwr_next:
        inc     rdi
        jmp     @strlwr_loop

    @strlwr_done:
        mov     rax, str_buf            ; Return pointer to modified string
    ret
LCASE$ endp
end