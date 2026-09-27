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
; Name:         RTRIM$
; Description:  Returns a newly allocated arena string with all trailing spaces (32) 
;               and tabs (9) trimmed from 's', using external LEN   .
; C Prototype:  char* RTRIM$(const char* s);
; Parameters:   rdi = pointer to source string (s)
; Returns:      rax = pointer to new arena-allocated string
; -----------------------------------------------------------------------------
PUBLIC RTRIM$

RTRIM$ PROC USES rbx r13 r14 r15 srcString:ptr
    local src_ptr:qword
    local orig_len:qword
    local new_len:qword
    local new_str:qword

    mov       src_ptr, srcString
    mov       rbx, srcString                  ; rbx = source string s

    ; Edge case check for NULL source
    test      rbx, rbx
    jz        rtrim_allocate_empty

    ; --- 1. Get current string length using external LEN    ---
    call      LEN                       ; rdi already contains source pointer
    mov       orig_len, rax
    mov       r14, rax                  ; r14 = len

    ; If length is 0, just allocate an empty new string
    test      rax, rax
    jz        rtrim_allocate_empty

    ; Start scanning from the last character: rsi = s + len - 1
    mov       rsi, rbx
    mov       rax, orig_len
    add       rsi, rax
    dec       rsi                       ; rsi = pointer to last char

rtrim_scan_loop:
    cmp       rsi, rbx
    jl        rtrim_allocate_empty      ; Went past beginning, result string is empty

    mov       al, byte ptr [rsi]

    ; Check if character is a space (32) or a tab (9)
    cmp       al, 32
    je        rtrim_skip_char
    cmp       al, 9
    jne       rtrim_found_end           ; Not space or tab, this is the final valid character

rtrim_skip_char:
    dec       rsi                       ; Move backward
    mov       rax, r14
    dec       rax                       ; Decrease length count
    mov       r14, rax
    jmp       rtrim_scan_loop

rtrim_found_end:
    ; r14 now holds the new trimmed length
    mov       new_len, r14
    jmp       rtrim_do_allocate

rtrim_allocate_empty:
    xor       rax, rax                  ; New length becomes 0
    mov       new_len, rax
    mov       r14, rax

rtrim_do_allocate:
    ; --- 2. Allocate Space via arena_alloc (new_len + 1 for NUL) ---
    mov       rax, new_len
    inc       rax                       ; add 1 for NUL terminator
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        rtrim_exit
    mov       new_str, rax
    mov       r15, rax                  ; r15 = new destination pointer

    ; If new length is 0, just null-terminate and finish
    mov       rax, new_len
    test      rax, rax
    jz        rtrim_success_empty

    ; --- 3. Copy trimmed bytes from source into the new string ---
    xor       rcx, rcx                  ; index counter = 0

rtrim_copy_loop:
    mov       rax, new_len
    cmp       rcx, rax
    jge       rtrim_success

    mov       rax, src_ptr
    mov       dl, byte ptr [rax + rcx]    ; Read byte from source
    mov       byte ptr [r15 + rcx], dl    ; Write byte to new destination

    inc       rcx
    jmp       rtrim_copy_loop

rtrim_success_empty:
    mov       rsi, new_str
    mov       byte ptr [rsi], 0
    jmp       rtrim_exit

rtrim_success:
    ; Null-terminate the string at new_len
    mov       rdx, new_len
    mov       byte ptr [r15 + rdx], 0
    mov       rax, new_str              ; Return pointer to new string

rtrim_exit:
    ret
RTRIM$ ENDP

END