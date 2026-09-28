OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

;
;==============================================================================
; MEM_FREE
;   Frees a block of memory that was previously allocated with MEMALLOC.
;
; Parameters:
;   mem_ptr:ptr - Pointer to the block of memory to be freed.
;
; Returns:
;   None
;==============================================================================

PUBLIC MEM_FREE
MEM_FREE PROC USES rsi rdi mem_ptr:PTR
    mov     rdi, mem_ptr
    test    rdi, rdi
    jz      @memfree_done

    ; Retrieve total size from the hidden 8-byte header and compute base address
    mov     rsi, [rdi - 8]      ; rsi = total mmap size stored in header
    lea     rdi, [rdi - 8]      ; rdi = base address returned by mmap

    ; Invoke sys_munmap (syscall 11)
    mov     rax, 11             ; SYS_munmap
    syscall

@memfree_done:
    ret
MEM_FREE ENDP

END