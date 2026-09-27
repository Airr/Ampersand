OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

extrn LEN:proto :ptr
extrn arena_alloc:proto :qword, :ptr
extrn arena:qword                          ; Reference global arena from amp.inc

.data
    szEmpty db 0

.code

;
;==============================================================================
; JOIN$
;   Joins up to 5 strings into a single string with a delimiter.
;
; Parameters:
;   count:qword - Number of strings to join (up to 5).
;   arg1:ptr, arg2:ptr, arg3:ptr, arg4:ptr, arg5:ptr - Pointers to the strings to be joined.
;
; Returns:
;   rax = Pointer to a newly allocated string containing the concatenated result,
;         or null if an error occurs during allocation.
;==============================================================================

PUBLIC JOIN$
JOIN$ PROC  
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 48                             ; Space for 5 register spills (rsi, rdx, rcx, r8, r9)

    mov     r12, rdi                        ; r12 = total string count
    ; mov     rax, qword ptr [arena]          ; Load global arena pointer
    ; mov     r14, rax                        ; r14 = arena descriptor pointer
    lea     r14, qword ptr [arena]
    
    ; Save volatile register arguments (args 0 through 4)
    mov     qword ptr [rbp - 40], rsi       ; arg 0
    mov     qword ptr [rbp - 48], rdx       ; arg 1
    mov     qword ptr [rbp - 56], rcx       ; arg 2
    mov     qword ptr [rbp - 64], r8        ; arg 3
    mov     qword ptr [rbp - 72], r9        ; arg 4

    test    r12, r12
    jle     join_empty

    xor     r15, r15                        ; Length accumulator
    xor     r13, r13                        ; Loop counter (i = 0)

    len_calc_loop:
        cmp     r13, r12
        jge     len_calc_done

        cmp     r13, 0
        je      len_arg_0
        cmp     r13, 1
        je      len_arg_1
        cmp     r13, 2
        je      len_arg_2
        cmp     r13, 3
        je      len_arg_3
        cmp     r13, 4
        je      len_arg_4

        ; If index >= 5, fetch from caller's stack frame
        mov     rax, r13
        sub     rax, 5
        shl     rax, 3
        mov     rbx, qword ptr [rbp + 16 + rax]
        jmp     len_got_string

    len_arg_0:
        mov     rbx, qword ptr [rbp - 40]
        jmp     len_got_string
    len_arg_1:
        mov     rbx, qword ptr [rbp - 48]
        jmp     len_got_string    
    len_arg_2:
        mov     rbx, qword ptr [rbp - 56]
        jmp     len_got_string      
    len_arg_3:
        mov     rbx, qword ptr [rbp - 64]
        jmp     len_got_string 
    len_arg_4:
        mov     rbx, qword ptr [rbp - 72]    

    len_got_string:
        test    rbx, rbx
        jz      len_calc_next

        push    rdi
        mov     rdi, rbx
        call    LEN
        pop     rdi
        add     r15, rax

    len_calc_next:
        inc     r13
        jmp     len_calc_loop

    len_calc_done:
        inc     r15                         ; Add space for null terminator

    mov     rdi, r15
    mov     rsi, r14
    call    arena_alloc
    
    test    rax, rax
    jz      join_fail
    mov     r13, rax                        ; r13 = base destination pointer

    mov     rdi, r13
    xor     r14, r14                        ; Reset loop counter for copy pass

    copy_loop:
        cmp     r14, r12
        jge     copy_done

        cmp     r14, 0
        je      copy_arg_0
        cmp     r14, 1
        je      copy_arg_1
        cmp     r14, 2
        je      copy_arg_2
        cmp     r14, 3
        je      copy_arg_3
        cmp     r14, 4
        je      copy_arg_4

        mov     rax, r14
        sub     rax, 5
        shl     rax, 3
        mov     rbx, qword ptr [rbp + 16 + rax]
        jmp     copy_got_string

    copy_arg_0:
        mov     rbx, qword ptr [rbp - 40]
        jmp     copy_got_string
    copy_arg_1:
        mov     rbx, qword ptr [rbp - 48]
        jmp     copy_got_string    
    copy_arg_2:
        mov     rbx, qword ptr [rbp - 56]
        jmp     copy_got_string      
    copy_arg_3:
        mov     rbx, qword ptr [rbp - 64]
        jmp     copy_got_string 
    copy_arg_4:
        mov     rbx, qword ptr [rbp - 72]    

    copy_got_string:
        test    rbx, rbx
        jz      copy_next

        push    rdi
        mov     rdi, rbx
        call    LEN
        mov     rcx, rax
        mov     rsi, rbx
        pop     rdi

        cld
        rep     movsb

    copy_next:
        inc     r14
        jmp     copy_loop

    copy_done:
        mov     byte ptr [rdi], 0
        mov     rax, r13
        jmp     join_exit

    join_empty:
        lea     rax, [szEmpty]
        jmp     join_exit

    join_fail:
        xor     rax, rax

    join_exit:
        add     rsp, 48
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbx
        leave
        ret
JOIN$ endp
end