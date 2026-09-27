Define AMP_MAIN

include amp.inc 

main proc USES rbx r12 r13 argc:qword, argv:ptr
    local fileHandle:qword, fileContent:ptr, tmpStr:ptr, files:ptr, filePath:ptr
    local outString:ptr, pSearch:ptr

    xor rbx, rbx
    mov files, DIR$("/home/riveraa/Projects/uasm/newlib/src")
    mov r12, files

    SORT(files)

    .while r12
        .if ENDSWITH(r12, ".asm")
            mov filePath, SPRINT("/home/riveraa/Projects/uasm/newlib/src/%s", r12)
            mov fileContent, LOADFILE$(filePath)
            
            .if fileContent
                ; FIX 1: Move via register (rax) because fileContent and pSearch are both local memory vars
                mov rax, fileContent
                mov pSearch, rax
                
                ; Loop to find ALL occurrences of "public" in the current file
                .while 1
                    mov tmpStr, REMAIN$(pSearch, "public")
                    
                    ; FIX 2: Load variables into registers to evaluate the condition
                    mov rax, tmpStr
                    mov r13, pSearch
                    .if !rax || rax == r13
                        .break
                    .endif
                    
                    PRINT("Extracted string: %s\n", tmpStr)
                    mov outString, JOIN$(3, outString, tmpStr, "\n")
                    
                    ; FIX 3: Move via register (rax) because tmpStr and pSearch are both local memory vars
                    mov rax, tmpStr
                    mov pSearch, rax
                .endw
            .else
                PRINT("No match found or failed to load: %s\n", filePath)
            .endif
        .endif
        inc  rbx
        mov  r12, files
        mov  r12, [r12 + rbx*sizeof(qword)]          
    .endw

    SAVEFILE("amp.txt", outString)
    .if rax
        PRINT("File Saved.\n")
    .else
        PRINT("File Not Saved.\n")
        EXIT(1)
    .endif
    EXIT(0)
main endp

end