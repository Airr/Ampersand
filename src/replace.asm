OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn LEN        :proto :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; REPLACE$
;   Replaces all occurrences of a substring (pattern) within a string with another 
;   substring.
;
; Parameters:
;   src (ptr): The source string in which to replace occurrences of the pattern.
;   pattern (ptr): The substring to be replaced.
;   replaceStr (ptr): The substring to insert as a replacement for each occurrence
;                     of the pattern.
;
; Returns:
;   rax: Pointer to a null-terminated string containing the source string with all 
;        occurrences of the pattern replaced by replaceStr. If an error occurs or no 
;        replacements are made, returns NULL.
;==============================================================================

PUBLIC REPLACE$
REPLACE$ PROC USES rbx r12 r13 r14 r15 src:ptr, pattern:ptr, replaceStr:ptr
    local src_str:qword
    local pat_str:qword
    local rep_str:qword
    local pat_len:qword
    local rep_len:qword
    local src_len:qword
    local final_len:qword
    local dest_ptr:qword

    mov       src_str, src
    mov       r12, src                  ; r12 = source string s
    mov       pat_str, pattern
    mov       r13, pattern              ; r13 = pattern string
    mov       rep_str, replaceStr
    mov       r14, replaceStr            ; r14 = replacement string

    ; Edge case checks
    test      r12, r12
    jz        replace_empty_src
    test      r13, r13
    jz        replace_copy_src

    ; Get lengths using external LEN
    mov       rdi, r13
    call      LEN
    mov       pat_len, rax
    mov       r15, rax                  ; r15 = pattern length
    test      r15, r15
    jz        replace_copy_src          ; Empty pattern -> copy src

    mov       rdi, r12
    call      LEN
    mov       src_len, rax

    mov       rdi, r14
    test      rdi, rdi
    jz        rep_len_zero
    call      LEN
    mov       rep_len, rax
    jmp       lengths_done
rep_len_zero:
    mov       rep_len, 0

lengths_done:
    ; --- Pass 1: Compute Exact Result Length ---
    ; We can count occurrences to find the exact destination size needed.
    xor       rcx, rcx                  ; rcx = match count accumulator
    mov       rbx, r12                  ; rbx = scan pointer

count_loop:
    mov       al, byte ptr [rbx]
    test      al, al
    jz        count_done

    ; Check match at rbx
    mov       rsi, pat_str
    mov       rdx, rbx
    mov       r8, pat_len
chk_match_p1:
    test      r8, r8
    jz        matched_p1
    mov       al, byte ptr [rdx]
    test      al, al
    jz        no_match_p1
    mov       ah, byte ptr [rsi]
    cmp       al, ah
    jne       no_match_p1
    inc       rdx
    inc       rsi
    dec       r8
    jmp       chk_match_p1

matched_p1:
    inc       rcx                       ; found a match
    mov       rax, pat_len
    add       rbx, rax                  ; advance past pattern
    jmp       count_loop

no_match_p1:
    inc       rbx                       ; advance by 1
    jmp       count_loop

count_done:
    ; final_len = src_len - (match_count * pat_len) + (match_count * rep_len)
    ; Which is: src_len + match_count * (rep_len - pat_len)
    mov       rax, pat_len
    mov       rdx, rep_len
    sub       rdx, rax                  ; diff = rep_len - pat_len
    
    ; rcx has match_count
    imul      rcx, rdx                  ; rcx = net change in length
    mov       rax, src_len
    add       rax, rcx
    mov       final_len, rax

    ; --- Allocate Space via arena_alloc (final_len + 1 for NUL) ---
    mov       rax, final_len
    inc       rax                       ; add 1 for NUL terminator
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        replace_fail
    mov       dest_ptr, rax

    ; --- Pass 2: Build the Result String ---
    mov       rbx, r12                  ; rbx = scan source pointer
    mov       rdi, dest_ptr             ; rdi = destination write pointer

replace_scan_loop:
    mov       al, byte ptr [rbx]
    test      al, al
    jz        replace_done

    ; Check if pattern matches at current position rbx
    mov       rsi, pat_str
    mov       rdx, rbx
    mov       r8, pat_len

replace_match_check:
    test      r8, r8
    jz        replace_matched

    mov       al, byte ptr [rdx]
    test      al, al
    jz        replace_no_match

    mov       ah, byte ptr [rsi]
    cmp       al, ah
    jne       replace_no_match

    inc       rdx
    inc       rsi
    dec       r8
    jmp       replace_match_check

replace_matched:
    ; Append replacement string
    mov       rsi, rep_str
    test      rsi, rsi
    jz        skip_rep_copy
    mov       rcx, rep_len
    test      rcx, rcx
    jz        skip_rep_copy
copy_rep_loop:
    mov       al, byte ptr [rsi]
    mov       byte ptr [rdi], al
    inc       rsi
    inc       rdi
    dec       rcx
    jnz       copy_rep_loop

skip_rep_copy:
    mov       rax, pat_len
    add       rbx, rax                  ; Advance source pointer by pattern length
    jmp       replace_scan_loop

replace_no_match:
    ; Copy single character
    mov       al, byte ptr [rbx]
    mov       byte ptr [rdi], al
    inc       rdi
    inc       rbx
    jmp       replace_scan_loop

replace_done:
    ; Null-terminate the string
    mov       byte ptr [rdi], 0
    mov       rax, dest_ptr
    jmp       replace_exit

replace_copy_src:
    ; Copy source entirely if pattern is null or empty
    mov       rdi, src_str
    test      rdi, rdi
    jz        replace_empty_src
    call      LEN
    mov       r14, rax                  ; length
    
    lea       rax, [r14 + 1]
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        replace_fail
    mov       dest_ptr, rax

    xor       rcx, rcx
copy_all_loop:
    cmp       rcx, r14
    jge       copy_all_done
    mov       rsi, src_str
    mov       al, byte ptr [rsi + rcx]
    mov       rsi, dest_ptr
    mov       byte ptr [rsi + rcx], al
    inc       rcx
    jmp       copy_all_loop
copy_all_done:
    mov       rsi, dest_ptr
    mov       byte ptr [rsi + r14], 0
    mov       rax, dest_ptr
    jmp       replace_exit

replace_empty_src:
    mov       rdi, 1
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        replace_fail
    mov       byte ptr [rax], 0
    jmp       replace_exit

replace_fail:
    xor       rax, rax

replace_exit:
    ret
REPLACE$ ENDP

END