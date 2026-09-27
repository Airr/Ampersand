OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn LEN           :proto :ptr
extrn COMPARE       :proto :ptr, :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; =====================================================================
; Function: ENDSWITH
; Description: Checks if a string ends with a specific suffix string 
;              using pure pointer arithmetic and no leading dot labels.
; Inputs:
;   src - Pointer to the source string
;   arg - Pointer to the suffix argument string
; Returns:
;   rax - 1 if src ends with arg, 0 otherwise
; =====================================================================
PUBLIC ENDSWITH
ENDSWITH PROC USES rbx r12 r13 r14 src:ptr, arg:ptr
    mov rbx, src        ; rbx = src pointer
    mov r14, arg        ; r14 = arg pointer

    ; 1. Get length of src
    mov r12, LEN(rbx)

    ; 2. Get length of arg
    mov r13, LEN(r14)

    ; 3. If arg is longer than src, it cannot end with it
    .if r13 > r12
        xor rax, rax
        ret
    .endif

    ; 4. Calculate tail pointer in src: src + len(src) - len(arg)
    mov rdi, rbx
    add rdi, r12
    sub rdi, r13        ; rdi points to the exact tail slice in src
    mov rsi, r14        ; rsi points to arg

    ; 5. Call strcmp function (rdi = str1, rsi = str2)
    .if COMPARE(rdi, rsi) != 0
        xor rax, rax
        ret
    .endif

    mov rax, 1          ; Match found! Returns 1
    ret

ENDSWITH endp

END
