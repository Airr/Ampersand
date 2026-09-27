OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; memfree - Releases a memory block managed by the 8-byte header architecture
; Input:  mem_ptr (PTR) - pointer returned by memalloc or strdup
; Output: None
; -----------------------------------------------------------------------------
PUBLIC memfree
memfree PROC USES rsi rdi mem_ptr:PTR
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
memfree ENDP

END