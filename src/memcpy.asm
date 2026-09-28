OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;
;==============================================================================
; MEM_COPY
;   Copies a block of memory from one location to another.
;
; Parameters:
;   dest:ptr - Pointer to the destination buffer where data will be copied.
;   src:ptr  - Pointer to the source buffer from which data is copied.
;   len:qword- The number of bytes to copy.
;
; Returns:
;   rax = Pointer to the destination buffer (same as the input dest parameter),
;         indicating the completion of the copying operation.
;==============================================================================

PUBLIC MEM_COPY
MEM_COPY PROC USES rdi rsi rcx dest:PTR, src:PTR, len:QWORD
    mov     rdi, dest
    mov     rsi, src
    mov     rcx, len
    
    test    rcx, rcx
    jz      @memcpy_done
    
    rep     movsb               ; Hardware-accelerated block copy via ERMS

    @memcpy_done:
        mov     rax, dest
    ret
MEM_COPY ENDP
end