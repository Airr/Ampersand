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

;==============================================================================
; SPRINT
;
; fmt  = format string
;
; Register-passed variadic arguments (same convention as PRINT):
;   RSI = argument 1
;   RDX = argument 2
;   RCX = argument 3
;   R8  = argument 4
;   R9  = argument 5
;
; Supports the same specifiers as PRINT: %c %% %s %d %u %x
; Literal text in the format string is copied through unchanged, exactly
; as PRINT would write it to stdout - SPRINT instead builds it into a new
; arena-allocated string.
;
; Additional stack-passed arguments are not currently handled (same
; limitation as PRINT).
;
; Returns:
;   rax = pointer to the new arena-allocated string, or 0 if arena_alloc
;         fails.
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

    .SWITCH al

        .CASE 'c'
            JMP sp_handle_char

        .CASE '%'
            JMP sp_handle_percent

        .CASE 's'
            JMP sp_handle_string

        .CASE 'd', 'u'
            JMP sp_handle_decimal

        .CASE 'x'
            JMP sp_handle_hex

        .DEFAULT
            JMP sp_unsupported

    .ENDSWITCH

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
