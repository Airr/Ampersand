OPTION LITERALS:ON
option casemap:none
option frame:auto

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

extern STR$:proto :QWORD
extern puts:proto :PTR


.code

PUBLIC putn
putn PROC USES rbx num:QWORD
    ; Generate arena-allocated string representation using itoa
    invoke  STR$, num
    mov     rbx, rax            ; Save the pointer

    ; Print the string to stdout
    invoke  puts, rbx

    ret
putn endp

END