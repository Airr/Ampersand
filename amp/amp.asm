DEFINE AMP_MAIN

include amp.inc

usage   proto
compile proto :ptr
link    proto :ptr

.data
    ldName   db "ld",0
    gccName  db "gcc",0
    szEmpty  db 0

.data?
    linkerType     dq ?
    useGcc         dq ?
    gccOptions     dq ?

.code

main proc argc:qword, argv:ptr
    local srcFile:ptr, arg2:ptr

    .if CMDCOUNT() == 0
        usage()
        EXIT(1)
    .endif

    lea  rax, szEmpty
    mov  gccOptions, rax               ; default: no extra options

    mov srcFile, COMMAND$(1)
    .if CMDCOUNT() > 1
        mov useGcc, 1
        mov arg2, COMMAND$(2)
        .if COMPARE(arg2, "gcc") == 0
            .if CMDCOUNT() > 2         ; guard: arg 3 may not exist
                mov gccOptions, COMMAND$(3)
            .endif
        .else
            mov rax, arg2              ; arg 2 is the options string
            mov gccOptions, rax        ; (no mem-to-mem mov)
        .endif
    .endif

    mov srcFile, EXTRACT$(srcFile, ".asm")

    compile(srcFile)
    link(srcFile)

    EXIT(0)
main endp

usage proc
    local aName:ptr
    mov aName, APPNAME$()

    PRINT("Usage: %s filename {gcc}\n", aName)
    PRINT("\tExample with LD: %s test\n", aName)
    PRINT("\tExample with GCC: %s test gcc [quoted options]\n", aName) 
    ret   
usage endp

compile proc USES r12 r13 r14 fName:ptr
    local objFile:ptr, compileCMD:Ptr, result:qword

    mov r13, fName
    mov r14, CONCAT$(r13,".asm")

    mov r12, WHERE$("uasm")
    .if  r12 == 0
        PRINT("Error: UASM not found. Please install UASM.\n")
        EXIT(1)
    .endif    

    .if EXIST(r14)
        PRINT("Assembling '%s'...\n", r14)
        mov compileCMD, SPRINT("%s -elf64 -q -zcw -I/usr/local/include -Fo %s.o %s", r12, r13, r14)

        mov result, SHELL(compileCMD)
        .if result != 0
            PRINT("Compile Error: %d\n", rax)
            EXIT(rax)
        .endif
    .else
        PRINT("ERROR: %s not found!\n", r14)
        EXIT(3)
    .endif
    xor eax, eax
    ret
compile endp

link proc USES r12 r13 r14 fName:ptr 
    local linker:ptr, result:qword

    mov r12, fName

    .if useGcc
        mov linker, WHERE$("gcc")
    .else
        mov linker, WHERE$("ld")
    .endif

    .if  linker == 0
        PRINT("Error: Linker not found. Please install a build toolchain.\n")
        EXIT(1)
    .endif   

    .if useGcc
        PRINT("Linking with GCC...\n")
         mov r14, SPRINT("%s %s.o -o %s /usr/local/lib/libamp.a -ldl %s -no-pie -s -Wl,--as-needed -nostartfiles -Wl,-e,_start", linker, r12, r12, gccOptions)
    .else
        PRINT("Linking with LD...\n")
        mov r14, SPRINT("%s %s.o /usr/local/lib/libamp.a -o %s -s -no-pie -e _start", linker, r12, r12)
    .endif

    mov result, SHELL(r14)
    .if result != 0
        PRINT("Link Error: %d\n", rax)
        EXIT(rax)
    .endif

    .if EXIST(r12)
        PRINT("Executable '%s' created successfully.\n", r12)
        mov r13, SPRINT("%s.o", r12)
        .if EXIST(r13)
            KILL(r13)
        .endif
    .else
        PRINT("Error: Executable '%s' not created.\n", r12)
        EXIT(4)
    .endif

    xor eax, eax
    ret
link endp
end
