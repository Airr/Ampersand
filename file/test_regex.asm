; test_regex.asm — standalone regex test against libc, no amp.inc dependency
; assemble/link (Linux x64):
;   uasm -elf64 test_regex.asm -Fo test_regex.o
;   gcc test_regex.o -o test_regex -no-pie
;   ./test_regex

Define AMP_MAIN
include amp.inc

extrn printf   :proto :ptr, :vararg
extrn malloc   :proto :qword
extrn free     :proto :ptr
extrn strtok   :proto :qword, :ptr
extrn regcomp  :proto :qword, :ptr, :dword
extrn regexec  :proto :qword, :ptr, :dword, :qword, :dword
extrn regfree  :proto :qword

.data
    pattern   db "^(SPRINT|sprint)[[:space:]]+(PROC|proc)[[:space:]]+USES([[:space:]]+[[:alnum:]_]+)*[[:space:]]+(.*)$", 0
    input     db "SPRINT PROC USES rbx rbp r12 r13 r14 r15 fmt:PTR, args:VARARG", 0

    errMsg    db "Could not compile regex", 10, 0
    failMsg   db "Match failed.", 10, 0
    item1Fmt  db "Item 1:  %.*s", 10, 0
    item2Fmt  db "Item 2:  %.*s", 10, 0
    restLabel db "Rest:    ", 0
    restFmt   db "%s", 0
    commaSep  db ", ", 0
    commaTok  db ",", 0
    nlFmt     db 10, 0


    REG_EXTENDED equ 1

.code
main proc USES rbx r12 r13 r14 r15
    local regexBuf[16]:qword     ; regex_t — generously oversized, glibc's is ~64 bytes
    local matchArr[10]:qword     ; regmatch_t[5] oversized buffer (real size: 5*8 bytes)
    local restStr:ptr 
    local restLen:qword
    local tokenPtr:ptr
    local colonPtr:ptr
    local firstFlag:qword

    regcomp(addr regexBuf, addr pattern, REG_EXTENDED)
    .if rax != 0
        lea rdi, errMsg
        xor eax, eax
        call printf
        mov rax, 1
        jmp cleanup
    .endif

    regexec(addr regexBuf, addr input, 5, addr matchArr, 0)

    .if rax == 0
        lea r10, matchArr          ; r10 = base; regmatch_t = {int rm_so; int rm_eo;} = 8 bytes/group

        ; ---- Item 1: group 1 ----
        movsxd rax, dword ptr [r10 + 1*8 + 4]  ; rm_eo
        movsxd rcx, dword ptr [r10 + 1*8]      ; rm_so
        sub rax, rcx                            ; rm_eo - rm_so
        mov r12, rax                            ; length
        lea rsi, input
        add rsi, rcx                            ; input + rm_so
        mov r13, rsi                            ; capture

        printf(addr item1Fmt, r12, r13)

        ; ---- Item 2: group 2 ----
        lea r10, matchArr
        movsxd rax, dword ptr [r10 + 2*8 + 4]
        movsxd rcx, dword ptr [r10 + 2*8]
        sub rax, rcx
        mov r12, rax
        lea rsi, input
        add rsi, rcx
        mov r13, rsi

        printf(addr item2Fmt, r12, r13)

        ; ---- Rest: group 4 ----
        ; ---- Rest: group 4 ----
        lea r10, matchArr

        ; group 4 = (.*)
        movsxd rax, dword ptr [r10 + 4*8 + 4]    ; rm_eo
        movsxd rcx, dword ptr [r10 + 4*8]        ; rm_so

        ; Print the offsets so we can verify the regex result
        ; temporarily:
        ; printf("start=%d end=%d\n", rcx, rax)
        mov r12, rcx        ; rm_so
        sub rax, rcx  
        mov restLen, rax    ; length of capture?

        mov restStr, ALLOC(restLen)          ; get allocation rom Arena
        .if !restStr
            jmp cleanup
        .endif

        ; Copy substring
        mov rdi, restStr
        lea rsi, input
        add rsi, r12
        mov rdx, restLen
        call strncpy

        ; Explicit NUL terminator
        mov rax, restStr
        add rax, restLen
        mov byte ptr [rax], 0

        printf(addr restLabel)

        strtok(restStr, ",")
        mov tokenPtr, rax

        mov firstFlag, 1

        .while tokenPtr
            strchr(tokenPtr, ':')
            mov colonPtr, rax

            .if colonPtr
                .if firstFlag == 0
                    printf(addr commaSep)
                .endif
                printf("%s", colonPtr)

                mov firstFlag, 0
            .endif

            strtok(0, ",")
            mov tokenPtr, rax
        .endw

        printf(addr nlFmt)

    .else
        printf(addr failMsg)
    .endif

    xor rax, rax

cleanup:
    regfree(addr regexBuf)
    EXIT(0)
main endp


end