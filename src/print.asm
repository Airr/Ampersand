;
;==============================================================================
; PRINT
;   Outputs formatted text to standard output.
;
; Parameters:
;   fmt (pointer): A null-terminated format string specifying the output format.
;   ...: Variable arguments corresponding to the placeholders in the format string.
;
; Returns:
;   None
;
; Supports:
;   %c   character
;   %%   literal %
;   %s   string
;   %d   decimal
;   %u   unsigned decimal
;   %x   hexadecimal
;
;==============================================================================


OPTION LITERALS:ON
option casemap:none
option frame:auto

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

extrn STR$    :proto :QWORD
extrn HEX$    :proto :QWORD


; ==============================================================================
; Constants
; ==============================================================================

SYS_WRITE       equ 1
STDOUT_FD       equ 1
PRINT_BUFSIZE   equ 65536


; ==============================================================================
; Static output buffer
; ==============================================================================

.data?

    print_buf   DB PRINT_BUFSIZE DUP(?)


.code


; ==============================================================================
; pf_flush
;
; Flush the current contents of print_buf.
;
; R14 = current end of data in print_buf
;
; R14 is reset to the beginning of print_buf after the flush.
; ==============================================================================

pf_flush PROC

    ; --------------------------------------------------------------------------
    ; RDI = buffer
    ; RDX = length
    ; --------------------------------------------------------------------------

    LEA     rsi, [print_buf]

    MOV     rdx, r14
    SUB     rdx, rsi

    TEST    rdx, rdx
    JZ      pf_flush_reset


    ; --------------------------------------------------------------------------
    ; write(1, print_buf, length)
    ; --------------------------------------------------------------------------

    MOV     rax, SYS_WRITE
    MOV     rdi, STDOUT_FD

    SYSCALL


pf_flush_reset:

    LEA     r14, [print_buf]

    RET

pf_flush ENDP


; ==============================================================================
; pf_check_buffer
;
; Ensures there is room for at least one more byte.
;
; R14 = current output position
;
; IMPORTANT:
; This routine deliberately does NOT modify AL.
; The formatter can therefore safely use AL around this call.
; ==============================================================================

pf_check_buffer PROC

    ; Use RCX for the end address instead of RAX/AL.

    LEA     rcx, [print_buf + PRINT_BUFSIZE]

    CMP     r14, rcx
    JB      pf_check_done


    ; Buffer is full.

    CALL    pf_flush


pf_check_done:

    RET

pf_check_buffer ENDP


; ==============================================================================
; PRINT
;
; fmt  = format string
;
; Register-passed variadic arguments:
;
;   RSI = argument 1
;   RDX = argument 2
;   RCX = argument 3
;   R8  = argument 4
;   R9  = argument 5
;
; Additional stack-passed arguments are not currently handled.
; ==============================================================================

;
;==============================================================================
; PRINT
;   Outputs formatted text to standard output.
;
; Parameters:
;   fmt (pointer): A null-terminated format string specifying the output format.
;   ...: Variable arguments corresponding to the placeholders in the format string.
;
; Returns:
;   None
;
; Notes:
;   The function uses a buffer (print_buf) to store formatted text before writing it
;   to standard output. It supports various format specifiers including %d for integers,
;   %u for unsigned integers, %x for hexadecimal values, %s for strings, and %% for the literal "%".
;
;   For unsupported format specifiers or errors during formatting, the function simply ignores them.
;   The buffer is flushed to standard output at the end of the formatted text.
;
;==============================================================================

PUBLIC PRINT
PRINT PROC USES rbp r13 r14 r15 fmt:PTR, args:VARARG

    LOCAL arg_array[8]:QWORD


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
    ;
    ; R13 = format string
    ; R14 = current output position
    ; R15 = current argument
    ; --------------------------------------------------------------------------

    MOV     r13, fmt

    LEA     r14, [print_buf]
    LEA     r15, [arg_array]


; ==============================================================================
; Main format loop
; ==============================================================================

pf_loop:

    MOV     al, [r13]

    CMP     al, 0
    JE      pf_done

    CMP     al, '%'
    JE      pf_handlearg


    ; --------------------------------------------------------------------------
    ; Normal character
    ;
    ; Check the buffer FIRST because pf_check_buffer may modify registers.
    ; Then reload AL from the format string.
    ; --------------------------------------------------------------------------

    CALL    pf_check_buffer

    MOV     al, [r13]
    MOV     [r14], al

    INC     r14
    INC     r13

    JMP     pf_loop


; ==============================================================================
; Format specifier
; ==============================================================================

pf_handlearg:

    INC     r13

    MOV     al, [r13]

    .if al == 'c'
        JMP pf_handle_char
    .elseif al == '%'
        JMP pf_handle_percent
    .elseif al == 's'
        JMP pf_handle_string
    .elseif al == 'd' || al == 'u'
        JMP pf_handle_decimal
    .elseif al == 'x'
        JMP pf_handle_hex
    .else
        JMP pf_unsupported
    .endif


; ==============================================================================
; %d / %u
; ==============================================================================

pf_handle_decimal:

    MOV     rdi, [r15]

    INVOKE  STR$, rdi

    MOV     rsi, rax

    JMP     pf_append_string


; ==============================================================================
; %x
; ==============================================================================

pf_handle_hex:

    MOV     rdi, [r15]

    INVOKE  HEX$, rdi

    MOV     rsi, rax

    JMP     pf_append_string


; ==============================================================================
; %s
; ==============================================================================

pf_handle_string:

    MOV     rsi, [r15]

    JMP     pf_append_string


; ==============================================================================
; Append NUL-terminated string
;
; RSI = source string
; ==============================================================================

pf_append_string:

    MOV     al, [rsi]

    CMP     al, 0
    JE      pf_append_string_done


    ; Check buffer BEFORE loading the byte that will be written.

    CALL    pf_check_buffer

    MOV     al, [rsi]
    MOV     [r14], al

    INC     r14
    INC     rsi

    JMP     pf_append_string


pf_append_string_done:

    ADD     r15, 8

    INC     r13

    JMP     pf_loop


; ==============================================================================
; %%
; ==============================================================================

pf_handle_percent:

    CALL    pf_check_buffer

    MOV     BYTE PTR [r14], '%'

    INC     r14
    INC     r13

    JMP     pf_loop


; ==============================================================================
; %c
; ==============================================================================

pf_handle_char:

    CALL    pf_check_buffer

    MOV     al, [r15]
    MOV     [r14], al

    INC     r14
    INC     r13

    ADD     r15, 8

    JMP     pf_loop


; ==============================================================================
; Unsupported format
; ==============================================================================

pf_unsupported:

    INC     r13

    JMP     pf_loop


; ==============================================================================
; Finished formatting
; ==============================================================================

pf_done:

    ; Flush anything remaining in the buffer.

    CALL    pf_flush

    RET

PRINT ENDP


END