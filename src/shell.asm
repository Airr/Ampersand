OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

MAX_ARGS    equ 64

extrn g_envp        :qword

.code

;
;==============================================================================
; SHELL
;   Executes a command in a new process using the system call sys_execve.
;
; Parameters:
;   cmd_str (ptr): A null-terminated string representing the command to execute.
;
; Returns:
;   rax: The exit status of the child process if successful. If an error occurs, 
;        returns -22 for invalid argument or -1 for other errors.
;==============================================================================

PUBLIC SHELL
SHELL PROC USES r12 r13 cmd_str:PTR 
    LOCAL wordArray[MAX_ARGS]:QWORD
    LOCAL child_pid:QWORD
    LOCAL wait_status:QWORD

    ; Load and validate the input string argument
    mov       rdi, cmd_str
    test      rdi, rdi
    jnz       shell_PROCeed
    mov       rax, -22            ; -EINVAL
    ret

shell_PROCeed:
    ; --- STEP 1: FORK THE PROCESS ---
    mov       rax, 57             ; sys_fork
    syscall                       
    
    test      rax, rax
    js        fork_failed         
    jz        child_PROCess       

    ; --- PARENT PROCESS ---
    mov       child_pid, rax      
    
    ; Call sys_wait4 (syscall 61)
    mov       rax, 61             
    mov       rdi, child_pid      
    lea       rsi, wait_status    
    xor       rdx, rdx            
    xor       r10, r10            
    syscall
    
    test      rax, rax
    js        wait_failed         

    ; Extract child's exit status (bits 8-15)
    mov       rax, wait_status    
    shr       rax, 8              
    and       rax, 0FFh           
    ret

wait_failed:
    ret

fork_failed:
    ret

child_PROCess:
    ; --- CHILD PROCESS ---
    lea       rdx, wordArray      
    mov       r12, rdx            
    xor       rcx, rcx            
    
    mov       rdi, cmd_str
    
store_token:
    ; Skip leading spaces
    mov       al, [rdi]
    test      al, al
    jz        done_parsing
    cmp       al, ' '
    jne       check_single_quote
    inc       rdi
    jmp       store_token

check_single_quote:
    mov       al, [rdi]
    ; cmp       al, "'"             ; Check for single quote opening
    ; je        parse_quoted_token

    cmp       al, '"'             ; Check for double quote opening
    je        parse_quoted_token

    ; --- Unquoted Token Parser ---
    mov       [r12 + rcx*8], rdi
    inc       rcx

parse_unquoted:
    mov       al, [rdi]
    test      al, al
    jz        done_parsing
    cmp       al, ' '
    je        found_space
    inc       rdi
    jmp       parse_unquoted

found_space:
    mov       byte ptr [rdi], 0   ; Null-terminate token in-place
    inc       rdi                 ; Skip past space
    cmp       rcx, MAX_ARGS
    jge       done_parsing
    jmp       store_token

parse_quoted_token:
    inc       rdi                 ; Skip past the opening quote
    mov       [r12 + rcx*8], rdi  ; Save the actual start of the token
    inc       rcx

find_closing_quote:
    mov       al, [rdi]
    test      al, al
    jz        done_parsing        ; Unterminated quote reached end of string
    ; cmp       al, "'"             ; Check for single quote closing
    ; je        found_closing_quote
    cmp       al, '"'             ; Check for double quote closing
    je        found_closing_quote
    inc       rdi
    jmp       find_closing_quote

found_closing_quote:
    mov       byte ptr [rdi], 0   ; Null-terminate token at closing quote position
    inc       rdi                 ; Skip past the closing quote
    
    ; Skip any trailing space immediately following the quote
    mov       al, [rdi]
    cmp       al, ' '
    jne       check_limit
    inc       rdi

check_limit:
    cmp       rcx, MAX_ARGS
    jge       done_parsing
    jmp       store_token

done_parsing:
    ; Null-terminate the argv pointer array itself
    mov       qword ptr [r12 + rcx*8], 0

    ; Setup and invoke sys_execve (syscall 59)
    mov       rax, 59             
    mov       rdi, [r12]          
    mov       rsi, r12            
    ; xor       rdx, rdx 
    mov       rdx, g_envp           ; Use the global environment pointer           
    syscall                       

child_exit:
    mov       rax, 60             
    mov       rdi, 127            
    syscall
SHELL ENDP
END
