OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn szEmpty       :byte

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

PUBLIC APPPATH$
.data
    szProcExe db "/PROC/self/exe", 0
.code

APPPATH$ PROC USES rbx r12 r13 r14
    local exeBuf[4096]:byte

    mov     eax, 89                 ; sys_readlink
    lea     rdi, szProcExe
    lea     rsi, exeBuf
    mov     edx, 4095
    syscall

    test    rax, rax
    jle     fail                    ; error or empty

    lea     r12, exeBuf             ; r12 = start of path
    mov     byte ptr [r12 + rax], 0 ; readlink doesn't NUL-terminate
    lea     rbx, [r12 + rax]        ; rbx = end

    mov     r13, -1                 ; index of last '/'

    scan_back:
        cmp     rbx, r12
        jbe     scan_done
        dec     rbx
        cmp     byte ptr [rbx], '/'
        jne     scan_back
        mov     r13, rbx
        sub     r13, r12
    scan_done:
        mov     r14, r13                ; bytes to copy
        cmp     r14, 0
        jg      alloc_string
        mov     r14, 1                  ; slash at index 0 -> "/"

    alloc_string:
        lea     rdi, [r14 + 1]
        lea     rsi, qword ptr [arena]
        call    arena_alloc
        test    rax, rax
        jz      done

        xor     ecx, ecx
    copy_loop:
        cmp     rcx, r14
        jae     copy_done
        mov     dl, [r12 + rcx]
        mov     [rax + rcx], dl
        inc     rcx
        jmp     copy_loop
    copy_done:
        mov     byte ptr [rax + r14], 0
        jmp     done

    fail:
        xor     eax, eax
    done:
        ret
APPPATH$ endp

end