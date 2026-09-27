OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

extrn puts          :proto :ptr
extrn strlen        :proto :ptr
extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword                          ; Fixed: data symbol declaration

.code 

;
;==============================================================================
; INPUT$
;   Reads a line of text from standard input and stores it in an allocated string.
;
; Parameters:
;   msg:ptr - Pointer to a prompt message to be displayed before reading input.
;
; Returns:
;   rax = Pointer to a newly allocated string containing the user's input,
;         or null if an error occurs during allocation or input failure.
;==============================================================================

PUBLIC INPUT$
INPUT$ PROC USES rbx r12 r13, msg:ptr
    local destBuf[4096]:byte
    lea rbx, destBuf
    mov r12, sizeof destBuf

    invoke puts, msg

    mov rax, 0                 ; sys_read
    mov rdi, 0                 ; stdin
    mov rsi, rbx               ; Set destination buffer
    mov rdx, r12
    syscall

    test rax, rax
    jle input_fail

    mov r13, rax               ; Save bytes read length
    mov byte ptr [rbx + rax - 1], 0  ; Null-terminate INPUT$ string

    mov rdi, r13               ; Request size = bytes read
    lea rsi, [arena]           ; Correctly pass arena descriptor pointer
    call arena_alloc
    
    test rax, rax
    jz input_fail

    mov r12, rax               ; Save allocated arena pointer

    ; Copy from stack buffer (rbx) to arena buffer (r12)
    mov rdi, r12               ; Destination = arena buffer
    mov rsi, rbx               ; Source = stack buffer
    mov rcx, r13               ; Length = bytes read
    cld
    rep movsb

    mov rax, r12               ; Return arena-allocated string pointer
    jmp input_done

input_fail:
    xor rax, rax

input_done:
    ret
INPUT$ endp 
end