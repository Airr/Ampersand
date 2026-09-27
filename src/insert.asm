OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn szEmpty       :byte

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; char* INSERT$(const char* s, int64_t pos, const char* substr)
; Returns a newly allocated arena string with 'substr' inserted into 's' at 'pos'.
; Note: 1-based indexing for BASIC compatibility. If pos <= 1, inserts at start.
; If pos > len(s), appends at the end.
; Input:  rdi = pointer to source string payload (s)
;         rsi = position (INTEGER / int64_t, 1-based)
;         rdx = pointer to substring payload (substr)
; Output: rax = pointer to new arena string payload
; -----------------------------------------------------------------------------
PUBLIC INSERT$

INSERT$ PROC USES rbx r12 r13 r14 r15 src:ptr, position:qword, substring:ptr
    local total_len:qword
    local insert_idx:qword
    local src_len:qword
    local sub_len:qword
    local new_str:qword

    mov       rbx, src                  ; rbx = source string 
    mov       r12, position             ; r12 = position
    mov       r13, substring            ; r13 = substring pointer

    ; --- 1. Get lengths of both strings ---
    xor       r14, r14                  ; r14 = len(s) = 0
    test      rbx, rbx
    jz        ins_get_substr_len
    
    ; Compute len(s) manually
    mov       rdi, rbx
    xor       rcx, rcx
src_len_loop:
    cmp       byte ptr [rdi + rcx], 0
    je        src_len_done
    inc       rcx
    jmp       src_len_loop
src_len_done:
    mov       r14, rcx                  ; r14 = len(s)

ins_get_substr_len:
    mov       src_len, r14
    xor       r15, r15                  ; r15 = len(substr) = 0
    test      r13, r13
    jz        ins_calc_total
    
    ; Compute len(substr) manually
    mov       rdi, r13
    xor       rcx, rcx
sub_len_loop:
    cmp       byte ptr [rdi + rcx], 0
    je        sub_len_done
    inc       rcx
    jmp       sub_len_loop
sub_len_done:
    mov       r15, rcx                  ; r15 = len(substr)

ins_calc_total:
    mov       sub_len, r15
    ; Total length = len(s) + len(substr) + 1 (for NUL)
    mov       rcx, r14
    add       rcx, r15                  
    inc       rcx                       ; Include space for NUL terminator
    mov       total_len, rcx

    ; --- 2. Allocate from Arena ---
    mov       rdi, rcx
    lea       rsi, [arena]
    call      arena_alloc

    test      rax, rax
    jz        ins_exit
    mov       new_str, rax              ; new_str = new destination arena payload pointer
    mov       r8, rax

    mov       rcx, total_len
    dec       rcx                       ; Exclude NUL for empty check
    test      rcx, rcx
    jz        ins_terminate_only        ; Both empty, just put NUL and return

    ; --- 3. Determine insertion index (convert 1-based to 0-based offset) ---
    dec       r12                       ; convert to 0-based
    test      r12, r12
    jns       ins_check_max_pos
    xor       r12, r12                  ; clamp to 0 if negative/1
ins_check_max_pos:
    mov       rax, src_len
    cmp       r12, rax
    jle       ins_do_copy
    mov       r12, rax                  ; clamp to len(s) if beyond end

ins_do_copy:
    mov       insert_idx, r12

    ; --- 4. Copy parts into new string ---
    xor       r9, r9                    ; source index = 0
    xor       r10, r10                  ; destination index = 0

    ; Copy first part of source
ins_copy_part1:
    mov       rax, insert_idx
    cmp       r9, rax
    jge       ins_copy_substr
    mov       al, byte ptr [rbx + r9]
    mov       byte ptr [r8 + r10], al
    inc       r9
    inc       r10
    jmp       ins_copy_part1

ins_copy_substr:
    ; Copy entire substring
    xor       r11, r11                  ; substr index = 0
ins_copy_substr_loop:
    mov       rax, sub_len
    cmp       r11, rax
    jge       ins_copy_part2
    mov       al, byte ptr [r13 + r11]
    mov       byte ptr [r8 + r10], al
    inc       r11
    inc       r10
    jmp       ins_copy_substr_loop

ins_copy_part2:
    ; Copy remainder of source from insert_idx to end
ins_copy_part2_loop:
    mov       rax, src_len
    cmp       r9, rax
    jge       ins_success
    mov       al, byte ptr [rbx + r9]
    mov       byte ptr [r8 + r10], al
    inc       r9
    inc       r10
    jmp       ins_copy_part2_loop

ins_terminate_only:
    mov       byte ptr [r8], 0
    mov       rax, new_str
    jmp       ins_exit

ins_success:
    mov       byte ptr [r8 + r10], 0    ; Null-terminate payload
    mov       rax, new_str              ; Return pointer to new arena payload

ins_exit:
    ret
INSERT$ ENDP

END