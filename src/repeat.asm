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
; REPEAT$
;   Repeats a given pattern 'count' times.
;
; Parameters:
;   count (qword): The number of times to repeat the pattern.
;   pattern (ptr): The substring to be repeated.
;
; Returns:
;   rax: Pointer to a null-terminated string containing the repeated pattern.
;         If an error occurs or 'count' is less than or equal to 0, returns NULL.
;==============================================================================

PUBLIC REPEAT$
REPEAT$ PROC USES rbx r12 r13 r14 r15 count:qword, pattern:ptr
    local rep_count:qword
    local pattern_ptr:qword
    local pattern_len:qword
    local total_len:qword
    local new_str:qword

    mov       rep_count, count            ; r12 = count
    mov       r12, count
    mov       pattern_ptr, pattern          ; r13 = pattern pointer
    mov       r13, pattern

    ; If count <= 0 or pattern is null, return empty string (1 byte null terminator)
    mov       rax, rep_count
    test      rax, rax
    jle       repeat_empty
    mov       rax, pattern_ptr
    test      rax, rax
    jz        repeat_empty

    ; --- 1. Calculate pattern length ---
    xor       rax, rax
    mov       rbx, pattern_ptr
len_loop:
    mov       dl, byte ptr [rbx]
    test      dl, dl
    jz        len_done
    inc       rax
    inc       rbx
    jmp       len_loop
len_done:
    mov       pattern_len, rax          ; r14 = pattern length
    mov       r14, rax
    test      r14, r14
    jz        repeat_empty

    ; --- 2. Calculate total output length (count * pattern_length) ---
    mov       rax, rep_count
    mov       rcx, pattern_len
    imul      rax, rcx                  ; rax = total payload length
    mov       total_len, rax            ; r15 = total length
    mov       r15, rax

    ; --- 3. Allocate Space via arena_alloc (total_len + 1 for NUL) ---
    mov       rax, total_len
    inc       rax                       ; add 1 for NUL terminator
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        repeat_fail
    mov       new_str, rax
    mov       rbx, rax                  ; rbx = destination payload pointer

    ; --- 4. Copy pattern 'count' times ---
    mov       rdi, rbx                  ; Destination payload pointer

repeat_copy_loop:
    mov       rax, rep_count
    test      rax, rax
    jz        repeat_done

    mov       rsi, pattern_ptr          ; Source pattern pointer
    mov       rcx, pattern_len          ; Length of pattern
    rep       movsb                     ; Copy pattern block

    mov       rax, rep_count
    dec       rax
    mov       rep_count, rax
    jmp       repeat_copy_loop

repeat_done:
    ; Null-terminate the string
    mov       byte ptr [rdi], 0

    ; --- 5. Return Destination Pointer ---
    mov       rax, new_str
    jmp       repeat_exit

repeat_empty:
    ; Allocate 1 byte for empty string (just NUL)
    mov       rdi, 1
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        repeat_fail
    mov       byte ptr [rax], 0
    jmp       repeat_exit

repeat_fail:
    xor       rax, rax                  ; Return NULL on allocation failure

repeat_exit:
    ret
REPEAT$ ENDP

END