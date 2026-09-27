OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; LPAD$
;   Pads a string with a specified character to a given length from the left.
;
; Parameters:
;   srcString:ptr - Pointer to the null-terminated string to be padded.
;   fillCount:qword - Number of characters by which the string should be padded.
;   fillChar:byte - Character used for padding.
;
; Returns:
;   rax = Pointer to a newly allocated string containing the left-padded string,
;         or null if an error occurs during allocation.
;==============================================================================

PUBLIC LPAD$
LPAD$ PROC USES rbx r12 r13 r14 r15 srcString:ptr, fillCount:qword, fillChar:byte
    local src_ptr:qword
    local pad_cnt:qword
    local fill_char:byte
    local src_len:qword
    local total_size:qword
    local new_str:qword

    mov       src_ptr, srcString              ; rbx = source string pointer (s)
    mov       rbx, srcString
    mov       pad_cnt, fillCount              ; r12 = pad_count
    mov       r12, fillCount
    mov       dl, fillChar
    mov       fill_char, dl             ; r13b = fill character
    mov       r13b, dl

    ; --- 1. Safely measure source string length via null-terminator scan ---
    test      rbx, rbx
    jz        lpad_source_empty

    xor       r14, r14                  ; r14 = source length counter
meas_loop:
    mov       al, byte ptr [rbx + r14]
    test      al, al
    jz        lpad_calc_total
    inc       r14
    jmp       meas_loop

lpad_source_empty:
    xor       r14, r14                  ; len = 0

lpad_calc_total:
    mov       src_len, r14
    ; Total allocation size = source_len + pad_count + 1 for NUL terminator
    mov       r15, r14
    mov       rax, pad_cnt
    add       r15, rax                  
    inc       r15                       ; Account for NUL terminator
    mov       total_size, r15

    ; --- 2. Allocate space via arena_alloc ---
    mov       rdi, r15                  ; length including NUL
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        lpad_exit
    mov       new_str, rax              ; r8 = new destination arena payload pointer
    mov       r8, rax

    mov       rcx, total_size
    dec       rcx                       ; Exclude NUL from count checks
    jz        lpad_terminate

    ; --- 3. Prepend fill characters ---
    mov       rax, pad_cnt
    test      rax, rax
    jle       lpad_copy_source          ; Skip if pad_count <= 0

    xor       rcx, rcx                  ; index = 0
lpad_fill_loop:
    mov       rax, pad_cnt
    cmp       rcx, rax
    jge       lpad_copy_source
    mov       al, fill_char
    mov       byte ptr [r8 + rcx], al
    inc       rcx
    jmp       lpad_fill_loop

lpad_copy_source:
    ; --- 4. Copy original source string after the fill characters ---
    mov       rax, src_len
    test      rax, rax
    jz        lpad_terminate            ; Skip if source length is 0

    xor       rsi, rsi                  ; source index = 0
lpad_copy_loop:
    mov       rax, src_len
    cmp       rsi, rax
    jge       lpad_terminate

    mov       rax, pad_cnt              ; destination offset = pad_count + source_index
    add       rax, rsi
    mov       rdx, src_ptr
    mov       dl, byte ptr [rdx + rsi]
    mov       byte ptr [r8 + rax], dl

    inc       rsi
    jmp       lpad_copy_loop

lpad_terminate:
    ; Ensure null-termination at the very end of the total size
    mov       rax, src_len
    add       rax, pad_cnt
    mov       byte ptr [r8 + rax], 0

    mov       rax, new_str              ; Return new arena string pointer

lpad_exit:
    ret
LPAD$ ENDP

END
