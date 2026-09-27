OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn szEmpty       :byte

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; EXTRACT$
;   Extracts a prefix from a string based on a match with another string.
;   If no match is found, returns the entire input string.
;
; Parameters:
;   mainStr:ptr - Pointer to the source string from which to extract.
;   matchStr:ptr - Pointer to the substring that indicates where to stop extraction.
;
; Returns:
;   rax = Pointer to a new string containing the extracted prefix,
;         or a copy of the entire input string if no match is found.
;==============================================================================

PUBLIC EXTRACT$
EXTRACT$ PROC USES rbx r12 r13 r14 r15 mainStr:ptr, matchStr:ptr
    mov       r12, mainStr                  ; r12 = mainStr pointer
    mov       r13, matchStr                 ; r13 = matchStr pointer

    ; --- 1. Edge Case Checks ---
    test      r12, r12
    jz        extract_empty             ; If mainStr is NULL, return empty string

    test      r13, r13
    jz        extract_copy_all          ; If matchStr is NULL, return copy of mainStr
    mov       al, byte ptr [r13]
    test      al, al
    jz        extract_copy_all          ; If matchStr is empty (""), return copy of mainStr

    ; --- 2. Pure Assembly Substring Search (strstr equivalent) ---
    mov       r14, r12                  ; r14 will track match start position if found

extract_search_loop:
    mov       al, byte ptr [r14]
    test      al, al
    jz        extract_not_found         ; Reached end of mainStr without match

    mov       rbx, r14                  ; rbx = scan pointer in mainStr
    mov       r15, r13                  ; r15 = scan pointer in matchStr

match_inner_loop:
    mov       dl, byte ptr [r15]
    test      dl, dl
    jz        extract_found             ; End of matchStr reached -> match found!

    mov       cl, byte ptr [rbx]
    test      cl, cl
    jz        extract_not_found         ; End of mainStr reached prematurely

    cmp       cl, dl
    jne       match_failed              ; Mismatch found

    inc       rbx
    inc       r15
    jmp       match_inner_loop

match_failed:
    inc       r14                       ; Advance mainStr start position by 1 and retry
    jmp       extract_search_loop

extract_not_found:
    ; Match not found -> return full copy of mainStr via arena
    jmp       extract_copy_all

extract_found:
    ; --- 3. Calculate Prefix Length ---
    mov       rcx, r14
    sub       rcx, r12                  ; rcx = length of prefix
    mov       r14, rcx                  ; r14 = exact length to EXTRACT$

    ; --- 4. Allocate from Arena (length + 1 for NUL terminator) ---
    mov       rdi, r14
    inc       rdi                       ; Space for NUL
    lea       rsi, [arena]
    call      arena_alloc

    test      rax, rax
    jz        extract_fail

    ; --- 5. Copy characters up to the match point ---
    mov       rdi, rax                  ; Destination = arena buffer
    mov       rsi, r12                  ; Source = mainStr pointer
    mov       rcx, r14                  ; Length to copy
    cld
    rep       movsb

    mov       byte ptr [rdi], 0         ; Null-terminate payload
    sub       rdi, r14                  ; Reset rdi to start of arena block
    mov       rax, rdi                  ; Return arena-allocated string pointer
    jmp       extract_exit

extract_copy_all:
    ; Compute length of mainStr including NUL
    mov       rbx, r12
    xor       rcx, rcx
all_len_loop:
    cmp       byte ptr [rbx + rcx], 0
    je        all_len_done
    inc       rcx
    jmp       all_len_loop
all_len_done:
    inc       rcx                       ; Include NUL byte
    mov       r14, rcx

    mov       rdi, r14
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        extract_fail

    mov       rdi, rax
    mov       rsi, r12
    mov       rcx, r14
    cld
    rep       movsb

    sub       rdi, r14
    mov       rax, rdi
    jmp       extract_exit

extract_empty:
    ; Return empty string allocated from arena (1 byte for NUL)
    mov       rdi, 1
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        extract_fail
    mov       byte ptr [rax], 0
    jmp       extract_exit

extract_fail:
    xor       rax, rax

extract_exit:
    ret
EXTRACT$ ENDP

end