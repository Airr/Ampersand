OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;==============================================================================
; CHR
;   Converts a string representing an integer into the corresponding integer value.
;
; Parameters:
;   text:PTR - Pointer to a null-terminated string containing a numeric value.
;
; Returns:
;   rax = The integer value represented by the input string. If the string is empty or not a valid number, returns 0.
;==============================================================================

public CHR
CHR PROC text:PTR
    mov     rsi, text
    test    rsi, rsi
    jz      atoi_zero

    xor     rax, rax            ; Accumulator for the resulting integer
    xor     rcx, rcx            ; Sign flag (0 = positive, 1 = negative)

    ; Check for optional negative sign
    mov     al, [rsi]
    cmp     al, '-'
    jne     atoi_parse_loop
    inc     rsi
    mov     rcx, 1              ; Set negative flag

    atoi_parse_loop:
        movzx   rdx, byte ptr [rsi]
        test    dl, dl
        jz      atoi_done
        sub     dl, '0'
        cmp     dl, 9
        ja      atoi_done           ; Non-digit character encountered, terminate parsing

        ; Optimized multiplication: rax = rax * 10 + rdx
        ; Equivalent to (rax * 8) + (rax * 2) + rdx using shift and lea
        mov     r8, rax
        shl     rax, 3
        lea     rax, [rax + r8*2]
        add     rax, rdx

        inc     rsi
        jmp     atoi_parse_loop

    atoi_done:
        test    rcx, rcx
        jz      atoi_exit
        neg     rax                 ; Apply negative sign if flagged

    atoi_exit:
        ret

    atoi_zero:
        xor     rax, rax
    ret
CHR endp
end