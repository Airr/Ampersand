OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;
;==============================================================================
; LCASE$
;   Converts all uppercase characters in a string to lowercase.
;
; Parameters:
;   str_buf:ptr - Pointer to the string that will be converted.
;
; Returns:
;   rax = Pointer to the modified string, which is the same as the input string.
;==============================================================================

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