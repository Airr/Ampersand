OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn UCASE$    :proto :ptr
extrn LCASE$    :proto :ptr
extrn TRIM$    :proto :ptr
extrn REPLACE$  :proto :ptr, :ptr, :ptr
extrn LEFT$     :proto :ptr, :qword
extrn LEN       :proto :ptr

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

MATCH$ PROTO :ptr, :ptr

.code

;
;==============================================================================
; REMAIN$
;   Returns the substring of pSource starting from the first occurrence of pMatch.
;
; Parameters:
;   pSource (ptr): The source string from which to start the substring.
;   pMatch (ptr): The substring at which to begin the returned substring.
;
; Returns:
;   rax: Pointer to a null-terminated string containing the portion of pSource
;        starting from the first occurrence of pMatch.
;
;        If an error occurs or no match is found, returns NULL.
;==============================================================================

PUBLIC REMAIN$
REMAIN$ PROC USES r12 r13 r14 r15 pSource:ptr, pMatch:ptr
    mov r14, pSource
    mov r15, pMatch
    .if r14 == 0 || r15 == 0
        xor rax, rax
        ret
    .endif

    mov r12, MATCH$(r14, r15)     ; line text, beginning at the first match
    .if r12
        mov r13, LEN(r15)
        add r12, r13              ; step over the match itself (first occurrence only)
        mov rax, TRIM$(r12)
        ret
    .endif

    xor rax, rax
    ret
REMAIN$ endp

; ----------------------------------------------------------------------
; MATCH$   (System V AMD64 ABI, Linux)
;   Finds pMatch inside pSource and returns the matched text through the
;   end of that line (up to, but not including, the terminating LF).
;
;   In:   RDI = pSource  (zero-terminated)
;         RSI = pMatch   (zero-terminated)
;   Out:  RAX = pointer to start of match in pSource, or 0 if not found
;         RDX = length in bytes from match start to LF (or NUL if there
;               is no LF); 0 if not found
;   Clobbers RCX, RDI, RSI, R8, R9 (all caller-saved). Case-sensitive.
;   Leaf routine: touches no callee-saved registers and no stack.
; ----------------------------------------------------------------------

MATCH$ PROC USES r12 pSource:ptr, pMatch:ptr

        cmp     byte ptr [rsi], 0
        je      @nomatch            ; empty needle never matches


@outer:
        cmp     byte ptr [rdi], 0
        je      @nomatch            ; hit end of source
        mov     r8, rdi             ; r8 = walks source
        mov     r9, rsi             ; r9 = walks needle

@inner:
        mov     al, [r9]
        test    al, al
        jz      @found              ; needle exhausted -> full match
        mov     cl, [r8]

        ; uppercase AL if it's a-z
        cmp     al, 'a'
        jb      @al_done
        cmp     al, 'z'
        ja      @al_done
        sub     al, 20h
@al_done:
        ; uppercase CL if it's a-z
        cmp     cl, 'a'
        jb      @cl_done
        cmp     cl, 'z'
        ja      @cl_done
        sub     cl, 20h
@cl_done:
        cmp     al, cl
        jne     @advance
        inc     r9
        inc     r8
        jmp     @inner

@advance:
        inc     rdi
        jmp     @outer

@found:
        mov     rax, rdi            ; return match start
@scan:                              ; r8 sits just past the needle
        mov     cl, [r8]
        test    cl, cl
        jz      @done               ; NUL: treat as end of line
        cmp     cl, 0Ah             ; LF
        je      @done
        inc     r8
        jmp     @scan

@done:
        mov     rdx, r8
        sub     rdx, rax            ; length = end - start
        mov     rax, LEFT$(rax, rdx) ; return pointer to match start
        ret

@nomatch:
        xor     eax, eax
        xor     edx, edx
        ret

MATCH$ ENDP
end
