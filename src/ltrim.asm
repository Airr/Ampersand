OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn LEN           :PROC

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; LTRIM$
;   Trims leading whitespace (spaces and tabs) from a string.
;
; Parameters:
;   srcString:ptr - Pointer to the null-terminated string from which leading 
;                    whitespace will be removed.
;
; Returns:
;   rax = Pointer to a newly allocated string containing the trimmed string,
;         or null if an error occurs during allocation.
;==============================================================================

PUBLIC LTRIM$
LTRIM$ PROC USES rbx r12 r13 r14 r15 srcString:ptr
    local src_str:qword
    local src_len:qword
    local new_len:qword
    local src_start:qword
    local new_str:qword

    mov       src_str, srcString              ; rbx = source string s
    mov       rbx, srcString

    ; --- 1. Get current string length ---
    call      LEN                       
    mov       src_len, rax              ; r14 = len
    mov       r14, rax

    ; If length is 0, just allocate an empty new arena string (just NUL)
    test      r14, r14
    jz        ltrim_allocate_empty

    mov       rdi, rbx                  ; rdi = pointer scanning from left
    mov       rsi, rbx                  ; rsi = end boundary pointer (s + len)
    add       rsi, r14

ltrim_scan_loop:
    cmp       rdi, rsi
    jge       ltrim_allocate_empty      ; Reached end of string, result is empty

    mov       al, byte ptr [rdi]
    test      al, al
    jz        ltrim_allocate_empty

    ; Check if character is a space (32) or a tab (9)
    cmp       al, 32
    je        ltrim_skip_char
    cmp       al, 9
    jne       ltrim_found_start         ; Not space or tab, we found our new start

ltrim_skip_char:
    inc       rdi                       ; Skip leading space or tab
    jmp       ltrim_scan_loop

ltrim_found_start:
    ; rdi now points to the first non-whitespace character.
    mov       src_start, rdi            ; r12 = securely save source start pointer
    mov       r12, rdi
    mov       rax, rsi
    sub       rax, r12                  ; r13 = new length
    mov       new_len, rax
    mov       r13, rax
    jmp       ltrim_do_allocate

ltrim_allocate_empty:
    xor       rax, rax                  ; new length = 0
    mov       new_len, rax
    mov       r13, rax
    mov       src_start, rax
    mov       r12, rax

ltrim_do_allocate:
    ; --- 2. Allocate space via arena_alloc (new_len bytes + 1 for NUL terminator) ---
    mov       rax, new_len
    inc       rax                       
    mov       rdi, rax                  ; length including NUL
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        ltrim_exit                ; Return NULL if allocation failed
    mov       new_str, rax              ; r15 = new destination arena payload pointer
    mov       r15, rax

    ; If new length is 0, just write NUL terminator and return
    mov       rax, new_len
    test      rax, rax
    jz        ltrim_terminate

    ; --- 3. Copy trimmed bytes from preserved source offset into the new string ---
    xor       rcx, rcx                  ; index counter = 0

ltrim_copy_loop:
    mov       rax, new_len
    cmp       rcx, rax
    jge       ltrim_terminate

    mov       rax, src_start
    mov       dl, byte ptr [rax + rcx]    ; Read byte from preserved source position (r12)
    mov       byte ptr [r15 + rcx], dl    ; Write byte to new destination safely

    inc       rcx
    jmp       ltrim_copy_loop

ltrim_terminate:
    ; Ensure null-termination at the end of the trimmed string
    mov       rax, new_len
    mov       byte ptr [r15 + rax], 0
    mov       rax, new_str              ; Return pointer to new arena string payload

ltrim_exit:
    ret
LTRIM$ ENDP

END
