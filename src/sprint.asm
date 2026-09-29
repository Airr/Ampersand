OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn g_argv        :qword
extrn g_argc        :qword
extrn szEmpty       :byte

extrn LEN           :proto :ptr
extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword 
extrn STR$          :proto :QWORD
extrn HEX$          :proto :QWORD

PRINT_BUFSIZE       equ 4096

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; SPRINT
;   Formats a string using printf-style formatting and stores the result in an 
;   arena-allocated buffer.
;
; Parameters:
;   fmt (ptr): A null-terminated format string. Supported specifiers are:
;     %c - character
;     %% - literal '%'
;     %s - string
;     %d - signed decimal integer
;     %u - unsigned decimal integer
;     %x - hexadecimal integer (lowercase)
;
;   ...: Variable arguments corresponding to placeholders in fmt.
;
; Returns:
;   rax: Pointer to the formatted string stored in the arena, or NULL if allocation fails.
;==============================================================================


PUBLIC SPRINT
SPRINT PROC USES rbx rbp r12 r13 r14 r15 fmt:PTR, args:VARARG

    LOCAL arg_array[8]:QWORD
    LOCAL outBuf[PRINT_BUFSIZE]:byte   ; scratch buffer while sizing/building

    ; --------------------------------------------------------------------------
    ; Capture incoming register arguments into a contiguous array.
    ; --------------------------------------------------------------------------
    MOV     arg_array[0],  rsi
    MOV     arg_array[8],  rdx
    MOV     arg_array[16], rcx
    MOV     arg_array[24], r8
    MOV     arg_array[32], r9

    ; --------------------------------------------------------------------------
    ; Register usage:
    ;   r13 = format string cursor
    ;   r14 = current output position (into outBuf)
    ;   r15 = current argument slot (into arg_array)
    ; --------------------------------------------------------------------------
    MOV     r13, fmt
    LEA     r14, outBuf
    LEA     r15, arg_array

sp_loop:
    MOV     al, [r13]
    CMP     al, 0
    JE      sp_done

    CMP     al, '%'
    JE      sp_handlearg

    ; Normal character: copy through.
    MOV     [r14], al
    INC     r14
    INC     r13
    JMP     sp_loop

sp_handlearg:
    INC     r13
    MOV     al, [r13]

    .if al == 'c'
        JMP sp_handle_char
    .elseif al == '%'
        JMP sp_handle_percent
    .elseif al == 's'
        JMP sp_handle_string
    .elseif al == 'd' || al == 'u'
        JMP sp_handle_decimal
    .elseif al == 'x'
        JMP sp_handle_hex
    .else
        JMP sp_unsupported
    .endif

sp_handle_decimal:
    MOV     rdi, [r15]
    INVOKE  STR$, rdi
    MOV     rsi, rax
    JMP     sp_append_string

sp_handle_hex:
    MOV     rdi, [r15]
    INVOKE  HEX$, rdi
    MOV     rsi, rax
    JMP     sp_append_string

sp_handle_string:
    MOV     rsi, [r15]
    JMP     sp_append_string

sp_append_string:
    MOV     al, [rsi]
    CMP     al, 0
    JE      sp_append_string_done

    MOV     [r14], al
    INC     r14
    INC     rsi
    JMP     sp_append_string

sp_append_string_done:
    ADD     r15, 8
    INC     r13
    JMP     sp_loop

sp_handle_percent:
    MOV     BYTE PTR [r14], '%'
    INC     r14
    INC     r13
    JMP     sp_loop

sp_handle_char:
    MOV     al, [r15]
    MOV     [r14], al
    INC     r14
    INC     r13
    ADD     r15, 8
    JMP     sp_loop

sp_unsupported:
    INC     r13
    JMP     sp_loop

sp_done:
    MOV     BYTE PTR [r14], 0       ; NUL-terminate the built string

    ; --------------------------------------------------------------------------
    ; Copy outBuf into a right-sized arena allocation.
    ; --------------------------------------------------------------------------
    LEA     rbx, outBuf
    MOV     r12, r14                ; r12 = end of written data
    SUB     r12, rbx                ; r12 = length (excluding NUL)

    LEA     rdi, [r12 + 1]          ; length + NUL
    LEA     rsi, qword ptr [arena]
    CALL    arena_alloc
    TEST    rax, rax
    JZ      sp_alloc_failed

    MOV     rdi, rax                ; dest
    MOV     rsi, rbx                ; source = outBuf
    MOV     rcx, r12                ; length
    CLD
    REP     MOVSB

    MOV     BYTE PTR [rdi], 0
    ; rax already holds the arena pointer (arena_alloc's return value,
    ; untouched by rep movsb since it USES rdi, not rax)
    JMP     sp_return

sp_alloc_failed:
    XOR     eax, eax

sp_return:
    RET

SPRINT ENDP

end
