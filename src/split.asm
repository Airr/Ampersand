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
; SPLIT$
;   Splits a null-terminated string into an array of substrings based on a delimiter.
;   Tokens are allocated from the arena and stored in a pointer array.
;
; Parameters:
;   srcString (ptr): A null-terminated string to be split.
;   delimiterString (ptr): A null-terminated string that serves as the delimiter.
;
; Returns:
;   rax: Pointer to an array of pointers, where each element is a token from srcString,
;        and the last element is NULL. If an error occurs, returns NULL.
;==============================================================================

PUBLIC SPLIT$
SPLIT$ PROC USES rbx r12 r13 r14 r15 srcString:ptr, delimiterString:ptr
    local src_str:qword
    local pat_str:qword
    local token_len:qword
    local dest_buf:qword
    local dest_arr:qword

    mov       src_str, srcString
    mov       pat_str, delimiterString
    mov       r12, srcString
    mov       r13, delimiterString

    ; --- 1. Validation ---
    test      r12, r12
    jz        split_fail

    test      r13, r13
    jz        split_no_delim
    cmp       byte ptr [r13], 0
    je        split_no_delim

    ; --- 2. Pass 1: Count Tokens ---
    mov       rcx, 1                    ; Base token count = 1

count_tokens_loop:
    mov       al, byte ptr [r12]
    test      al, al
    jz        count_tokens_done

    mov       rdi, r12
    mov       rsi, r13
    call      check_delimiter
    test      rax, rax
    jnz       count_next_char

    ; Delimiter matched: increment count and advance past delimiter
    inc       rcx
    mov       rdi, r12
    mov       rsi, r13
    call      skip_delimiter_length
    mov       r12, rdi
    jmp       count_tokens_loop

count_next_char:
    inc       r12
    jmp       count_tokens_loop

count_tokens_done:
    ; rcx = number of tokens (N)
    ; Allocate (N + 1) * 8 bytes from arena for pointer array
    lea       rdi, [rcx*8 + 8]
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        split_fail

    mov       dest_arr, rax
    mov       r14, rax                  ; r14 = array base pointer
    xor       r15, r15                  ; r15 = current token index
    mov       r12, src_str              ; r12 = current scan pointer (reload from saved local)
    mov       r13, pat_str              ; r13 = delimiter pointer

    ; --- 3. Pass 2: Extract and Allocate Tokens ---
next_token_start:
    mov       rbx, r12                  ; rbx = start of current token

scan_char_loop:
    mov       al, byte ptr [r12]
    test      al, al
    jz        token_reached_end_of_str

    ; Check if delimiter matches at current scan pointer r12
    mov       rdi, r12
    mov       rsi, r13
    call      check_delimiter
    test      rax, rax
    jz        token_matched_delimiter

    inc       r12
    jmp       scan_char_loop

token_matched_delimiter:
    ; Token found from rbx to r12 (length = r12 - rbx)
    mov       rax, r12
    sub       rax, rbx
    mov       token_len, rax

    ; Allocate arena space: token_len + 1 (for NUL terminator)
    lea       rdi, [rax + 1]
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        split_fail

    mov       dest_buf, rax

    ; Copy token characters
    mov       rdi, rax
    mov       rsi, rbx
    mov       rcx, token_len
    cld
    rep       movsb
    mov       byte ptr [rdi], 0

    ; Store token pointer in output array
    mov       rax, dest_buf
    mov       [r14 + r15*8], rax
    inc       r15

    ; Advance r12 past delimiter
    mov       rdi, r12
    mov       rsi, r13
    call      skip_delimiter_length
    mov       r12, rdi

    jmp       next_token_start

token_reached_end_of_str:
    ; Final token from rbx to r12 (length = r12 - rbx)
    mov       rax, r12
    sub       rax, rbx
    mov       token_len, rax

    ; Allocate arena space: token_len + 1 (for NUL terminator)
    lea       rdi, [rax + 1]
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        split_fail

    mov       dest_buf, rax

    ; Copy token characters
    mov       rdi, rax
    mov       rsi, rbx
    mov       rcx, token_len
    cld
    rep       movsb
    mov       byte ptr [rdi], 0

    ; Store token pointer in output array
    mov       rax, dest_buf
    mov       [r14 + r15*8], rax
    inc       r15

    ; Null-terminate pointer array
    mov       qword ptr [r14 + r15*8], 0

    ; Return array pointer
    mov       rax, r14
    ret

split_no_delim:
    ; Allocate 16 bytes for 2 pointers: [token_ptr, NULL]
    mov       rdi, 16
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        split_fail
    mov       dest_arr, rax

    ; Find length of str_ptr
    mov       r12, src_str
    xor       rcx, rcx
no_delim_len_loop:
    cmp       byte ptr [r12 + rcx], 0
    je        no_delim_len_done
    inc       rcx
    jmp       no_delim_len_loop

no_delim_len_done:
    mov       token_len, rcx
    lea       rdi, [rcx + 1]
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        split_fail

    mov       dest_buf, rax
    mov       rdi, rax
    mov       rsi, r12
    mov       rcx, token_len
    cld
    rep       movsb
    mov       byte ptr [rdi], 0

    ; Populate array: [dest_buf, 0]
    mov       r14, dest_arr
    mov       rax, dest_buf
    mov       [r14], rax
    mov       qword ptr [r14 + 8], 0

    mov       rax, r14
    ret

split_fail:
    xor       rax, rax
    ret
SPLIT$ ENDP

; -----------------------------------------------------------------------------
; check_delimiter
; Inputs:  rdi = scan position in source string
;          rsi = delimiter string
; Returns: eax = 0 (and ZF=1) if match, 1 (and ZF=0) if mismatch
; -----------------------------------------------------------------------------
check_delimiter PROC
    push      rdi
    push      rsi
cd_loop:
    mov       al, [rsi]
    test      al, al
    jz        cd_match

    mov       dl, [rdi]
    cmp       dl, al
    jne       cd_fail

    inc       rdi
    inc       rsi
    jmp       cd_loop

cd_match:
    xor       eax, eax
    jmp       cd_exit

cd_fail:
    mov       eax, 1
    test      eax, eax

cd_exit:
    pop       rsi
    pop       rdi
    ret
check_delimiter ENDP

; -----------------------------------------------------------------------------
; skip_delimiter_length
; Inputs:  rdi = current scan pointer (start of delimiter)
;          rsi = delimiter string
; Returns: rdi = scan pointer advanced past delimiter
; -----------------------------------------------------------------------------
skip_delimiter_length PROC
    push      rsi
sdl_loop:
    mov       al, [rsi]
    test      al, al
    jz        sdl_done
    inc       rdi
    inc       rsi
    jmp       sdl_loop
sdl_done:
    pop       rsi
    ret
skip_delimiter_length ENDP

END