OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

extrn ALLOC :proto :qword
extrn LEN   :proto :ptr
.code

;
;==============================================================================
; SCOPY
;   Copies a null-terminated string into another buffer.
;
; Parameters:
;   src (ptr): The source string to be copied.
;
; Returns:
;   rax: Pointer to a newly allocated buffer containing the copy of the source 
;        string. If an error occurs or 'src' is NULL, returns NULL.
==============================================================================

PUBLIC SCOPY
SCOPY PROC USES rbx r12 r13, src:ptr
    mov     r12, src            ; src survives the calls below
    mov     r13, LEN(r12)
    inc     r13                 ; length + NUL

    mov     rbx, ALLOC(r13)     ; dest buffer from the arena
    .if rbx == 0                ; ALLOC can fail
        xor eax, eax
        ret
    .endif

    mov     rdi, rbx            ; dest buffer
    mov     rsi, r12            ; source to copy
    mov     rcx, r13            ; size of source
    cld                         ; clear the direction flag (move forward)
    rep     movsb               ; copy from source to dest

    mov     rax, rbx            ; return dest pointer
    ret
SCOPY endp

end