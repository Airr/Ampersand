Define AMP_MAIN
include amp.inc
include regex.inc

.data

    pattern db "^(SPRINT|sprint)[[:space:]]+(PROC|proc)[[:space:]]+USES([[:space:]]+[[:alnum:]_]+)*[[:space:]]+(.*)$", 0

    input db "SPRINT PROC USES rbx rbp r12 r13 r14 r15 fmt:PTR, args:VARARG", 0

    item1Fmt db "Item 1:  %s", 10, 0
    item2Fmt db "Item 2:  %s", 10, 0
    restLabel db "Rest:    ", 0
    restFmt db "%s", 0
    commaSep db ", ", 0
    commaTok db ",", 0
    nlFmt db 10, 0

    failFmt db "regex_parse failed: %d", 10, 0

.code

main proc USES rbx r12 r13 r14 r15

    local item1:ptr
    local item2:ptr
    local rest:ptr
    local tokenPtr:ptr
    local colonPtr:ptr
    local firstFlag:qword
    local outPut:ptr

    ; -------------------------------------------------------------------------
    ; regex_parse(pattern, input, &item1, &item2, &rest)
    ;
    ; SysV:
    ;   RDI = pattern
    ;   RSI = input
    ;   RDX = item1
    ;   RCX = item2
    ;   R8  = rest
    ; -------------------------------------------------------------------------
    ; lea rdi, pattern
    ; xor eax, eax
    ; call printf
    ; ret

    lea rdi, pattern
    lea rsi, input
    lea rdx, item1
    lea rcx, item2
    lea r8, rest


    call regex_parse

    test rax, rax
    jnz failed

    ; -------------------------------------------------------------------------
    ; Item 1
    ; -------------------------------------------------------------------------

    PRINT(addr item1Fmt, item1)
    mov outPut, CONCAT$(item1,"\t")


    ; -------------------------------------------------------------------------
    ; Item 2
    ; -------------------------------------------------------------------------

    PRINT(addr item2Fmt, item2)
    mov outPut, SPRINT("%s %s\t",outPut, item2)
    ; -------------------------------------------------------------------------
    ; Rest
    ; -------------------------------------------------------------------------


    PRINT(addr restLabel)

    mov tokenPtr, strtok(rest, addr commaTok)

    ; mov tokenPtr, rax
    mov firstFlag, 1

    .while tokenPtr

        ; mov rdi, tokenPtr
        ; mov esi, 3Ah
        ; call strchr
        strchr(tokenPtr, 3Ah)

        mov colonPtr, rax

        .if colonPtr

            .if firstFlag == 0
                PRINT(addr commaSep)
                mov outPut, CONCAT$(outPut, addr commaSep)
            .endif

            PRINT(addr restFmt, colonPtr)
            mov outPut, CONCAT$(outPut, colonPtr)

            mov firstFlag, 0

        .endif

        xor edi, edi
        lea rsi, commaTok
        call strtok

        mov tokenPtr, rax

    .endw

    PRINT("\n")

    ; -------------------------------------------------------------------------
    ; Cleanup
    ; -------------------------------------------------------------------------

    mov rdi, item1
    ; call free
    mov r15, SPRINT("%s %s %s", item1, item2, rest)
    mov rdi, item2
    call free

    mov rdi, rest
    call free

    PRINT("%s\n", outPut)
    EXIT(0)

failed:

    mov r12, rax

    PRINT(addr failFmt, r12)

    EXIT(1)

main endp

end