OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

; Constants for Linux Kernel File System Calls (x86_64)
SYS_OPEN        EQU 2
SYS_CLOSE       EQU 3
SYS_WRITE       EQU 1

.code

; -----------------------------------------------------------------------------
; Name:         SAVEFILE
; Description:  Saves a null-terminated string to a file, automatically appending 
;               a newline (line feed, 0x0A) character at the end.
; C Prototype:  int64_t SAVEFILE(const char* filepath, const char* s);
; Parameters:   rdi = pointer to null-terminated file path string (filepath)
;               rsi = pointer to string data (normal C string)
; Returns:      rax = 1 on success, 0 on failure
; -----------------------------------------------------------------------------
PUBLIC SAVEFILE

SAVEFILE PROC USES rbx r12 r13 r14 filePath:ptr, srcString:ptr
    local filepath_ptr:qword
    local str_ptr:qword
    local str_len:qword
    local file_desc:qword
    local newline_char:byte

    mov       filepath_ptr, filePath         ; r12 = filepath pointer
    mov       r12, filePath
    mov       str_ptr, srcString              ; r13 = string pointer
    mov       r13, srcString

    ; Edge case check for NULL pointers
    test      r12, r12
    jz        save_fail
    test      r13, r13
    jz        save_fail

    ; --- 1. Determine string length via null-termination scan ---
    xor       rax, rax                  ; len = 0
    mov       r14, rax
str_len_loop:
    mov       rax, str_ptr
    mov       al, byte ptr [rax + r14]
    test      al, al
    jz        str_len_done
    inc       r14
    jmp       str_len_loop
str_len_done:

    mov       rax, r14
    test      rax, rax
    jz        save_fail                 ; If length is 0, nothing to save
    mov       str_len, r14

    ; --- 2. Open/Create file (sys_open: rax=2, rdi=filename, rsi=flags, rdx=mode) ---
    mov       rax, SYS_OPEN
    mov       rdi, r12
    mov       rsi, 65                   ; O_WRONLY(1) | O_CREAT(64)
    or        rsi, 512                  ; O_TRUNC (512) -> total 577
    mov       rdx, 420                  ; 420 decimal = 0644 octal permissions
    syscall

    cmp       rax, 0
    jl        save_fail                 ; If rax is negative, open failed
    mov       file_desc, rax            ; rbx = file descriptor (fd)
    mov       rbx, rax

    ; --- 3. Write main string data using sys_write ---
    mov       rax, SYS_WRITE
    mov       rdi, rbx
    mov       rsi, str_ptr
    mov       rdx, str_len              ; length of string
    syscall

    cmp       rax, 0
    jl        save_close_fail           ; If rax < 0, write failed

    ; --- 4. Write enforced line feed (0x0A) ---
    mov       byte ptr [newline_char], 0Ah       ; Line feed character
    
    mov       rax, SYS_WRITE
    mov       rdi, rbx
    lea       rsi, newline_char                  ; Source pointer to line feed byte
    mov       rdx, 1                             ; 1 byte length
    syscall

    cmp       rax, 0
    jl        save_close_fail           ; If rax < 0, write failed

    ; --- 5. Close file descriptor (sys_close: rax=3, rdi=fd) ---
    mov       rax, SYS_CLOSE
    mov       rdi, rbx
    syscall

    mov       rax, 1                    ; Return success (1)
    jmp       save_exit

save_close_fail:
    mov       rax, SYS_CLOSE
    mov       rdi, rbx
    syscall

save_fail:
    xor       rax, rax                  ; Return failure (0)

save_exit:
    ret
SAVEFILE ENDP

END