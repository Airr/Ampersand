OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
EXTERN LEN          :PROC

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; Name:         TRIM$
; Description:  Returns a newly arena-allocated string with leading and trailing spaces 
;               removed, and multiple consecutive spaces between words reduced to a 
;               single space, using an external LEN   module with zero libc dependencies.
; C Prototype:  char* TRIM$(const char* s);
; Parameters:   rdi = pointer to source null-terminated string (s)
; Returns:      rax = pointer to new arena-allocated string payload
; -----------------------------------------------------------------------------
PUBLIC TRIM$

TRIM$ PROC USES rbx r12 r13 r14 r15 srcString:ptr
    local src_ptr:qword
    local src_len:qword
    local final_len:qword
    local dest_ptr:qword

    mov       src_ptr, srcString
    mov       r12, srcString

    ; --- 1. Validate input and compute length via external LEN   ---
    test      r12, r12
    jz        trim_allocate_empty

    call      LEN                        ; returns length in rax
    mov       src_len, rax
    cmp       src_len, 0
    jle       trim_allocate_empty

    ; --- 2. Find first non-space character (skip leading spaces) ---
    mov       rdi, src_ptr              ; rdi = scan pointer from start
    mov       rsi, src_ptr
    add       rsi, src_len              ; rsi = end boundary (s + len)

trim_skip_leading:
    cmp       rdi, rsi
    jge       trim_allocate_empty       ; String is all spaces

    mov       al, byte ptr [rdi]
    cmp       al, 32                    ; ASCII space
    jne       trim_found_start
    inc       rdi
    jmp       trim_skip_leading

trim_found_start:
    mov       r12, rdi                  ; r12 = pointer to first non-space character

    ; --- 3. Find last non-space character (skip trailing spaces) ---
    mov       rdi, rsi                  
    dec       rdi                       ; rdi = pointer to last character

trim_skip_trailing:
    cmp       rdi, r12
    jl        trim_allocate_empty       ; Should not happen if leading pass succeeded

    mov       al, byte ptr [rdi]
    cmp       al, 32
    jne       trim_found_end
    dec       rdi
    jmp       trim_skip_trailing

trim_found_end:
    mov       r13, rdi                  ; r13 = pointer to last non-space character

    ; --- 4. Calculate exact final length (collapsing internal spaces) ---
    xor       rcx, rcx                  ; final length counter = 0
    mov       rdi, r12                  ; scan pointer starting from valid text start

trim_calc_len_loop:
    cmp       rdi, r13
    jg        trim_calc_done

    mov       al, byte ptr [rdi]
    cmp       al, 32
    jne       trim_calc_regular

    ; It's a space: count it as 1, then skip all subsequent consecutive spaces
    inc       rcx
trim_skip_internal_spaces:
    inc       rdi
    cmp       rdi, r13
    jg        trim_calc_done
    mov       al, byte ptr [rdi]
    cmp       al, 32
    je        trim_skip_internal_spaces
    jmp       trim_calc_len_loop

trim_calc_regular:
    inc       rcx
    inc       rdi
    jmp       trim_calc_len_loop

trim_calc_done:
    mov       final_len, rcx            ; exact final length needed

    ; --- 5. Allocate brand new string via arena_alloc (final_len + 1 for NUL) ---
    mov       rdi, final_len
    inc       rdi                       ; include space for null terminator
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        trim_exit                 ; Return NULL if allocation failed
    mov       dest_ptr, rax
    mov       r8, rax                   ; r8 = destination payload pointer

    cmp       final_len, 0
    je        trim_success_empty

    ; --- 6. Copy and collapse spaces into the new arena buffer ---
    mov       rdi, r12                  ; source read pointer (starts at first non-space)
    xor       rdx, rdx                  ; destination write index = 0

trim_copy_loop:
    cmp       rdi, r13
    jg        trim_success

    mov       al, byte ptr [rdi]
    cmp       al, 32
    jne       trim_copy_regular

    ; Write single space
    mov       byte ptr [r8 + rdx], 32
    inc       rdx

    ; Skip all consecutive spaces in source
trim_skip_source_spaces:
    inc       rdi
    cmp       rdi, r13
    jg        trim_success
    mov       al, byte ptr [rdi]
    cmp       al, 32
    je        trim_skip_source_spaces
    jmp       trim_copy_loop

trim_copy_regular:
    mov       byte ptr [r8 + rdx], al
    inc       rdx
    inc       rdi
    jmp       trim_copy_loop

trim_allocate_empty:
    ; Allocate 1 byte for null terminator
    mov       rdi, 1
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        trim_exit
    mov       dest_ptr, rax
    mov       r8, rax

trim_success_empty:
    mov       r8, dest_ptr

trim_success:
    mov       rax, dest_ptr
    mov       rcx, final_len
    mov       byte ptr [rax + rcx], 0   ; Ensure null termination

trim_exit:
    ret
TRIM$ ENDP

END