Define AMP_MAIN

include amp.inc
parse	proto	:ptr

.data

.code
main proc USES rbx r12 r13 r14
	local tmpStr:ptr, files:ptr, filePath:ptr, pSearch:ptr, fileContent:ptr
    local outString:ptr

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
                    mov tmpStr, REMAIN$(pSearch, "PUBLIC")
                    
                    ; FIX 2: Load variables into registers to evaluate the condition
                    mov rax, tmpStr
                    mov r13, pSearch
                    .if !rax || rax == r13
                        .break
                    .endif
                    
                    ; PRINT("Extracted string: %s\n", tmpStr)
                    ; mov outString, JOIN$(3, outString, tmpStr, "\n")
					mov r12, CONCAT$(tmpStr, " PROC")
					mov r12, INDEXOF(fileContent, r12)
                    .if r12 != -1
                        mov r13, fileContent
                        add r13, r12                 ; r13 now points directly at the match

                        xor r14, r14
                        ; scan until end of line, incrementing r14 for MID$() call
                        .while byte ptr [r13 + r14] != 10 && byte ptr [r13 + r14] != 0
                            inc r14
                        .endw

                        mov r15, MID$(fileContent, r12, r14) ; extract the actual line text
                        mov r15, parse(r15)                  ; generate the function prototypes
                        PRINT("%s\n", r15)
                        .if !outString 
                            mov outString, SPRINT("%s\n", r15)
                        .else
                            mov outString, SPRINT("%s%s\n", outString, r15)
                        .endif
                    .endif              
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

    SAVEFILE("protos.txt", outString)
    .if rax
        PRINT("File Saved.\n")
    .else
        PRINT("File Not Saved.\n")
        EXIT(1)
    .endif	

	EXIT(0)
main endp

parse proc USES r12 r13 r14 string:ptr
	local argv:ptr
	mov argv, string

	mov r12, EXTRACT$(argv, "PROC")		; get proc name
	mov r13, INDEXOF(argv, ":")			; location of parameters

	.if COMPARE(argv, r12) == 0
		xor rax, rax
		ret
	.endif

	.if r13 !=-1
		mov r14, argv

		.while r13 != 0
			mov al, [r14 + r13 -1]
			cmp al, ' '
			je backscan_done
			cmp al, 9
			je backscan_done
			dec r13
		.endw

		backscan_done:
			mov r14, LEN(argv)
			sub r13, r14
			neg r13
			mov r14, RIGHT$(argv, r13)
			mov rax, SPRINT("%s\t\tPROTO\t%s",r12,r14)
			ret
	.endif

	mov rax, SPRINT("%s\t\tPROTO",r12)
	ret
parse endp
end
