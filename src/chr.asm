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
; CHR$
;   Builds a string from a list of character codes (0-255) terminated by a
;   negative value (e.g. CHR_END / -1).
;
; Parameters:
;   codes (vararg): Character codes (0-255) terminated by a negative value.
;
; Returns:
;   rax: Pointer to the newly allocated null-terminated string, or NULL on error.
;==============================================================================

PUBLIC CHR$
CHR$ PROC USES rbx r12 r13
    LOCAL codes[6]:QWORD                    ; the six register-passed codes, spilled

    mov     codes[0],  rdi                  ; code 0
    mov     codes[8],  rsi                  ; code 1
    mov     codes[16], rdx                  ; code 2
    mov     codes[24], rcx                  ; code 3
    mov     codes[32], r8                   ; code 4
    mov     codes[40], r9                   ; code 5
                                            ; codes 6 and up are on the caller's stack

    ; --- 1. Count the codes up to the terminator, validating each ---
    xor     r12, r12                        ; r12 = number of codes
    .while 1
        mov     rax, r12
        .if rax < 6
            mov     rax, codes[rax*8]
        .else
            sub     rax, 6
            mov     rax, [rbp + rax*8 + 16] ; [rbp+8] is the return address
        .endif
        test    rax, rax
        .break .if SIGN?                    ; negative = end of list
        .if rax > 255
            xor     eax, eax                ; bad code -> NULL
            jmp     chr_exit
        .endif
        inc     r12
    .endw

    ; --- 2. Allocate count + 1 bytes ---
    lea     rdi, [r12 + 1]
    lea     rsi, [arena]
    call    arena_alloc
    test    rax, rax
    jz      chr_exit                        ; allocation failed -> NULL
    mov     r13, rax                        ; r13 = destination

    ; --- 3. Store the codes ---
    xor     rbx, rbx
    .while rbx < r12
        mov     rax, rbx
        .if rax < 6
            mov     rax, codes[rax*8]
        .else
            sub     rax, 6
            mov     rax, [rbp + rax*8 + 16]
        .endif
        mov     byte ptr [r13 + rbx], al
        inc     rbx
    .endw

    mov     byte ptr [r13 + r12], 0
    mov     rax, r13

chr_exit:
    ret
CHR$ ENDP

END