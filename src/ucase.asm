OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;
;==============================================================================
; UCASE$
;   Converts a given ASCII string into uppercase in place.
;
; Parameters:
;   str_buf (ptr): A pointer to the null-terminated ASCII string to be converted.
;
; Returns:
;   rax: Pointer to the same string, now containing only uppercase characters.
==============================================================================

PUBLIC UCASE$
UCASE$ PROC USES rsi rdi str_buf:PTR
    mov     rsi, str_buf
    test    rsi, rsi
    jz      @strupr_done
    mov     rdi, rsi

    @strupr_loop:
        mov     al, [rdi]
        test    al, al
        jz      @strupr_done

        cmp     al, 'a'
        jb      @strupr_next
        cmp     al, 'z'
        ja      @strupr_next
        sub     al, 20h             ; Convert lowercase to uppercase
        mov     [rdi], al

    @strupr_next:
        inc     rdi
        jmp     @strupr_loop

    @strupr_done:
        mov     rax, str_buf            ; Return pointer to modified string
    ret
UCASE$ endp
end