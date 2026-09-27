OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; Name:         REMOVE$
; Description:  Returns a substring of MainStr with all case-sensitive 
;               occurrences of the Match string removed, using arena storage and no libc.
; C Prototype:  char* REMOVE$(const char* mainStr, const char* matchStr);
; Parameters:   rdi - Pointer to MainStr (null-terminated C string)
;               rsi - Pointer to MatchStr (null-terminated C string)
; Returns:      rax - Pointer to a new arena-allocated string with matches removed
; -----------------------------------------------------------------------------
PUBLIC REMOVE$

REMOVE$ PROC USES rbx r12 r13 r14 r15 srcString:ptr, match:ptr
    local main_str:qword
    local match_str:qword
    local match_len:qword
    local new_len:qword
    local dest_ptr:qword

    mov       main_str, srcString
    mov       r12, match                  ; r12 = mainStr pointer
    mov       match_str, rsi
    mov       r13, match                  ; r13 = matchStr pointer

    ; --- 1. Edge Case Checks ---
    test      r12, r12
    jz        remove_empty              ; If mainStr is NULL, return empty string

    test      r13, r13
    jz        remove_copy_all           ; If matchStr is NULL, return copy of mainStr
    
    ; Find length of matchStr
    xor       rax, rax
    mov       rbx, r13
match_len_loop:
    mov       dl, byte ptr [rbx]
    test      dl, dl
    jz        match_len_done
    inc       rax
    inc       rbx
    jmp       match_len_loop
match_len_done:
    test      rax, rax
    jz        remove_copy_all           ; If matchStr is empty (""), return copy of mainStr
    mov       match_len, rax
    mov       r15, rax                  ; r15 = length of matchStr

    ; --- 2. Pass 1: Calculate Length of Resulting String ---
    xor       r14, r14                  ; r14 = new string length accumulator
    mov       rbx, r12                  ; rbx = current scan pointer in mainStr

pass1_loop:
    mov       al, byte ptr [rbx]
    test      al, al
    jz        pass1_done                ; Reached end of mainStr

    ; Check if matchStr matches at current position (rbx)
    mov       rcx, match_str            ; rcx = matchStr pointer
    mov       rdx, rbx                  ; rdx = temp mainStr pointer for comparison
    mov       rsi, match_len            ; rsi = matchStr length counter

pass1_match_check:
    test      rsi, rsi
    jz        pass1_matched             ; Full match found!

    mov       al, byte ptr [rdx]
    test      al, al
    jz        pass1_no_match            ; MainStr ended prematurely

    mov       ah, byte ptr [rcx]
    cmp       al, ah
    jne       pass1_no_match            ; Mismatch

    inc       rdx
    inc       rcx
    dec       rsi
    jmp       pass1_match_check

pass1_matched:
    ; A match was found! Skip past it in the source scan.
    mov       rax, match_len
    add       rbx, rax                  ; Advance mainStr pointer by match length
    jmp       pass1_loop

pass1_no_match:
    ; No match at this position, keep the character
    inc       r14                       ; Increment new string length
    inc       rbx                       ; Advance mainStr pointer by 1
    jmp       pass1_loop

pass1_done:
    mov       new_len, r14              ; r14 holds exact length without NUL terminator

    ; --- 3. Allocate Space via arena_alloc (new_len + 1 for NUL) ---
    mov       rax, r14
    inc       rax                       ; add 1 for NUL terminator
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        remove_fail
    mov       dest_ptr, rax
    mov       r15, rax                  ; r15 = destination pointer

    ; --- 4. Pass 2: Populate Destination Payload Buffer ---
    mov       rbx, main_str             ; reset mainStr scan pointer
    mov       rdi, dest_ptr             ; reset destination write pointer

pass2_loop:
    mov       al, byte ptr [rbx]
    test      al, al
    jz        pass2_done                ; Reached end of mainStr

    ; Check for match again at current position
    mov       rcx, match_str
    mov       rdx, rbx
    mov       rsi, match_len

pass2_match_check:
    test      rsi, rsi
    jz        pass2_matched

    mov       al, byte ptr [rdx]
    test      al, al
    jz        pass2_no_match

    mov       ah, byte ptr [rcx]
    cmp       al, ah
    jne       pass2_no_match

    inc       rdx
    inc       rcx
    dec       rsi
    jmp       pass2_match_check

pass2_matched:
    mov       rax, match_len
    add       rbx, rax
    jmp       pass2_loop

pass2_no_match:
    mov       al, byte ptr [rbx]
    mov       byte ptr [rdi], al
    inc       rdi
    inc       rbx
    jmp       pass2_loop

pass2_done:
    ; Null-terminate the new string
    mov       byte ptr [rdi], 0

    ; --- 5. Return Destination Pointer ---
    mov       rax, dest_ptr
    jmp       remove_exit

remove_copy_all:
    ; Compute length of mainStr
    xor       rax, rax
    mov       rbx, main_str
len_all_loop:
    mov       dl, byte ptr [rbx + rax]
    test      dl, dl
    jz        len_all_done
    inc       rax
    jmp       len_all_loop
len_all_done:
    mov       r14, rax
    
    ; Allocate arena space
    lea       rax, [r14 + 1]
    mov       rdi, rax
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        remove_fail
    mov       dest_ptr, rax

    ; Copy string
    xor       rcx, rcx
copy_all_loop:
    cmp       rcx, r14
    jge       copy_all_done
    mov       rsi, main_str
    mov       al, byte ptr [rsi + rcx]
    mov       rsi, dest_ptr
    mov       byte ptr [rsi + rcx], al
    inc       rcx
    jmp       copy_all_loop
copy_all_done:
    mov       rsi, dest_ptr
    mov       byte ptr [rsi + r14], 0
    mov       rax, dest_ptr
    jmp       remove_exit

remove_empty:
    ; Allocate 1 byte for empty string (just NUL)
    mov       rdi, 1
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        remove_fail
    mov       byte ptr [rax], 0
    jmp       remove_exit

remove_fail:
    xor       rax, rax

remove_exit:
    ret
REMOVE$ ENDP

END