OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn LEN           :PROC

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code

; -----------------------------------------------------------------------------
; char* left(const char* s, size_t count)
; Returns a newly arena-allocated string containing the leftmost 'count' characters of 's'.
; Input:  rdi = pointer to source string payload (s)
;         rsi = count of characters to extract (qword)
; Output: rax = pointer to new arena-allocated string payload
; -----------------------------------------------------------------------------

PUBLIC LEFT$

LEFT$ PROC USES rbx r12 r13 r14 srcString:ptr, numBytes:qword
    local src_str:qword
    local req_count:qword
    local dest_str:qword

    mov       src_str, rdi
    mov       rbx, rdi                  ; rbx = source string pointer
    mov       req_count, rsi
    mov       r12, rsi                  ; r12 = requested count

    ; --- 1. Get current string length ---
    call      LEN                    
    
    ; Clamp req_count to string length if it exceeds it
    cmp       r12, rax
    jbe       left_alloc
    mov       r12, rax                  ; r12 = min(req_count, strlen)

left_alloc:
    ; --- 2. Allocate space via arena_alloc (r12 chars + 1 for NUL terminator) ---
    mov       rax, r12
    inc       rax                       
    mov       rdi, rax                  ; length including NUL
    lea       rsi, [arena]
    call      arena_alloc
    test      rax, rax
    jz        left_exit
    mov       dest_str, rax
    mov       r13, rax                  ; r13 = new destination payload pointer

    ; If clamped count is 0, just write NUL terminator and return
    test      r12, r12
    jz        left_terminate

    ; --- 3. Copy characters from source to new string ---
    xor       rcx, rcx                  ; index counter = 0

left_loop:
    cmp       rcx, r12
    jge       left_terminate

    mov       al, byte ptr [rbx + rcx]
    mov       byte ptr [r13 + rcx], al

    inc       rcx
    jmp       left_loop

left_terminate:
    ; Ensure null-termination at the end of the extracted string
    mov       byte ptr [r13 + r12], 0
    mov       rax, dest_str

left_exit:
    ret
LEFT$ ENDP

END
