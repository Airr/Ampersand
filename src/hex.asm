OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

extrn ALLOC   :proto :qword

.code

;
;==============================================================================
; HEX$
;   Converts a QWORD (64-bit unsigned integer) to its hexadecimal 
;   string representation.
;
; Parameters:
;   num:QWORD - The 64-bit unsigned integer to convert.
;
; Returns:
;   rax = Pointer to a newly allocated string containing the hexadecimal 
;   representation of num, or null if an error occurs during allocation.
;==============================================================================

PUBLIC HEX$
HEX$ PROC USES rbx rcx rdi rsi r12 r13 num:QWORD     
    local scratch[32]:byte     

    mov       rbx, 16               ; Base 16 for hexadecimal
    mov       rax, num

    lea       rdi, [scratch + 31]        
    mov       byte ptr [rdi], 0     ; Null terminator at the very end

    ; Handle zero explicitly
    test      rax, rax
    jnz       @hex_loop
    
    dec       rdi
    mov       byte ptr [rdi], '0'
    jmp       @hex_done

@hex_loop:
    test      rax, rax
    jz        @hex_done
    xor       rdx, rdx
    div       rbx                   ; rax = rax / 16, rdx = remainder (0-15)
    
    ; Convert remainder to ASCII hex digit ('0'-'9', 'A'-'F')
    cmp       rdx, 10
    jl        @hex_decimal_digit
    add       rdx, 'A' - 10         ; Hex letters A through F
    jmp       @hex_store_digit
@hex_decimal_digit:
    add       rdx, '0'              ; Decimal digits 0 through 9

@hex_store_digit:
    dec       rdi
    mov       [rdi], dl             ; Store digit in buffer
    jmp       @hex_loop

@hex_done:
    ; rdi now points to the start of the string within scratch
    mov       r12, rdi              ; Save pointer to string start

    ; Compute string length (including null terminator) from rdi to the end of scratch
    lea       rax, [scratch + 32]
    sub       rax, r12              ; rax = length including NUL
    mov       r13, rax              ; Save length

    ; Allocate directly from the arena
    ; mov       rdi, r13
    ; lea       rsi, [arena]
    ; call      arena_alloc
    ALLOC(r13)

    test      rax, rax
    jz        @hex_fail

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

@hex_fail:
    xor       rax, rax
    ret
HEX$ ENDP

END
