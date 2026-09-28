OPTION LITERALS:ON
option casemap:none
option frame:auto

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

extern STR$:proto :QWORD
extern puts:proto :PTR


.code

;
;==============================================================================
; putn
;   Prints a number to standard output.
;
; Parameters:
;   num (QWORD): The numeric value to be printed.
;
; Returns:
;   None
;
; Notes:
;   This procedure converts the provided QWORD integer to its string representation 
;   using the STR$() function, then prints this string to the standard output 
;   using the puts() function.
;
;==============================================================================

PUBLIC putn
putn PROC USES rbx num:QWORD
    ; Generate arena-allocated string representation using STR$()
    invoke  STR$, num
    mov     rbx, rax            ; Save the pointer

    ; Print the string to stdout
    invoke  puts, rbx

    ret
putn endp

END