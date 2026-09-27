OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; Constants for Linux Kernel File System Calls
SYS_OPEN        EQU 2
SYS_CLOSE       EQU 3
SYS_FSTAT       EQU 5
SYS_READ        EQU 0
O_RDONLY        EQU 0

; -----------------------------------------------------------------------------
; char* LOADFILE$(const char* filepath)
; Loads an entire file into a newly arena-allocated string.
; Input:  rdi = pointer to null-terminated file path string
; Output: rax = pointer to new arena string payload, or NULL on failure
; -----------------------------------------------------------------------------

PUBLIC LOADFILE$

LOADFILE$ PROC USES rbx r12 r13 r14 filePath:ptr
    local file_desc:qword
    local file_size:qword
    local sds_ptr:qword
    local stat_buf[144]:byte

    mov       r12, filePath                  ; r12 = filepath pointer

    ; --- 1. Open file (sys_open) ---
    mov       rax, SYS_OPEN
    mov       rdi, r12
    xor       rsi, rsi                  ; O_RDONLY = 0
    xor       rdx, rdx
    syscall

    cmp       rax, -4095
    jae       load_fail
    mov       file_desc, rax            ; rbx = file descriptor (fd)
    mov       rbx, rax

    ; --- 2. Get file size using sys_fstat ---
    mov       rax, SYS_FSTAT
    mov       rdi, rbx
    lea       rsi, stat_buf
    syscall

    cmp       rax, -4095
    jae       load_close_fail

    ; File size (st_size) is located at offset 48 in the standard Linux stat structure
    mov       rax, qword ptr [stat_buf + 48] ; r13 = file size in bytes
    mov       file_size, rax
    mov       r13, rax

    ; --- 3. Allocate space via arena_alloc (file_size bytes + 1 for NUL terminator) ---
    mov       rax, r13
    inc       rax
    mov       rdi, rax                  ; length including NUL
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        load_close_fail
    mov       sds_ptr, rax              ; r14 = arena payload pointer
    mov       r14, rax

    ; --- 4. Read file content directly into arena payload ---
    mov       rax, SYS_READ
    mov       rdi, rbx
    mov       rsi, r14
    mov       rdx, r13
    syscall

    ; --- 5. Close file descriptor (sys_close) ---
    mov       rax, SYS_CLOSE
    mov       rdi, rbx
    syscall

    ; Ensure null terminator at payload[file_size]
    mov       rax, file_size
    mov       byte ptr [r14 + rax], 0

    mov       rax, sds_ptr              ; Return arena string pointer
    jmp       load_exit

load_close_fail:
    ; Attempt to close fd if it was opened
    mov       rax, SYS_CLOSE
    mov       rdi, rbx
    syscall

load_fail:
    xor       rax, rax                  ; Return NULL on failure

load_exit:
    ret
LOADFILE$ ENDP

END
