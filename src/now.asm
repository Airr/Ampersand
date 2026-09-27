OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; Name:         NOW$
; Description:  Returns current local date and time as "MM/DD/YY HH:MM:SS AM/PM"
;               via pure Linux syscalls, resolving the correct local timezone offset 
;               by parsing /etc/localtime transition times without using libc.
; C Prototype:  char* NOW(void);
; Returns:      rax - Pointer to a new arena-allocated string containing the formatted timestamp
; -----------------------------------------------------------------------------
PUBLIC NOW$

NOW$ PROC USES rbx r12 r13 r14 r15
    local tv_sec:qword
    local tv_usec:qword
    local tz_offset:qword
    local raw_time:qword
    local year_val:qword
    local month_val:qword
    local am_pm_buf[2]:byte
    local normal_days[12]:byte
    local leap_days[12]:byte
    local str_buf[32]:byte
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

    ; Parse TZif header counts (32-bit big-endian fields)
    mov       r8d, dword ptr [rsi + 32]  ; timecnt
    bswap     r8d
    mov       r9d, dword ptr [rsi + 36]  ; typecnt
    bswap     r9d
    test      r9d, r9d
    jle       skip_tz_parse

    ; Find which transition period current `tv_sec` falls into by scanning transition times
    xor       rcx, rcx                   ; rcx = transition index loop counter
    mov       r10, -1                    ; r10 = active transition type index (default -1)

find_transition_loop:
    cmp       rcx, r8                    ; compare with tzh_timecnt
    jge       transitions_scanned

    ; Read 4-byte transition time at 44 + 4*rcx using valid base+index addressing
    lea       rax, file_buf
    mov       edx, dword ptr [rax + rcx*4 + 44]
    bswap     edx
    movsxd    rdx, edx                   ; rdx = transition timestamp (epoch seconds)

    mov       rax, tv_sec
    cmp       rax, rdx
    jl        transition_found_index     ; if current time < transition time, we found our bracket

    ; Read corresponding transition type index at 44 + 4*r8d + rcx
    mov       rax, 4
    imul      rax, r8                    ; 4 * timecnt
    add       rax, 44
    add       rax, rcx                   ; rax = offset to type index
    lea       rsi, file_buf
    movzx     r10d, byte ptr [rsi + rax] ; r10d = type index

    inc       rcx
    jmp       find_transition_loop

transition_found_index:
    jmp       fetch_ttinfo

transitions_scanned:
    test      r8, r8
    jz        fetch_ttinfo
    ; Get last transition type index
    mov       rax, 4
    imul      rax, r8
    add       rax, 44
    dec       r8                         ; adjusted last index offset
    add       rax, r8
    lea       rsi, file_buf
    movzx     r10d, byte ptr [rsi + rax]
    jmp       fetch_ttinfo

fetch_ttinfo:
    cmp       r10, 0
    jl        default_first_type
    cmp       r10, r9                    ; ensure index < typecnt
    jge       default_first_type
    jmp       calc_ttinfo_offset

default_first_type:
    xor       r10, r10

calc_ttinfo_offset:
    ; Re-read timecnt from header to compute exact ttinfo base offset
    lea       rsi, file_buf
    mov       r8d, dword ptr [rsi + 32]
    bswap     r8d
    
    mov       rax, 4
    imul      rax, r8                    ; 4 * timecnt
    add       rax, 44                    ; header + transitions
    add       rax, r8                    ; + 1 * timecnt (type indices)
    
    ; Each ttinfo struct is 6 bytes: 4 bytes utoff, 1 byte isdst, 1 byte desigidx
    mov       rcx, 6
    imul      rcx, r10                   ; 6 * type_index
    add       rax, rcx                   
    
    cmp       rax, r15
    jge       skip_tz_parse

    lea       rsi, file_buf
    add       rsi, rax
    mov       eax, dword ptr [rsi]       ; read 4-byte utoff (big-endian seconds east of UTC)
    bswap     eax
    movsxd    rax, eax                   
    
    ; Convert seconds east of UTC to offset
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
    div       rcx
    mov       r8, rax                    ; r8 = total days since epoch

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
    dec       r8                         ; adjust day backwards if hours became negative

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

    ; --- 5. Calculate Gregorian Year, Month, and Day ---
    mov       r9, 1970

year_loop:
    mov       rax, r9
    and       rax, 3
    jnz       is_not_leap

    mov       rax, r9
    xor       rdx, rdx
    mov       rcx, 100
    div       rcx
    test      rdx, rdx
    jz        check_400

    mov       rcx, 366
    jmp       got_year_days

check_400:
    mov       rax, r9
    xor       rdx, rdx
    mov       rcx, 400
    div       rcx
    test      rdx, rdx
    jz        is_leap

is_not_leap:
    mov       rcx, 365
    jmp       got_year_days

is_leap:
    mov       rcx, 366

got_year_days:
    cmp       r8, rcx
    jb        year_found
    sub       r8, rcx
    inc       r9
    jmp       year_loop

year_found:
    mov       year_val, r9

    ; --- 6. Select Month Table (Normal vs Leap) ---
    lea       rbx, normal_days
    mov       byte ptr [rbx + 0], 31
    mov       byte ptr [rbx + 1], 28
    mov       byte ptr [rbx + 2], 31
    mov       byte ptr [rbx + 3], 30
    mov       byte ptr [rbx + 4], 31
    mov       byte ptr [rbx + 5], 30
    mov       byte ptr [rbx + 6], 31
    mov       byte ptr [rbx + 7], 31
    mov       byte ptr [rbx + 8], 30
    mov       byte ptr [rbx + 9], 31
    mov       byte ptr [rbx + 10], 30
    mov       byte ptr [rbx + 11], 31

    lea       rbx, leap_days
    mov       byte ptr [rbx + 0], 31
    mov       byte ptr [rbx + 1], 29
    mov       byte ptr [rbx + 2], 31
    mov       byte ptr [rbx + 3], 30
    mov       byte ptr [rbx + 4], 31
    mov       byte ptr [rbx + 5], 30
    mov       byte ptr [rbx + 6], 31
    mov       byte ptr [rbx + 7], 31
    mov       byte ptr [rbx + 8], 30
    mov       byte ptr [rbx + 9], 31
    mov       byte ptr [rbx + 10], 30
    mov       byte ptr [rbx + 11], 31

    mov       rax, year_val
    and       rax, 3
    jnz       sel_normal
    mov       rax, year_val
    xor       rdx, rdx
    mov       rcx, 100
    div       rcx
    test      rdx, rdx
    jz        chk_400_m
    lea       rsi, leap_days
    jmp       got_table
chk_400_m:
    mov       rax, year_val
    xor       rdx, rdx
    mov       rcx, 400
    div       rcx
    test      rdx, rdx
    jz        sel_leap
sel_normal:
    lea       rsi, normal_days
    jmp       got_table
sel_leap:
    lea       rsi, leap_days

got_table:
    xor       rcx, rcx

month_loop:
    movzx     rdx, byte ptr [rsi + rcx]
    cmp       r8, rdx
    jb        month_found
    sub       r8, rdx
    inc       rcx
    cmp       rcx, 12
    jl        month_loop
    jmp       now_error

month_found:
    inc       rcx
    inc       r8
    mov       month_val, rcx

    ; --- 7. Format into "MM/DD/YY HH:MM:SS AM" string on stack ---
    mov       rax, month_val
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 0], al
    mov       byte ptr [str_buf + 1], dl
    mov       byte ptr [str_buf + 2], '/'

    mov       rax, r8
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 3], al
    mov       byte ptr [str_buf + 4], dl
    mov       byte ptr [str_buf + 5], '/'

    mov       rax, year_val
    xor       rdx, rdx
    mov       rcx, 100
    div       rcx
    mov       rax, rdx
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 6], al
    mov       byte ptr [str_buf + 7], dl
    mov       byte ptr [str_buf + 8], ' '

    mov       rax, r12
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 9], al
    mov       byte ptr [str_buf + 10], dl
    mov       byte ptr [str_buf + 11], ':'

    mov       rax, r13
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 12], al
    mov       byte ptr [str_buf + 13], dl
    mov       byte ptr [str_buf + 14], ':'

    mov       rax, r14
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 15], al
    mov       byte ptr [str_buf + 16], dl
    mov       byte ptr [str_buf + 17], ' '

    mov       al, byte ptr [am_pm_buf + 0]
    mov       dl, byte ptr [am_pm_buf + 1]
    mov       byte ptr [str_buf + 18], al
    mov       byte ptr [str_buf + 19], dl
    mov       byte ptr [str_buf + 20], 0  ; NUL terminator

    ; --- 8. Allocate space via arena_alloc (21 bytes including NUL) ---
    mov       rdi, 21
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        now_error
    mov       new_str, rax
    mov       r15, rax

    ; Copy from stack buffer to arena-allocated string
    xor       rcx, rcx
copy_loop:
    cmp       rcx, 21
    jge       now_success
    mov       al, byte ptr [str_buf + rcx]
    mov       byte ptr [r15 + rcx], al
    inc       rcx
    jmp       copy_loop

now_success:
    mov       rax, new_str
    jmp       now_exit

now_error:
    xor       rax, rax

now_exit:
    ret
NOW$ ENDP

path_etc_localtime db "/etc/localtime", 0

END