OPTION LITERALS:ON
option casemap:none
option frame:auto

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn SORT          :proto :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; DIR$
;   Returns a pointer to an array of strings representing the files in a directory 
;
; Parameters:
;   dir_path:ptr - Pointer to the directory path string.
;
; Returns:
;   rax = Pointer to the array of strings containing the matching filenames,
;         or null if allocation fails or no files match.
;
; Notes:
;   The returned array includes a NULL terminator at the end.
;==============================================================================

PUBLIC DIR$
DIR$ PROC USES rbx r12 r13 r14 r15 dir_path:PTR
    LOCAL read_buf[65536]:BYTE
    LOCAL dir_buf[4096]:BYTE
    LOCAL pattern_buf[4096]:BYTE
    LOCAL saved_path:QWORD
    LOCAL open_path:QWORD
    LOCAL saved_pattern:QWORD
    LOCAL entry_count:QWORD
    LOCAL buffer_end:QWORD
    LOCAL record_len:QWORD
    LOCAL name_ptr:QWORD

    ; Split a wildcard path into its directory and final-component pattern.
    ; Plain directory paths retain the historical implicit "*" pattern.
    mov     r12, dir_path
    xor     r13, r13                  ; last slash
    xor     r14, r14                  ; wildcard present
dir_path_scan:
    mov     al, [r12]
    test    al, al
    jz      dir_path_scan_done
    cmp     al, '/'
    jne     dir_path_wildcard
    mov     r13, r12
    jmp     dir_path_scan_next
dir_path_wildcard:
    cmp     al, '*'
    je      dir_path_has_wildcard
    cmp     al, '?'
    jne     dir_path_scan_next
dir_path_has_wildcard:
    mov     r14, 1
dir_path_scan_next:
    inc     r12
    jmp     dir_path_scan

dir_path_scan_done:
    test    r14, r14
    jz      dir_plain_path
    test    r13, r13
    jz      dir_wildcard_no_slash

    ; Copy the directory prefix, excluding the final slash.
    mov     rsi, dir_path
    lea     rdi, [dir_buf]
    cmp     r13, rsi
    jne     dir_copy_prefix
    mov     byte ptr [rdi], '/'
    inc     rdi
    jmp     dir_copy_prefix_done
dir_copy_prefix:
    cmp     rsi, r13
    jae     dir_copy_prefix_done
    mov     al, [rsi]
    mov     [rdi], al
    inc     rsi
    inc     rdi
    jmp     dir_copy_prefix
dir_copy_prefix_done:
    mov     byte ptr [rdi], 0
    lea     rax, [dir_buf]
    mov     open_path, rax
    lea     rsi, [r13 + 1]
    jmp     dir_copy_pattern

dir_wildcard_no_slash:
    mov     byte ptr [dir_buf], '.'
    mov     byte ptr [dir_buf + 1], 0
    lea     rax, [dir_buf]
    mov     open_path, rax
    mov     rsi, dir_path
    jmp     dir_copy_pattern

dir_plain_path:
    mov     open_path, dir_path
    lea     rsi, [implicit_pattern]
    mov     saved_pattern, rsi
    jmp     dir_open_first

dir_copy_pattern:
    lea     rdi, [pattern_buf]
dir_copy_pattern_loop:
    mov     al, [rsi]
    mov     [rdi], al
    inc     rsi
    inc     rdi
    test    al, al
    jnz     dir_copy_pattern_loop
    lea     rax, [pattern_buf]
    mov     saved_pattern, rax

dir_open_first:

    ; First pass: count names and the bytes needed for their copies.
    mov     rax, 2                    ; sys_open
    mov     rdi, open_path
    mov     rsi, 10000h               ; O_RDONLY | O_DIRECTORY
    xor     rdx, rdx
    syscall
    test    rax, rax
    js      dir_fail
    mov     r14, rax                  ; directory file descriptor
    xor     r12, r12                  ; entry count
    xor     r13, r13                  ; name bytes, including NULs

dir_first_read:
    mov     rax, 217                  ; sys_getdents64
    mov     rdi, r14
    lea     rsi, [read_buf]
    mov     rdx, SIZEOF read_buf
    syscall
    test    rax, rax
    jz      dir_first_done
    js      dir_close_fail

    lea     rbx, [read_buf]
    lea     rdx, [rbx + rax]
    mov     buffer_end, rdx
dir_first_entry:
    cmp     rbx, buffer_end
    jae     dir_first_read
    movzx   rcx, word ptr [rbx + 16]
    test    rcx, rcx
    jz      dir_close_fail
    mov     record_len, rcx
    lea     rdi, [rbx + 19]

    ; Ignore the synthetic current and parent directory entries.
    mov     al, [rdi]
    cmp     al, '.'
    jne     dir_first_name
    cmp     byte ptr [rdi + 1], 0
    je      dir_first_next
    cmp     byte ptr [rdi + 1], '.'
    jne     dir_first_name
    cmp     byte ptr [rdi + 2], 0
    je      dir_first_next

dir_first_name:
    mov     name_ptr, rdi
    mov     rsi, saved_pattern
    call    dir_match
    mov     rdi, name_ptr
    test    rax, rax
    jz      dir_first_next
    xor     r8, r8
dir_first_name_len:
    cmp     byte ptr [rdi + r8], 0
    je      dir_first_name_done
    inc     r8
    jmp     dir_first_name_len
dir_first_name_done:
    inc     r8
    inc     r12
    add     r13, r8
    jc      dir_close_fail

dir_first_next:
    add     rbx, record_len
    jmp     dir_first_entry

dir_first_done:
    mov     rax, 3                    ; sys_close
    mov     rdi, r14
    syscall
    mov     entry_count, r12

    ; Allocate the pointer table followed by all NUL-terminated names.
    mov     rax, r12
    shl     rax, 3
    jc      dir_fail
    add     rax, r13
    jc      dir_fail
    add     rax, 8
    jc      dir_fail
    mov     rdi, rax
    lea     rsi, [arena]
    call    arena_alloc
    test    rax, rax
    jz      dir_fail
    mov     r12, rax
    mov     r13, r12
    mov     rax, entry_count
    shl     rax, 3
    add     r13, rax
    xor     rbx, rbx                  ; result entry index

    ; Second pass: copy names and publish pointers into the result array.
    mov     rax, 2                    ; sys_open
    mov     rdi, open_path
    mov     rsi, 10000h
    xor     rdx, rdx
    syscall
    test    rax, rax
    js      dir_fail
    mov     r14, rax

dir_second_read:
    mov     rax, 217                  ; sys_getdents64
    mov     rdi, r14
    lea     rsi, [read_buf]
    mov     rdx, SIZEOF read_buf
    syscall
    test    rax, rax
    jz      dir_second_done
    js      dir_second_close_fail

    lea     r15, [read_buf]
    lea     rdx, [r15 + rax]
    mov     buffer_end, rdx
dir_second_entry:
    cmp     r15, buffer_end
    jae     dir_second_read
    movzx   rcx, word ptr [r15 + 16]
    test    rcx, rcx
    jz      dir_second_close_fail
    mov     r10, rcx
    mov     record_len, rcx
    lea     rdi, [r15 + 19]

    mov     al, [rdi]
    cmp     al, '.'
    jne     dir_second_name
    cmp     byte ptr [rdi + 1], 0
    je      dir_second_next
    cmp     byte ptr [rdi + 1], '.'
    jne     dir_second_name
    cmp     byte ptr [rdi + 2], 0
    je      dir_second_next

dir_second_name:
    mov     name_ptr, rdi
    mov     rsi, saved_pattern
    call    dir_match
    mov     rdi, name_ptr
    test    rax, rax
    jz      dir_second_next
    xor     r8, r8
dir_second_name_len:
    cmp     byte ptr [rdi + r8], 0
    je      dir_second_name_done
    inc     r8
    jmp     dir_second_name_len
dir_second_name_done:
    inc     r8
    mov     [r12 + rbx*8], r13
    mov     rsi, rdi
    mov     rdi, r13
    mov     rcx, r8
    cld
    rep     movsb
    add     r13, r8
    inc     rbx

dir_second_next:
    add     r15, record_len
    jmp     dir_second_entry

dir_second_done:
    mov     qword ptr [r12 + rbx*8], 0
    mov     rax, 3                    ; sys_close
    mov     rdi, r14
    syscall

    SORT(r12)
    mov     rax, r12

    ret

dir_second_close_fail:
    mov     rax, 3
    mov     rdi, r14
    syscall
    jmp     dir_fail
dir_close_fail:
    mov     rax, 3
    mov     rdi, r14
    syscall
dir_fail:
    xor     rax, rax
    ret
DIR$ ENDP

; Match one directory name against a pattern containing '*' and '?'.
; Inputs: rdi = name, rsi = pattern. Returns RAX = 1 for a match.
dir_match PROC USES r12 r13 r14 r15
    mov     r12, rdi
    mov     r13, rsi
    cmp     byte ptr [r13], '*'
    jne     dir_match_literal
    inc     r13
    cmp     byte ptr [r13], 0
    je      dir_match_yes
    xor     r14, r14
dir_match_name_length:
    cmp     byte ptr [r12 + r14], 0
    je      dir_match_name_length_done
    inc     r14
    jmp     dir_match_name_length
dir_match_name_length_done:
    xor     r15, r15
dir_match_pattern_length:
    cmp     byte ptr [r13 + r15], 0
    je      dir_match_pattern_length_done
    inc     r15
    jmp     dir_match_pattern_length
dir_match_pattern_length_done:
    cmp     r15, r14
    ja      dir_match_no
    sub     r14, r15
    add     r12, r14
    xor     rcx, rcx
dir_match_suffix:
    cmp     rcx, r15
    jae     dir_match_yes
    mov     al, [r12 + rcx]
    mov     dl, [r13 + rcx]
    cmp     dl, '?'
    je      dir_match_suffix_next
    cmp     al, dl
    jne     dir_match_no
dir_match_suffix_next:
    inc     rcx
    jmp     dir_match_suffix

dir_match_literal:
    xor     rcx, rcx
dir_match_literal_loop:
    mov     al, [r12 + rcx]
    mov     dl, [r13 + rcx]
    test    dl, dl
    jz      dir_match_literal_end
    test    al, al
    jz      dir_match_no
    cmp     dl, '?'
    je      dir_match_literal_next
    cmp     al, dl
    jne     dir_match_no
dir_match_literal_next:
    inc     rcx
    jmp     dir_match_literal_loop
dir_match_literal_end:
    test    al, al
    jnz     dir_match_no
dir_match_yes:
    mov     rax, 1
    ret
dir_match_no:
    xor     rax, rax
    ret
dir_match ENDP

.data
implicit_pattern db '*', 0
END
