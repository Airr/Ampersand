OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn szEmpty       :byte

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.data
szPrefix    db  1bh, '[', '3'            ; ANSI prefix base (\x1b[3)
szReset     db  1bh, '[', '0', 'm', 0    ; ANSI reset sequence (\x1b[0m)

.code

PUBLIC COLOR
COLOR PROC USES rbx r12 r13 r14 r15 text:ptr, colorcode:qword
    mov     r12, text                   ; r12 = text pointer
    mov     r13, colorcode              ; r13 = fg COLOR code

    test    r12, r12
    jz      color_empty

    ; --- 1. Calculate text length ---
    xor     rax, rax
    mov     rbx, r12
len_loop:
    mov     dl, byte ptr [rbx]
    test    dl, dl
    jz      len_done
    inc     rax
    inc     rbx
    jmp     len_loop
len_done:
    mov     r14, rax                ; r14 = length of text

    ; Total size needed: ANSI start (5 bytes) + text len + ANSI reset (4 bytes without NUL, or total string len) + null terminator
    ; Prefix is 5 bytes: "\x1b[3" + digit + 'm' -> wait, szPrefix is 3 bytes ("\x1b[3"), then 2 bytes added ('digit', 'm') = 5 bytes total.
    ; Reset sequence is 4 bytes ("\x1b[0m") plus a null terminator = 5 bytes.
    ; Total exact size = 5 (prefix) + r14 (text) + 4 (reset bytes) + 1 (null terminator) = r14 + 10 bytes.
    lea     rax, [r14 + 10]
    mov     r15, rax                ; r15 = total allocation size needed

    ; --- 2. Allocate directly from the Arena ---
    ; mov     rdi, r15
    ; lea     rsi, [arena]
    ; call    arena_alloc
    arena_alloc(r15, addr arena)

    test    rax, rax
    jz      color_fail

    mov     rbx, rax                ; rbx = arena destination payload buffer
    mov     rdi, rbx                ; rdi = destination pointer

    ; Copy ANSI prefix base (\x1b[3) from .data section
    lea     rsi, [szPrefix]
    mov     rcx, 3
    rep     movsb
    
    ; Append dynamic COLOR code digit (0-7) and 'm'
    mov     al, r13b    
    add     al, '0'
    mov     byte ptr [rdi], al
    mov     byte ptr [rdi + 1], 'm'
    add     rdi, 2

    ; Copy original text payload
    mov     rsi, r12
    mov     rcx, r14
    rep     movsb

    ; Append ANSI reset sequence from the .data section (copy 4 bytes: "\x1b[0m")
    lea     rsi, [szReset]
    mov     rcx, 4
    rep     movsb

    ; Null-terminate the final combined string
    mov     byte ptr [rdi], 0

    mov     rax, rbx                ; Return arena-allocated string pointer
    jmp     color_exit

color_empty:
    ; Return empty string allocated from arena (1 byte for NUL)
    ; mov     rdi, 1
    ; lea     rsi, [arena]
    ; call    arena_alloc
    arena_alloc(1, addr arena)
    test    rax, rax
    jz      color_fail
    mov     byte ptr [rax], 0
    jmp     color_exit

color_fail:
    xor     rax, rax

color_exit:
    ret
COLOR ENDP

end