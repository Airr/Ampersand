OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn LEN           :proto

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; MID$
;   Extracts a substring from a source string, starting at a given index and of 
;   a specified length.
;
; Parameters:
;   srcString:ptr - Pointer to the null-terminated source string 
;                   from which to extract.
;   index:qword   - The starting index of the substring in the source string.
;   numBytes:qword- The number of bytes (characters) to include in 
;                   the extracted substring.
;
; Returns:
;   rax = Pointer to a newly allocated string containing the extracted substring,
;         or null if an error occurs during allocation or if the input parameters 
;         are invalid.
;==============================================================================

PUBLIC MID$
MID$ PROC USES rbx r12 r13 r14 r15 srcString:ptr, index:qword, numBytes:qword
    local src_str:qword
    local start_idx:qword
    local req_len:qword
    local cur_len:qword
    local new_str:qword

    mov       src_str, rdi              ; rbx = source s (payload pointer)
    mov       rbx, rdi
    mov       start_idx, rsi            ; r12 = start index
    mov       r12, rsi
    mov       req_len, rdx              ; r13 = requested length
    mov       r13, rdx

    ; --- 1. Get current string length ---
    call      LEN                    
    mov       cur_len, rax              ; r14 = cur_len
    mov       r14, rax

    ; --- 2. Bounds checking ---
    mov       rax, start_idx
    cmp       rax, cur_len
    jge       mid_empty_result
    mov       rax, req_len
    test      rax, rax
    jle       mid_empty_result
    mov       rax, cur_len
    test      rax, rax
    jz        mid_empty_result

    ; Adjust length if start + length exceeds cur_len
    mov       rax, start_idx
    add       rax, req_len              ; rax = start + length
    cmp       rax, cur_len
    jle       mid_calc_source

    ; If it exceeds, clamp length: length = cur_len - start
    mov       rax, cur_len
    sub       rax, start_idx            ; r13 = adjusted length
    mov       req_len, rax
    mov       r13, rax

mid_calc_source:
    ; --- 3. Allocate space via arena_alloc (req_len bytes + 1 for NUL terminator) ---
    mov       rax, req_len
    inc       rax
    mov       rdi, rax                  ; length including NUL
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        mid_exit
    mov       new_str, rax              ; r15 = new destination arena payload pointer
    mov       r15, rax

    ; --- 4. Copy characters from source substring position ---
    mov       rax, src_str
    add       rax, start_idx            ; source position = s + start_idx
    mov       r8, rax

    xor       rcx, rcx                  ; index counter = 0

mid_copy_loop:
    mov       rax, req_len
    cmp       rcx, rax
    jge       mid_terminate

    mov       al, byte ptr [r8 + rcx]
    mov       byte ptr [r15 + rcx], al

    inc       rcx
    jmp       mid_copy_loop

mid_empty_result:
    ; Allocate an empty arena string (just NUL terminator)
    mov       rdi, 1                    ; 1 byte for NUL
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        mid_exit
    mov       new_str, rax
    mov       r15, rax
    ; xor       req_len, req_len          ; len = 0 for termination index
    mov       req_len, 0

mid_terminate:
    ; Ensure null-termination at the end of the extracted substring
    mov       rax, req_len
    mov       byte ptr [r15 + rax], 0
    mov       rax, new_str              ; Return pointer to new arena string payload

mid_exit:
    ret
MID$ ENDP


END
