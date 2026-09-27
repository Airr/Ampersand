OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

PUBLIC memset
memset PROC USES rdi dest:PTR, val:BYTE, len:QWORD
    mov     rdi, dest
    mov     al, val
    mov     rcx, len
    
    test    rcx, rcx
    jz      @memset_done
    
    rep     stosb               ; Hardware-accelerated byte fill via ERMS

    @memset_done:
        mov     rax, dest
    ret
memset ENDP
end