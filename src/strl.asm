
OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn ALLOC   :proto :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.data
    mask_abs  dq  0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF  ; 128-bit mask (16 bytes)
    pow10_6   dq  1000000.0           ; Multiplier for 6 decimal precision places
    
.code

;
;==============================================================================
; STRL$
;   Converts a 64-bit floating-point number into its ASCII representation.
;   The result is formatted to 6 decimal places.
;
; Parameters:
;   float (real8): The double-precision floating-point number to be converted.
;
; Returns:
;   rax: Pointer to the arena-allocated string representing the number,
;        or NULL if allocation fails.
;==============================================================================

PUBLIC STRL$
STRL$ PROC USES rbx r12 r13 r14 r15 float:REAL8
    local int_part:qword, frac_part:qword, buf_ptr:qword

    ; 1. Allocate 64 bytes from our memory arena for the string buffer
    ; mov     rdi, 64
    ; mov     rsi, addr arena
    ; call    arena_alloc
    ; arena_alloc(64, addr arena)
    ALLOC(64)
    test    rax, rax
    jz      strl_error
    mov     buf_ptr, rax
    mov     rbx, rax            ; RBX tracks current write position

    ; 2. Handle sign check / absolute value
    movsd   xmm1, float          ; Keep copy of original
    pxor    xmm2, xmm2
    ucomisd xmm1, xmm2
    jnb     strl_is_positive

    ; If negative, write '-' and negate value
    mov     byte ptr [rbx], '-'
    inc     rbx
    andpd   xmm1, oword ptr [mask_abs]

strl_is_positive:
    ; 3. Extract integer part using truncation
    cvttsd2si rax, xmm1
    mov     int_part, rax

    ; Convert integer part to ASCII (reverse order digits, then reverse)
    mov     r12, rbx            ; Save start of integer digits
    mov     rax, int_part
    test    rax, rax
    jnz     strl_convert_int
    
    ; Handle zero case explicitly
    mov     byte ptr [rbx], '0'
    inc     rbx
    jmp     strl_int_done

strl_convert_int:
    mov     rcx, 10
strl_int_loop:
    xor     rdx, rdx            ; MUST clear rdx before every div instruction
    div     rcx                 ; RAX = quotient, RDX = remainder (digit)
    add     dl, '0'
    mov     byte ptr [rbx], dl
    inc     rbx
    test    rax, rax
    jnz     strl_int_loop

    ; Reverse the extracted integer digits in place
    mov     r13, rbx
    dec     r13                 ; R13 points to last digit
strl_reverse_loop:
    cmp     r12, r13
    jge     strl_int_done
    mov     al, byte ptr [r12]
    mov     dl, byte ptr [r13]
    mov     byte ptr [r12], dl
    mov     byte ptr [r13], al
    inc     r12
    dec     r13
    jmp     strl_reverse_loop

strl_int_done:
    ; 4. Add decimal point
    mov     byte ptr [rbx], '.'
    inc     rbx

    ; 5. Extract fractional part (value - int_part)
    cvtsi2sd xmm3, int_part
    subsd   xmm1, xmm3          ; xmm1 now holds fractional part (0.xxxx)

    ; Multiply fractional part by 1,000,000 for 6 decimal places
    movsd   xmm4, qword ptr [pow10_6]
    mulsd   xmm1, xmm4
    cvttsd2si rax, xmm1
    mov     frac_part, rax

    ; Convert fractional part to ASCII with zero-padding (6 digits fixed)
    mov     r14, 6
    mov     r15, rbx
    add     r15, 6              ; Point to end of fraction
    mov     byte ptr [r15], 0   ; Null-terminate string at the end

strl_frac_loop:
    dec     r15
    xor     rdx, rdx
    mov     rax, frac_part
    mov     rcx, 10
    div     rcx
    mov     frac_part, rax
    add     dl, '0'
    mov     byte ptr [r15], dl
    dec     r14
    jnz     strl_frac_loop

    ; Move RBX past the 6-digit fractional block
    add     rbx, 6
    mov     byte ptr [rbx], 0   ; Ensure final null-termination

    mov     rax, buf_ptr        ; Return base pointer of string
    ret

strl_error:
    xor     rax, rax
    ret
STRL$ endp

end