OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

.data

.code

;
;==============================================================================
; STR$
;   Converts a 64-bit signed integer into its STRING representation.
;   Handles positive and negative numbers, as well as zero.
;
; Parameters:
;   num (qword): The signed 64-bit integer to be converted.
;
; Returns:
;   rax: Pointer to the arena-allocated string representing the number.
;==============================================================================

PUBLIC STR$
STR$ PROC USES rbx rcx rdi rsi r12 r13 num:QWORD     
    local scratch[32]:byte     

    mov       rbx, 10
    mov       rax, num
    xor       rsi, rsi              ; rsi = negative flag (0 = positive, 1 = negative)

    lea       rdi, [scratch + 31]        
    mov       byte ptr [rdi], 0     ; Null terminator at the very end

    ; Check if the number is negative (signed check)
    test      rax, rax
    jns       @str_pos              ; Jump if positive or zero
    mov       rsi, 1                ; Set negative flag
    neg       rax                   ; Make positive for the division loop

@str_pos:
    ; Handle zero explicitly
    test      rax, rax
    jnz       @str_loop
    
    dec       rdi
    mov       byte ptr [rdi], '0'
    jmp       @str_check_sign

@str_loop:
    test      rax, rax
    jz        @str_check_sign
    xor       rdx, rdx
    div       rbx                   ; rax = rax / 10, rdx = remainder
    add       rdx, '0'              ; Convert remainder to ASCII digit
    dec       rdi
    mov       [rdi], dl             ; Store digit in buffer
    jmp       @str_loop

@str_check_sign:
    ; Prepend minus sign if the original number was negative
    test      rsi, rsi
    jz        @str_done
    dec       rdi
    mov       byte ptr [rdi], '-'

@str_done:
    ; rdi now points to the start of the string within scratch
    mov       r12, rdi              ; Save pointer to string start

    ; Compute string length (including null terminator) from rdi to the end of scratch
    lea       rax, [scratch + 32]
    sub       rax, r12              ; rax = length including NUL
    mov       r13, rax              ; Save length

    ; Allocate directly from the arena
    mov       rdi, r13
    lea       rsi, [arena]
    call      arena_alloc

    test      rax, rax
    jz        @str_fail

    ; Copy string from stack scratch buffer to arena buffer
    mov       rdi, rax              ; Destination = arena buffer
    mov       rsi, r12              ; Source = scratch string start
    mov       rcx, r13              ; Length
    cld
    rep movsb

    ; Restore return value pointer to the arena buffer
    sub       rdi, r13              ; Reset rdi back to start of arena buffer
    mov       rax, rdi
    ret

@str_fail:
    xor       rax, rax
    ret
STR$ ENDP

end