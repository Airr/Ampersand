OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; int64_t indexof(const char* haystack, const char* needle)
; Input:  rdi = pointer to haystack string payload
;         rsi = pointer to needle null-terminated string
; Output: rax = 0-based index of first match, or -1 if not found
; -----------------------------------------------------------------------------
PUBLIC INDEXOF

INDEXOF PROC USES rbx r12 r13 r14 r15 haystack:ptr, needle:ptr
    local haystack_ptr:qword
    local needle_ptr:qword
    local haystack_len:qword

    mov       haystack_ptr, haystack         
    mov       r12, haystack
    mov       needle_ptr, needle           
    mov       r13, needle

    ; If needle is empty, return 0 immediately
    mov       al, byte ptr [r13]
    test      al, al
    jz        instr_found_zero

    ; Compute haystack length manually
    mov       rdi, r12
    xor       rcx, rcx
len_loop:
    cmp       byte ptr [rdi + rcx], 0
    je        len_done
    inc       rcx
    jmp       len_loop
len_done:
    mov       haystack_len, rcx         
    mov       r14, rcx
    
    ; If haystack length is 0, can't match anything -> return -1
    test      r14, r14
    jz        instr_not_found

    xor       rbx, rbx                  ; rbx = current haystack index (i = 0)

instr_outer_loop:
    mov       rax, haystack_ptr
    mov       al, byte ptr [rax + rbx]
    test      al, al
    jz        instr_not_found

    ; Check if character matches the first char of needle
    mov       r8, needle_ptr             ; FIX: r8, not rax - rax still holds haystack[rbx] in al
    mov       dl, byte ptr [r8]
    cmp       al, dl
    je        instr_check_substring

    inc       rbx
    dec       r14
    jnz       instr_outer_loop
    jmp       instr_not_found

instr_check_substring:
    ; Inner loop: compare haystack substring with needle using an offset index
    xor       r11, r11                  ; r11 = needle index = 0

instr_inner_loop:
    mov       r8, needle_ptr
    mov       al, byte ptr [r8 + r11]   ; Get needle char at index r11
    test      al, al                    ; End of needle reached = full match!
    jz        instr_match_success

    mov       r9, haystack_ptr          ; FIX: r9, not rax - rax still holds needle[r11] in al
    add       r9, rbx                   ; Current haystack position + offset
    mov       dl, byte ptr [r9 + r11]   ; Get corresponding haystack char
    cmp       al, dl                    ; Do they match?
    jne       instr_match_fail

    inc       r11
    jmp       instr_inner_loop

instr_match_success:
    mov       rax, rbx                  ; Return matching start index
    jmp       instr_exit

instr_match_fail:
    inc       rbx                       ; Move to next character in haystack
    jmp       instr_outer_loop

instr_found_zero:
    xor       rax, rax
    jmp       instr_exit

instr_not_found:
    mov       rax, -1                   ; Return -1 if substring not found

instr_exit:
    ret
INDEXOF ENDP

END