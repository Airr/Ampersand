OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS



.code

;
;==============================================================================
; MEM_ALLOC
;   Allocates a block of memory from the system's heap.
;
; Parameters:
;   memsize:qword - The size, in bytes, of the memory block to allocate.
;
; Returns:
;   rax = Pointer to the newly allocated block of memory,
;         or null if an error occurs during allocation.
;==============================================================================

PUBLIC MEM_ALLOC
MEM_ALLOC PROC USES rbx r12 memsize:QWORD
    mov     rbx, memsize
    test    rbx, rbx
    jz      @memalloc_fail

    ; Calculate total allocation size: requested size + 8-byte header
    lea     rsi, [rbx + 8]

    ; Invoke sys_mmap (syscall 9)
    mov     rax, 9              ; SYS_mmap
    xor     rdi, rdi            ; addr = NULL
    ; rsi holds total length (size + 8)
    mov     rdx, 3              ; prot = PROT_READ | PROT_WRITE
    mov     r10, 22h            ; flags = MAP_PRIVATE | MAP_ANONYMOUS
    mov     r8, -1              ; fd = -1
    xor     r9, r9              ; offset = 0
    syscall

    test    rax, rax
    js      @memalloc_fail
    cmp     rax, -4095
    ja      @memalloc_fail

    mov     r12, rax            ; r12 = base mmap address

    ; Store total allocation size in the 8-byte header
    lea     rdx, [rbx + 8]
    mov     [r12], rdx

    ; Return pointer immediately following the 8-byte header
    lea     rax, [r12 + 8]
    ret

@memalloc_fail:
    xor     rax, rax
    ret
MEM_ALLOC ENDP

end
