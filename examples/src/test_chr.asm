AMP_MAIN = 1

include amp.inc

.code
main proc uses rbx r12 r13 r14 r15 argc:dword, argv:ptr
    xor     r15, r15                        ; failure count

    mov     r12, CHR$(72, 105, 33, CHR_END)
    PRINT("1  CHR$(72,105,33,CHR_END)  = %s\n", r12)

    mov     r12, CHR$(65, 66, 67, 68, 69, 70, CHR_END)          ; six codes = all registers
    PRINT("2  six codes (registers)    = %s\n", r12)

    mov     r12, CHR$(65, 66, 67, 68, 69, 70, 71, CHR_END)      ; seventh is on the stack
    PRINT("3  seven codes              = %s\n", r12)

    mov     r12, CHR$(97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, CHR_END)
    PRINT("4  fourteen codes           = %s\n", r12)

    mov     r12, CHR$(CHR_END)
    .if r12 == 0
        inc r15
        PRINT("5a FAIL: empty list returned NULL\n")
    .else
        LEN(r12)
        .if rax != 0
            inc r15
        .endif
        PRINT("5a CHR$(CHR_END)            = [%s] (not NULL)\n", r12)
    .endif
    mov     r12, CHR$(-5)
    .if r12 == 0
        inc r15
    .else
        PRINT("5b any negative terminates  = [%s]\n", r12)
    .endif

    mov     r12, CHR$(65, 256, CHR_END)
    .if r12 != 0
        inc r15
        PRINT("6a FAIL: 256 accepted\n")
    .else
        PRINT("6a code 256                 = NULL\n")
    .endif
    mov     r12, CHR$(65, 66, 67, 68, 69, 70, 71, 999, CHR_END) ; bad code in the stack part
    .if r12 != 0
        inc r15
        PRINT("6b FAIL: 999 (stack arg) accepted\n")
    .else
        PRINT("6b bad code as 8th arg      = NULL\n")
    .endif

    mov     r12, CHR$(255, 1, CHR_END)
    movzx   r13, byte ptr [r12]
    .if r13 != 255
        inc r15
    .endif
    PRINT("7  CHR$(255,1) byte0        = %d\n", r13)

    mov     r12, CHR$(65, 0, 66, CHR_END)
    LEN(r12)
    mov     r13, rax
    movzx   r14, byte ptr [r12+2]
    .if r13 != 1 || r14 != 66
        inc r15
    .endif
    PRINT("8  CHR$(65,0,66) LEN=%d, byte2=%d\n", r13, r14)

    mov     r12, CHR$(88, 89, 90, CHR_END)
    movzx   r13, byte ptr [r12+3]
    .if r13 != 0
        inc r15
    .endif
    PRINT("9  NUL after last code       = %d\n", r13)

    PRINT("failures=%d\n", r15)
    mov     rax, r15
    EXIT(rax)
main endp
end