OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn arena_alloc   :proto :qword, :ptr
extrn arena         :qword
extrn szEmpty       :byte
extrn ALLOC 		:proto	requested_size:qword

SYS_GETCWD           EQU 79
`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code
;
;==============================================================================
; CURDIR$
;   Retrieves the current working directory path and allocates memory from 
;   an arena to store it.
;
; Parameters:
;   None
;
; Returns:
;   rax = Pointer to the newly allocated string containing the current 
;   working directory path, or null if allocation fails.
;==============================================================================

PUBLIC CURDIR$
CURDIR$ PROC USES r12
	mov r12, ALLOC(4096)
	
	mov rax, SYS_GETCWD
	mov rdi, r12
	mov rsi, 4096
	syscall
	.if rax < 0
		xor rax, rax
		ret
	.endif
	
	mov rax, r12
	ret
CURDIR$ endp    
; CURDIR$ PROC USES rbx r12 r14 r15
;     ; --- 1. Allocate space on stack frame for path buffer ---
;     sub     rsp, 528                    ; Ensure local space for stack buffer

;     ; --- 2. Call sys_readlink on "/PROC/self/cwd" ---
;     mov     rax, 89                     ; sys_readlink
;     lea     rdi, [szProcSelfCwd]        ; "/PROC/self/cwd"
;     lea     rsi, [rbp - 528]            ; Destination buffer on stack
;     mov     rdx, 512                    ; Buffer size
;     syscall

;     cmp     rax, 0
;     jle     cwd_empty                   

;     mov     r14, rax                    ; r14 = actual path string length
;     mov     byte ptr [rbp - 528 + r14], 0 ; Null-terminate buffer

;     ; --- 3. Allocate from Arena (length + 1 for NUL terminator) ---
;     mov     rdi, r14
;     inc     rdi                         ; Include space for NUL
;     mov     r15, rdi                    ; Save total allocation size
;     lea     rsi, [arena]
;     call    arena_alloc

;     test    rax, rax
;     jz      cwd_fail

;     ; --- 4. Copy directory path characters to arena buffer ---
;     mov     rdi, rax                    ; Destination = arena buffer
;     lea     rsi, [rbp - 528]            ; Source = stack buffer (path string)
;     mov     rcx, r14                    ; Length of path string
;     cld
;     rep     movsb

;     mov     byte ptr [rdi], 0           ; Null-terminate payload
;     sub     rdi, r14                    ; Reset rdi back to start of arena block
;     mov     rax, rdi                    ; Return arena-allocated string pointer
;     jmp     cwd_exit

; cwd_empty:
;     ; Return empty string allocated from arena (1 byte for NUL)
;     mov     rdi, 1
;     lea     rsi, [arena]
;     call    arena_alloc
;     test    rax, rax
;     jz      cwd_fail
;     mov     byte ptr [rax], 0
;     jmp     cwd_exit

; cwd_fail:
;     xor     rax, rax

; cwd_exit:
;     add     rsp, 528
;     ret
; CURDIR$ ENDP

.data
; szProcSelfCwd   db "/PROC/self/cwd", 0

end