; ==============================================================================
; Arena Memory Manager Module (UASM Compatible, Libc-Independent)
; Supports high-performance O(1) bump allocation, chunk reuse, 
; standard fast reset, and secure zero-fill resetting.
; ==============================================================================

OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

extrn arena         :qword

SYS_MMAP        equ 9
SYS_MUNMAP      equ 11
PROT_READ       equ 1
PROT_WRITE      equ 2
MAP_PRIVATE     equ 2
MAP_ANON        equ 32

.code

; ------------------------------------------------------------------------------
; arena_alloc
; Allocates memory from an arena using a bump pointer, expanding via mmap 
; or reusing existing chunks down the chain when capacity is reached.
; 
; Inputs:
;   rdi = number of bytes requested
;   rsi = pointer to arena descriptor [current_chunk, root_chunk]
; 
; Output:
;   rax = pointer to allocated payload space (or 0 on mmap failure)
; ------------------------------------------------------------------------------
arena_alloc PROC USES rbx r12 r13
    mov     rbx, rdi        
    mov     r13, rsi        
    
    ; Align requested size to 8 bytes
    add     rbx, 7
    and     rbx, -8

    mov     r12, [r13]      ; Load current_chunk
    test    r12, r12
    jz      alloc_root_chunk

check_space:
    mov     rax, [r12 + 16] ; Load current offset
    mov     rcx, rax
    add     rcx, rbx        ; Compute new offset
    cmp     rcx, [r12 + 8]  ; Compare with capacity
    ja      next_or_grow

    ; Space available in current chunk
    lea     rdx, [r12 + 24]
    add     rax, rdx        ; Return payload pointer
    mov     [r12 + 16], rcx ; Update offset
    ret

next_or_grow:
    ; Check if a pre-existing next chunk is already chained
    mov     rax, [r12]      
    test    rax, rax
    jz      grow_new_chunk

    ; Reuse existing chunk down the chain
    mov     r12, rax
    mov     [r13], r12      ; Update current_chunk pointer
    mov     qword ptr [r12 + 16], 0 ; Reset its offset for reuse
    jmp     check_space

alloc_root_chunk:
grow_new_chunk:
    mov     rsi, 65536      ; Default 64KB chunk size
    cmp     rbx, rsi
    jle     use_default
    mov     rsi, rbx
    add     rsi, 24         ; Account for header size

use_default:
    mov     rax, SYS_MMAP
    xor     rdi, rdi
    mov     rdx, PROT_READ or PROT_WRITE
    mov     r10, MAP_PRIVATE or MAP_ANON
    mov     r8, -1
    xor     r9, r9
    syscall

    cmp     rax, -4096
    ja      mmap_failed

    ; Initialize new chunk header
    mov     qword ptr [rax], 0      ; next_chunk = NULL
    mov     rdx, rsi
    sub     rdx, 24
    mov     qword ptr [rax + 8], rdx  ; capacity
    mov     qword ptr [rax + 16], rbx ; offset = requested size

    test    r12, r12
    jz      is_root
    mov     [r12], rax              ; old_chunk->next = new_chunk
    jmp     update_head

is_root:
    mov     [r13 + 8], rax          ; Set root_chunk pointer if first time

update_head:
    mov     [r13], rax              ; current_chunk = new_chunk

    lea     rax, [rax + 24]
    ret

mmap_failed:
    xor     rax, rax
    ret
arena_alloc endp

; ------------------------------------------------------------------------------
; arena_reset
; Performs a fast retained reset, resetting chunk offsets to 0 and restoring 
; the current head back to the root chunk without any syscalls.
; 
; Input:
;   rdi = pointer to arena descriptor
; ------------------------------------------------------------------------------
arena_reset PROC USES rbx
    mov     rbx, [rdi + 8]  ; Load root_chunk pointer
    mov     [rdi], rbx      ; Reset current_chunk to root_chunk

reset_loop:
    test    rbx, rbx
    jz      reset_done

    mov     qword ptr [rbx + 16], 0 ; Reset offset to 0
    mov     rbx, [rbx]      ; Traverse to next chunk
    jmp     reset_loop

reset_done:
    ret
arena_reset endp

; ------------------------------------------------------------------------------
; arena_secure_reset
; Securely wipes active payload bytes with zeros across all linked chunks 
; before resetting offsets. Ideal for sensitive buffers, keys, or passwords.
; 
; Input:
;   rdi = pointer to arena descriptor
; ------------------------------------------------------------------------------
arena_secure_reset PROC USES rbx rdi rsi rcx
    mov     rbx, [rdi + 8]  ; Load root_chunk pointer
    mov     r10, rdi        ; Preserve descriptor pointer

secure_reset_loop:
    test    rbx, rbx
    jz      secure_reset_done

    mov     rcx, [rbx + 16] ; Load active payload size (offset)
    test    rcx, rcx
    jz      skip_zero_fill

    ; Securely zero out used payload space
    lea     rdi, [rbx + 24]     
    xor     al, al              
    rep     stosb               

skip_zero_fill:
    mov     qword ptr [rbx + 16], 0 
    mov     rbx, [rbx]      
    jmp     secure_reset_loop

secure_reset_done:
    mov     rax, [r10 + 8]
    mov     [r10], rax      ; Reset current_chunk to root_chunk
    ret
arena_secure_reset endp


;==============================================================================
; ALLOC
;   Allocates memory from an arena.
;
; Parameters:
;   requested_size:qword - The size of the memory block to allocate in bytes.
;
; Returns:
;   rax = pointer to the allocated memory block, or null if allocation fails.
;==============================================================================

PUBLIC ALLOC
ALLOC PROC requested_size:qword
    mov     rdi, requested_size     ; 1st argument -> rdi (Linux ABI)
    lea     rsi, arena              ; 2nd argument -> rsi (Linux ABI)
    call    arena_alloc             ; Direct register call
    ret
ALLOC endp
end