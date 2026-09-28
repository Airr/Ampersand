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
; REVERSE$
;   Reverses the order of characters in a given string.
;
; Parameters:
;   src (ptr): The source string to be reversed.
;
; Returns:
;   rax: Pointer to a null-terminated string containing the reversed version 
;        of the source string. If an error occurs or the source is empty, returns NULL.
==============================================================================

PUBLIC REVERSE$
REVERSE$ PROC USES rbx r12 r13 r14 src:ptr
    local src_ptr:qword
    local str_len:qword
    local new_str:qword
    local dest_idx:qword

    mov       src_ptr, src
    mov       rbx, src                  ; rbx = source s pointer

    ; Edge case check for NULL source
    test      rbx, rbx
    jz        reverse_empty

    ; Get current string length using external LEN  
    call      LEN                       ; rdi already contains source pointer
    mov       str_len, rax              ; r12 = len
    mov       r12, rax

    ; Allocate Space via arena_alloc (str_len + 1 for NUL)
    mov       rax, str_len
    inc       rax                       ; add 1 for NUL terminator
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        reverse_exit              ; Return NULL if allocation failed
    mov       new_str, rax              ; r13 = new destination pointer
    mov       r13, rax

    ; If length is 0, just null-terminate and finish
    mov       rax, str_len
    test      rax, rax
    jz        reverse_success_empty

    ; Copy and reverse bytes from source (rbx) to destination (r13)
    ; rsi = source index counter (from 0 to len - 1)
    ; rdi = destination index counter (from len - 1 down to 0)
    xor       rsi, rsi                  ; source index = 0
    mov       rax, str_len
    dec       rax                       ; destination index = len - 1
    mov       dest_idx, rax
    mov       r14, rax

reverse_copy_loop:
    mov       rax, str_len
    cmp       rsi, rax
    jge       reverse_success

    mov       rdx, src_ptr
    mov       al, byte ptr [rdx + rsi]    ; Read byte from source forward
    mov       rdx, dest_idx
    mov       byte ptr [r13 + rdx], al    ; Write byte to destination backward

    inc       rsi
    mov       rax, dest_idx
    dec       rax
    mov       dest_idx, rax
    mov       r14, rax
    jmp       reverse_copy_loop

reverse_success_empty:
    mov       rsi, new_str
    mov       byte ptr [rsi], 0
    jmp       reverse_exit

reverse_success:
    ; Null-terminate the string at str_len
    mov       rdx, str_len
    mov       byte ptr [r13 + rdx], 0
    mov       rax, new_str              ; Return pointer to new string

    jmp       reverse_exit

reverse_empty:
    ; Allocate 1 byte for empty string (just NUL)
    mov       rdi, 1
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        reverse_exit
    mov       byte ptr [rax], 0

reverse_exit:
    ret
REVERSE$ ENDP

END