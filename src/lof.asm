; -----------------------------------------------------------------------------
; Name:         LOF (Length of File)
; Description:  Retrieves the size of a file given its file path string.
;               Mirrors BASIC's LOF function using Linux system calls.
; C Prototype:  int64_t LOF(const char* filepath);
; Parameters:   rdi - Pointer to a null-terminated C string (filepath)
; Returns:      rax - File size in bytes on success, or 0 on failure.
; -----------------------------------------------------------------------------
OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; Constants for Linux Kernel File System Calls
SYS_OPEN        EQU 2
SYS_CLOSE       EQU 3
SYS_FSTAT       EQU 5
O_RDONLY        EQU 0

PUBLIC LOF

LOF PROC USES rbx r12 r13 r14 path:ptr
    local file_desc:qword
    local file_size:qword
    local stat_buf[144]:byte

    mov     r12, path                ; r12 = filepath pointer passed from Caller

    ; --- 1. Open file (sys_open) ---
    mov     rax, SYS_OPEN
    mov     rdi, r12
    xor     rsi, rsi                ; O_RDONLY = 0
    xor     rdx, rdx
    syscall

    cmp     rax, -4095
    jae     load_fail               ; Jump if syscall returned an error
    mov     file_desc, rax          ; rbx = file descriptor (fd)
    mov     rbx, rax

    ; --- 2. Get file info using sys_fstat ---
    mov     rax, SYS_FSTAT
    mov     rdi, rbx
    lea     rsi, stat_buf
    syscall

    cmp     rax, -4095
    jae     load_close_fail         ; Jump if fstat failed
    
    ; --- 3. Extract st_size from struct stat (offset 48) ---
    mov     rax, qword ptr [stat_buf + 48]  ; r13 = file size
    mov     file_size, rax
    mov     r13, rax

    ; --- 4. Close file ---
    mov     rax, SYS_CLOSE
    mov     rdi, rbx
    syscall

    mov     rax, file_size          ; Move file size into rax as the return value
    jmp     load_exit

load_close_fail:                    ; Attempt to close fd if fstat failed    
    mov     rax, SYS_CLOSE
    mov     rdi, rbx
    syscall

load_fail:
    mov     rax, -1                ; Return -1 on failure

load_exit:
    ret    
LOF ENDP

END