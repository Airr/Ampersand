OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn LEN           :proto :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; Name:         RPAD$
; Description:  Returns a newly allocated arena string with 'fill_char' appended 
;               'count' times to the right side of 's', using external LEN  .
; C Prototype:  char* RPAD$(const char* s, int64_t count, char fill_char);
; Parameters:   rdi = pointer to source string (s)
;               rsi = count of padding characters to append (int64_t)
;               rdx = fill character (byte, passed in dl)
; Returns:      rax = pointer to new arena-allocated string
; -----------------------------------------------------------------------------
PUBLIC RPAD$

RPAD$ PROC USES rbx r12 r13 r14 r15 src:ptr, count:qword, fillChar:byte
    local src_str:qword
    local fill_count:qword
    local fill_byte:byte
    local src_len:qword
    local total_len:qword
    local dest_ptr:qword

    mov       src_str, src
    mov       rbx, src                  ; rbx = source string s
    mov       fill_count, count         
    mov       r12, count                ; r12 = count of fill chars
    mov       al, fillChar                 
    mov       fill_byte, fillChar
    mov       r13b, al                  ; r13b = fill character

    ; --- 1. Get current string length using external LEN    ---
    test      rbx, rbx
    jz        rpad_source_empty
    
    ; call      LEN                       ; rdi already contains source pointer
    LEN(src_str)
    mov       src_len, rax
    mov       r14, rax                  ; r14 = len(s)
    jmp       rpad_calc_total

rpad_source_empty:
    xor       r14, r14                  ; len(s) = 0
    mov       src_len, 0

rpad_calc_total:
    ; Handle negative or zero count safely
    test      r12, r12
    jle       rpad_count_zero

    mov       r15, r14                  
    add       r15, r12                  ; r15 = total length (len(s) + count)
    jmp       rpad_do_allocate

rpad_count_zero:
    mov       r15, r14                  ; total length = len(s)

rpad_do_allocate:
    mov       total_len, r15

    ; --- 2. Allocate Space via arena_alloc (total_len + 1 for NUL) ---
    mov       rax, total_len
    inc       rax                       ; add 1 for NUL terminator
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        rpad_exit
    mov       dest_ptr, rax
    mov       r8, rax                   ; r8 = new destination pointer

    ; If total length is 0, just null-terminate and finish
    test      r15, r15
    jz        rpad_success_empty

    ; --- 3. Copy original source string entirely ---
    test      r14, r14
    jz        rpad_fill_padding         ; If source was empty, jump straight to padding

    xor       rcx, rcx                  ; index counter = 0
rpad_copy_loop:
    cmp       rcx, r14
    jge       rpad_fill_padding

    mov       al, byte ptr [rbx + rcx]
    mov       byte ptr [r8 + rcx], al

    inc       rcx
    jmp       rpad_copy_loop

rpad_fill_padding:
    ; --- 4. Append fill_char 'count' times starting from original length ---
    test      r12, r12
    jle       rpad_success

    mov       rcx, r14                  ; rcx starts where source string ends
    mov       r9, r15                   ; r9 is the target final length

rpad_fill_loop:
    cmp       rcx, r9
    jge       rpad_success

    mov       byte ptr [r8 + rcx], r13b
    inc       rcx
    jmp       rpad_fill_loop

rpad_success_empty:
    mov       rsi, dest_ptr
    mov       byte ptr [rsi], 0
    jmp       rpad_exit

rpad_success:
    ; Null-terminate the string at total_len
    mov       rdx, total_len
    mov       byte ptr [r8 + rdx], 0
    mov       rax, dest_ptr             ; Return pointer to new string

    jmp       rpad_exit

rpad_exit:
    ret
RPAD$ ENDP

END