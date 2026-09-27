OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.data
    path_etc_localtime db "/etc/localtime", 0

.code

; -----------------------------------------------------------------------------
; Name:         TIME$
; Description:  Returns current local time as "HH:MM:SS AM/PM" via pure Linux syscalls,
;               automatically resolving the correct local timezone offset by parsing 
;               /etc/localtime 64-bit TZif transition times without using libc.
; C Prototype:  char* TIME$(void);
; Returns:      rax - Pointer to a new arena-allocated string containing the formatted time
; -----------------------------------------------------------------------------
PUBLIC TIME$

TIME$ PROC USES rbx r12 r13 r14 r15
    local tv_sec:qword
    local tv_usec:qword
    local tz_offset:qword
    local raw_time:qword
    local am_pm_buf[2]:byte
    local str_buf[16]:byte
    local file_buf[2048]:byte
    local new_str:qword

    ; --- 1. Fetch current epoch time via sys_gettimeofday (syscall 96) ---
    mov       rax, 96                    ; sys_gettimeofday
    lea       rdi, tv_sec                ; pointer to struct timeval
    xor       rsi, rsi                   ; tz = NULL
    syscall

    ; Default timezone offset to 0 (UTC) if parsing fails
    mov       qword ptr [tz_offset], 0

    ; --- 2. Read /etc/localtime to parse TZif transitions and find active offset ---
    mov       rax, 2                     ; sys_open
    lea       rdi, path_etc_localtime    ; filename "/etc/localtime"
    xor       rsi, rsi                   ; O_RDONLY
    xor       rdx, rdx
    syscall
    test      rax, rax
    js        skip_tz_parse              ; if open failed, default to UTC
    mov       rbx, rax                   ; save file descriptor in rbx

    mov       rax, 0                     ; sys_read
    mov       rdi, rbx                   ; fd
    lea       rsi, file_buf              ; buffer
    mov       rdx, 2048                  ; count
    syscall
    mov       r15, rax                   ; save bytes read

    mov       rax, 3                     ; sys_close
    mov       rdi, rbx
    syscall

    test      r15, r15
    jle       skip_tz_parse

    ; Verify 'TZif' magic bytes at offset 0
    lea       rsi, file_buf
    mov       al, byte ptr [rsi + 0]
    cmp       al, 'T'
    jne       skip_tz_parse

    ; Check for TZif v2/v3 second header (64-bit transition block)
    mov       rcx, 4
search_second_header:
    lea       rax, file_buf
    add       rax, rcx
    cmp       rcx, 1024                  ; safety limit
    jge       parse_32bit_block          ; fallback to 32-bit if not found
    
    mov       edx, dword ptr [rax]
    cmp       edx, 0x66695A54            ; 'TZif' in little endian
    je        found_64bit_header
    inc       rcx
    jmp       search_second_header

found_64bit_header:
    lea       rsi, file_buf
    add       rsi, rcx                   ; rsi points to second TZif header
    mov       r11, rcx                   ; save second header offset

    ; Read counts from second header
    mov       r8d, dword ptr [rsi + 32]  ; timecnt (64-bit block timecnt)
    bswap     r8d
    mov       r9d, dword ptr [rsi + 36]  ; typecnt
    bswap     r9d
    test      r9d, r9d
    jle       skip_tz_parse

    ; 64-bit transition times start at second header + 44
    lea       rdx, [rsi + 44]            ; rdx = pointer to 64-bit transition array
    xor       rcx, rcx                   ; loop counter i = 0
    xor       r10, r10                   ; active type index default 0

find_trans_64:
    cmp       rcx, r8
    jge       fetch_ttinfo_64

    mov       rax, qword ptr [rdx + rcx*8]
    bswap     rax                        ; rax = transition epoch seconds

    mov       rdi, tv_sec
    cmp       rdi, rax
    jl        fetch_ttinfo_64            ; if tv_sec < transition, current r10 is correct

    ; Read transition type index for this transition
    push      rdx
    push      rcx
    mov       rax, 8
    imul      rax, r8                    ; 8 * timecnt
    add       rax, 44
    add       rax, rcx
    lea       rdi, file_buf
    add       rdi, r11
    movzx     r10d, byte ptr [rdi + rax]
    pop       rcx
    pop       rdx

    inc       rcx
    jmp       find_trans_64

parse_32bit_block:
    lea       rsi, file_buf
    mov       r8d, dword ptr [rsi + 32]
    bswap     r8d
    mov       r9d, dword ptr [rsi + 36]
    bswap     r9d
    test      r9d, r9d
    jle       skip_tz_parse

    lea       rdx, [rsi + 44]            ; 32-bit transition array
    xor       rcx, rcx
    xor       r10, r10

find_trans_32:
    cmp       rcx, r8
    jge       fetch_ttinfo_32

    mov       eax, dword ptr [rdx + rcx*4]
    bswap     eax
    movsxd    rax, eax

    mov       rdi, tv_sec
    cmp       rdi, rax
    jl        fetch_ttinfo_32

    push      rdx
    push      rcx
    mov       rax, 4
    imul      rax, r8                    ; 4 * timecnt
    add       rax, 44
    add       rax, rcx
    lea       rdi, file_buf
    movzx     r10d, byte ptr [rdi + rax]
    pop       rcx
    pop       rdx

    inc       rcx
    jmp       find_trans_32

fetch_ttinfo_32:
    mov       rax, 4
    imul      rax, r8                    ; 4 * timecnt
    add       rax, 44                    ; header + transitions
    add       rax, r8                    ; + type indices
    jmp       calc_ttinfo_offset_common

fetch_ttinfo_64:
    mov       rax, 8
    imul      rax, r8                    ; 8 * timecnt
    add       rax, 44                    ; header + transitions
    add       rax, r8                    ; + type indices
    add       rax, r11                   ; add second header base offset

calc_ttinfo_offset_common:
    mov       rcx, 6
    imul      rcx, r10                   ; 6 * type_index
    add       rax, rcx

    cmp       rax, r15
    jge       skip_tz_parse

    lea       rsi, file_buf
    add       rsi, rax
    mov       eax, dword ptr [rsi]       ; read 4-byte utoff (seconds east of UTC)
    bswap     eax
    movsxd    rax, eax
    mov       tz_offset, rax

skip_tz_parse:
    ; --- 3. Adjust UTC epoch time by determined timezone seconds ---
    mov       rax, tv_sec
    add       rax, tz_offset             ; add offset seconds directly
    mov       raw_time, rax

    ; --- 4. Extract Time Components from Adjusted Epoch Seconds ---
    mov       rax, raw_time
    
    xor       rdx, rdx
    mov       rcx, 86400
    div       rcx                        ; rdx = seconds into current day

    mov       rax, rdx                  
    xor       rdx, rdx
    mov       rcx, 3600                 
    div       rcx
    mov       r12, rax                   ; r12 = hours (0 - 23)

    mov       rax, rdx                  
    xor       rdx, rdx
    mov       rcx, 60                   
    div       rcx
    mov       r13, rax                   ; r13 = Minutes (0 - 59)
    mov       r14, rdx                   ; r14 = Seconds (0 - 59)

    ; Handle potential negative hours if offset wrapped backwards past midnight
    test      r12, r12
    jns       hour_positive
    add       r12, 24

hour_positive:
    ; Convert 24-hour format to 12-hour format + AM/PM flag
    mov       byte ptr [am_pm_buf + 0], 'A'
    mov       byte ptr [am_pm_buf + 1], 'M'

    cmp       r12, 12
    jb        is_am
    mov       byte ptr [am_pm_buf + 0], 'P'  
    sub       r12, 12                     
is_am:
    cmp       r12, 0
    jne       hour_done
    mov       r12, 12                     
hour_done:

    ; --- 5. Format into "HH:MM:SS AM" string on stack ---
    mov       rax, r12
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 0], al
    mov       byte ptr [str_buf + 1], dl
    mov       byte ptr [str_buf + 2], ':'

    mov       rax, r13
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 3], al
    mov       byte ptr [str_buf + 4], dl
    mov       byte ptr [str_buf + 5], ':'

    mov       rax, r14
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 6], al
    mov       byte ptr [str_buf + 7], dl
    mov       byte ptr [str_buf + 8], ' '

    mov       al, byte ptr [am_pm_buf + 0]
    mov       dl, byte ptr [am_pm_buf + 1]
    mov       byte ptr [str_buf + 9], al
    mov       byte ptr [str_buf + 10], dl
    mov       byte ptr [str_buf + 11], 0  ; Null terminator for safety

    ; --- 6. Allocate Space via arena_alloc (11 bytes + 1 for NUL) ---
    mov       rdi, 12                   
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        time_error
    mov       new_str, rax
    mov       r15, rax                  ; r15 = destination pointer

    ; --- 7. Copy formatted time string into arena buffer ---
    xor       rcx, rcx
time_copy_loop:
    cmp       rcx, 11
    jge       time_success
    mov       al, byte ptr [str_buf + rcx]
    mov       byte ptr [r15 + rcx], al
    inc       rcx
    jmp       time_copy_loop

time_success:
    mov       byte ptr [r15 + 11], 0    ; Ensure null termination
    mov       rax, new_str
    jmp       time_exit

time_error:
    xor       rax, rax                  

time_exit:
    ret
TIME$ ENDP

END