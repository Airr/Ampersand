AMP_MAIN = 1

include amp.inc

grab    proto   :ptr, :ptr, :ptr

.data
    input db "SPRINT PROC USES rbx rbp r12 r13 r14 r15 fmt:PTR, args:VARARG", 0

.code

main proc USES rbx r12 r13 r14 r15 argc:qword, argv:ptr
    local check:ptr
    ; mov r12, SPLIT$(addr input, " ")
    ; .while qword ptr [r12]      ; derefence array via brackets to get element, cast to qword pointer, check if null (0)
    ;     mov r13, [r12]
    ;     mov check, grab(addr input, r13, " ")
    ;     PRINT("%s\n",check)

    ;     add r12, sizeof qword   ; move to next element. each element pointer is 8 bytes (qword) in this case
    ; .endw
    mov r12, REMOVE$(addr input, "USES")
    mov r12, REMOVE$(r12, "USES rbx rbp r12 r13 r14 r15")
    PRINT("%s\n", r12)
    EXIT(0)
main endp

grab proc USES rbx r12 r13 r14 srcString:ptr, beginString:ptr, endString:ptr
    local start:qword, wordSize:qword, found:ptr
    mov r12, srcString
    mov r13, beginString
    mov r14, endString

    mov start, INDEXOF(r12, r13)
    .if start
        mov wordSize, LEN(r13)
        mov found, MID$(r12, start, wordSize)
        ; PRINT("Found: %s, Grab Start: %d, Length: %d\n", found, start, wordSize)
    .endif
    mov rax, found
    ret

grab endp
end