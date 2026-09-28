OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;
;==============================================================================
; MEMSET
;   Sets a block of memory to a specific value.
;
; Parameters:
;   dest:ptr - Pointer to the destination buffer to be filled with the given value.
;   val:byte - The byte value to fill the buffer with.
;   len:qword- The number of bytes in the buffer to set to the given value.
;
; Returns:
;   rax = Pointer to the destination buffer (same as the input dest parameter),
;         indicating the completion of the setting operation.
;==============================================================================

PUBLIC MEMSET
MEMSET PROC USES rdi dest:PTR, val:BYTE, len:QWORD
    mov     rdi, dest
    mov     al, val
    mov     rcx, len
    
    test    rcx, rcx
    jz      @memset_done
    
    rep     stosb               ; Hardware-accelerated byte fill via ERMS

    @memset_done:
        mov     rax, dest
    ret
MEMSET ENDP
end