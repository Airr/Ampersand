OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn LEN           :proto :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; RIGHT$
;   Extracts the specified number of characters from the right end of a string.
;
; Parameters:
;   src (ptr): The source string from which to extract the substring.
;   count (qword): The number of characters to extract from the right side.
;
; Returns:
;   rax: Pointer to a null-terminated string containing the extracted substring. 
;        If an error occurs or 'count' is zero, returns NULL.
==============================================================================

PUBLIC RIGHT$
RIGHT$ PROC USES rbx r12 r13 r14 src:ptr, count:qword
    local src_str:qword
    local req_count:qword
    local dest_str:qword
    local src_len:qword

    mov       src_str, src
    mov       rbx, src                  ; rbx = source string pointer
    mov       req_count, count
    mov       r12, count                ; r12 = requested count

    ; Edge case check for NULL source
    test      rbx, rbx
    jz        right_empty

    ; --- 1. Get current string length using external LEN    ---
    call      LEN                       ; rdi already contains source pointer
    mov       src_len, rax

    ; Clamp req_count to string length if it exceeds it
    cmp       r12, rax
    jbe       right_alloc
    mov       r12, rax                  ; r12 = min(req_count, LEN  )

right_alloc:
    ; --- 2. Allocate Space via arena_alloc (r12 + 1 for NUL) ---
    mov       rax, r12
    inc       rax                       ; add 1 for NUL terminator
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        right_exit
    mov       dest_str, rax
    mov       r13, rax                  ; r13 = new destination payload pointer

    ; If count is 0, just null-terminate and finish
    test      r12, r12
    jz        right_success_empty

    ; Calculate source start offset: src_len - r12
    mov       rax, src_len
    sub       rax, r12                  ; rax = starting index in source
    
    ; --- 3. Copy characters from source offset to new string ---
    xor       rcx, rcx                  ; destination index counter = 0

right_loop:
    cmp       rcx, r12
    jge       right_success

    ; Read from [rbx + start_index + rcx]
    mov       rdx, src_len
    sub       rdx, r12
    add       rdx, rcx
    mov       al, byte ptr [rbx + rdx]
    
    mov       byte ptr [r13 + rcx], al

    inc       rcx
    jmp       right_loop

right_success_empty:
    mov       rsi, dest_str
    mov       byte ptr [rsi], 0
    jmp       right_exit

right_success:
    ; Null-terminate the string at r12
    mov       byte ptr [r13 + r12], 0
    mov       rax, dest_str

    jmp       right_exit

right_empty:
    ; Allocate 1 byte for empty string (just NUL)
    mov       rdi, 1
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        right_exit
    mov       byte ptr [rax], 0

right_exit:
    ret
RIGHT$ ENDP

END