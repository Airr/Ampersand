OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;==============================================================================
; ASC
;   Converts a string into the corresponding integer value.
;
; Parameters:
;   text:PTR - Pointer to a null-terminated string.
;
; Returns:
;   rax = The integer value of the first character represented by the input string.
;         If the string is empty or not a valid string, returns 0.
;==============================================================================

PUBLIC ASC
ASC PROC text:PTR
    mov     rsi, text
    test    rsi, rsi
    jz      asc_zero

    xor     rax, rax            ; Accumulator for the resulting integer
    xor     rcx, rcx            ; Sign flag (0 = positive, 1 = negative)

    ; Check for optional negative sign
    mov     al, [rsi]
    cmp     al, '-'
    jne     asc_parse_loop
    inc     rsi
    mov     rcx, 1              ; Set negative flag

    asc_parse_loop:
        movzx   rdx, byte ptr [rsi]
        test    dl, dl
        jz      asc_done
        sub     dl, '0'
        cmp     dl, 9
        ja      asc_done           ; Non-digit character encountered, terminate parsing

        ; Optimized multiplication: rax = rax * 10 + rdx
        ; Equivalent to (rax * 8) + (rax * 2) + rdx using shift and lea
        mov     r8, rax
        shl     rax, 3
        lea     rax, [rax + r8*2]
        add     rax, rdx

        inc     rsi
        jmp     asc_parse_loop

    asc_done:
        test    rcx, rcx
        jz      asc_exit
        neg     rax                 ; Apply negative sign if flagged

    asc_exit:
        ret

    asc_zero:
        xor     rax, rax
    ret
ASC endp
end