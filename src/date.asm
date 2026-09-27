OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

PUBLIC DATE$
PUBLIC ISODATE$
; -----------------------------------------------------------------------------
; Name:         format_date
; Description:  Formats date into str_buf based on format type and allocates via arena
; Input:        rdi = format flag (0 = MM-DD-YYYY, 1 = YYYY-MM-DD)
; Returns:      rax = Pointer to arena-allocated string, or 0 on failure
; -----------------------------------------------------------------------------
format_date PROC USES rbx r12 r13 r14 r15
    local normal_days[12]:byte
    local leap_days[12]:byte
    local raw_time:qword
    local tz_offset:qword
    local tv:qword, tz:qword        ; timeval / timezone structs space
    local year_val:qword
    local month_val:qword
    local day_val:qword
    local fmt_type:qword
    local str_buf[16]:byte

    mov       fmt_type, rdi

    ; --- Store days-in-month as bytes directly (Normal year) ---
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

    ; --- Store days-in-month as bytes directly (Leap year) ---
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

    ; --- 1. Fetch current epoch time via Linux sys_time (syscall 201) ---
    mov       rax, 201          
    xor       rdi, rdi          
    syscall                   
    mov       raw_time, rax   ; Save raw UTC time

    ; --- 2. Get timezone offset dynamically ---
    lea       rdi, tv             ; struct timeval
    lea       rsi, tz             ; struct timezone
    mov       rax, 96             ; sys_gettimeofday
    syscall
    test      rax, rax
    jnz       use_utc             ; If syscall fails, use UTC

    ; Extract timezone offset from struct timezone
    movsxd    rax, dword ptr [tz]     ; tz_minuteswest (signed int)
    imul      rax, rax, 60            ; Convert minutes to seconds
    neg       rax                     ; Convert to seconds east of UTC
    mov       tz_offset, rax          ; Save timezone offset

    ; Check if DST is active (tz_dsttime is offset 4 in struct timezone)
    mov       eax, dword ptr [tz + 4]  
    test      eax, eax
    je        apply_offset
    
    ; If DST is active, add 3600 seconds (1 hour)
    add       tz_offset, 3600

apply_offset:
    ; Apply timezone offset to UTC time
    mov       rax, raw_time
    add       rax, tz_offset
    jmp       time_adjusted

use_utc:
    ; Fallback to UTC if gettimeofday fails
    mov       rax, raw_time

time_adjusted:
    ; Now convert to days
    xor       rdx, rdx
    mov       rcx, 86400              ; Seconds per day
    div       rcx                     
    mov       r8, rax                 ; r8 = total days since 1970-01-01

    ; --- 3. Calculate Gregorian Year ---
    mov       r9, 1970                ; Starting year

year_loop:
    mov       rax, r9
    and       rax, 3                  ; year % 4
    jnz       is_not_leap             

    mov       rax, r9
    xor       rdx, rdx
    mov       rcx, 100
    div       rcx
    test      rdx, rdx
    jnz       is_leap                 ; Not divisible by 100, but divisible by 4

    ; Divisible by 100 - check if divisible by 400
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
    mov       year_val, r9   ; Save calculated Year

    ; --- 4. Select Month Table (Normal vs Leap) ---
    mov       rax, r9
    and       rax, 3
    jnz       sel_normal
    mov       rax, r9
    xor       rdx, rdx
    mov       rcx, 100
    div       rcx
    test      rdx, rdx
    jnz       sel_leap
    mov       rax, r9
    xor       rdx, rdx
    mov       rcx, 400
    div       rcx
    test      rdx, rdx
    jz        sel_leap

sel_normal:
    lea       rsi, normal_days        ; Normal table pointer
    jmp       got_table

sel_leap:
    lea       rsi, leap_days          ; Leap table pointer

got_table:
    xor       rcx, rcx                ; Month index counter (0 to 11)

month_loop:
    movzx     rdx, byte ptr [rsi + rcx]    
    cmp       r8, rdx
    jb        month_found
    sub       r8, rdx                 
    inc       rcx
    cmp       rcx, 12
    jl        month_loop
    jmp       date_error

month_found:
    inc       rcx                     ; Month (1 - 12)
    inc       r8                      ; Day of month (1 - 31)

    mov       month_val, rcx          ; Save Month
    mov       day_val, r8             ; Save Day

    ; --- 5. Format String Based on Selection ---
    mov       rax, fmt_type
    test      rax, rax
    jnz       format_iso_layout

    ; Format: MM-DD-YYYY
    mov       rax, month_val
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 0], al
    mov       byte ptr [str_buf + 1], dl
    mov       byte ptr [str_buf + 2], '-'

    mov       rax, day_val
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 3], al
    mov       byte ptr [str_buf + 4], dl
    mov       byte ptr [str_buf + 5], '-'

    mov       rax, year_val
    xor       rdx, rdx
    mov       rcx, 1000
    div       rcx
    add       al, '0'
    mov       byte ptr [str_buf + 6], al
    mov       rax, rdx

    xor       rdx, rdx
    mov       rcx, 100
    div       rcx
    add       al, '0'
    mov       byte ptr [str_buf + 7], al
    mov       rax, rdx

    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    mov       byte ptr [str_buf + 8], al

    add       dl, '0'
    mov       byte ptr [str_buf + 9], dl
    mov       byte ptr [str_buf + 10], 0
    jmp       do_allocate

format_iso_layout:
    ; Format: YYYY-MM-DD
    mov       rax, year_val
    xor       rdx, rdx
    mov       rcx, 1000
    div       rcx
    add       al, '0'
    mov       byte ptr [str_buf + 0], al
    mov       rax, rdx

    xor       rdx, rdx
    mov       rcx, 100
    div       rcx
    add       al, '0'
    mov       byte ptr [str_buf + 1], al
    mov       rax, rdx

    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    mov       byte ptr [str_buf + 2], al

    add       dl, '0'
    mov       byte ptr [str_buf + 3], dl
    mov       byte ptr [str_buf + 4], '-'

    mov       rax, month_val
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 5], al
    mov       byte ptr [str_buf + 6], dl
    mov       byte ptr [str_buf + 7], '-'

    mov       rax, day_val
    xor       rdx, rdx
    mov       rcx, 10
    div       rcx
    add       al, '0'
    add       dl, '0'
    mov       byte ptr [str_buf + 8], al
    mov       byte ptr [str_buf + 9], dl
    mov       byte ptr [str_buf + 10], 0

do_allocate:
    ; --- 6. Allocate from Arena & Copy ---
    mov       rdi, 11                 ; Length (10 chars + NUL)
    lea       rsi, [arena]
    call      arena_alloc

    test      rax, rax
    jz        date_fail

    mov       rdi, rax                ; Destination = arena buffer
    lea       rsi, str_buf            ; Source = stack buffer
    mov       rcx, 11                 ; Copy bytes including NUL
    cld
    rep       movsb

    sub       rdi, 11
    mov       rax, rdi                ; Return arena string pointer
    jmp       date_exit

date_error:
date_fail:
    xor       rax, rax                ; Return NULL on failure

date_exit:
    ret
format_date ENDP

; --- Public Entry Points ---

;
;==============================================================================
; DATE$
;   Retrieves the current date in "MM-DD-YYYY" format and returns it as a string.
;
; Parameters:
;   None
;
; Returns:
;   rax = Pointer to the newly allocated string containing the formatted date, 
;   or null if allocation fails.
;==============================================================================

PUBLIC DATE$
DATE$ PROC
    xor       rdi, rdi                ; 0 = MM-DD-YYYY format flag
    call      format_date
    ret
DATE$ ENDP


;
;==============================================================================
; ISODATE$
;   Retrieves the current date in "YYYY-MM-DD" ISO format and returns it as a string.
;
; Parameters:
;   None
;
; Returns:
;   rax = Pointer to the newly allocated string containing the formatted date, 
;   or null if allocation fails.
;==============================================================================

PUBLIC ISODATE$
ISODATE$ PROC
    mov       rdi, 1                  ; 1 = YYYY-MM-DD format flag
    call      format_date
    ret
ISODATE$ ENDP

END
