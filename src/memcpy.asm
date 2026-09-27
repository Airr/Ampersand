OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

PUBLIC memcpy
memcpy PROC USES rdi rsi rcx dest:PTR, src:PTR, len:QWORD
    mov     rdi, dest
    mov     rsi, src
    mov     rcx, len
    
    test    rcx, rcx
    jz      @memcpy_done
    
    rep     movsb               ; Hardware-accelerated block copy via ERMS

    @memcpy_done:
        mov     rax, dest
    ret
memcpy ENDP
end