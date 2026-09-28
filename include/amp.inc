ifndef AMP_INC
    AMP_INC equ 1

    OPTION LITERALS:ON
    option casemap:none
    option frame:auto

    ; Mark stack as non-executable (NX bit) for security. Required on modern Linux
    ; to prevent buffer overflow attacks and avoid linker warnings.

    `.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
    `.note.GNU-stack` ENDS

    assign MACRO dest, func, args:VARARG
        IFNB <args>
            invoke func, args
        ELSE
            invoke func
        ENDIF
        mov [dest], rax
    ENDM

    FCALL macro target, targs:VARARG
        sub     rsp, 8
        IFNB <targs>
            call target, targs
        ELSE
            call target
        ENDIF
        add     rsp, 8
    endm

    LIBCALL macro func, args:VARARG
        IFNB <args>
            invoke func, args
        ELSE
            invoke func
        ENDIF
    ENDM


    ; Function Prototypes
	ALLOC 		PROTO	requested_size:qword
	APPNAME$ 	PROTO
	APPPATH$ 	PROTO
	CALLOC 		PROTO	count:qword, elem_size:qword
	CHR 		PROTO	text:PTR
	CLOSE 		PROTO	fileHandle:qword
	CLS 		PROTO
	CMDCOUNT 	PROTO
	COLOR 		PROTO	text:ptr, colorcode:qword
	COMMAND$ 	PROTO	argnum:qword
	COMPARE 	PROTO	str1:ptr, str2:ptr
	CONCAT$ 	PROTO	str1:ptr, str2:ptr
	CURDIR$ 	PROTO
    DATE$       PROTO
	DIR$ 		PROTO	dir_path:PTR
	ENC$ 		PROTO	srcPtr:ptr, encChar:dword
	ENDSWITH 	PROTO	src:ptr, arg:ptr
	ENV$ 		PROTO	namePtr:ptr
	EPAUSE 		PROTO
	EXEPATH$ 	PROTO
	EXIST 		PROTO	filePath:ptr
	EXIT 		PROTO	code:qword
	EXTRACT$ 	PROTO	mainStr:ptr, matchStr:ptr
	HEX$ 		PROTO	num:QWORD     
	INDEXOF 	PROTO	haystack:ptr, needle:ptr
	INPUT$ 		PROTO	msg:ptr
    INSERT$     PROTO   src:ptr, position:qword, substring:ptr
    ISODATE$    PROTO
    JOIN$       PROTO   :qword, :vararg
	KILL 		PROTO	filePath:ptr
	LCASE$ 		PROTO	str_buf:PTR
    LEFT$       PROTO   srcString:ptr, numBytes:qword
	LEN 		PROTO	text:ptr
	LOADFILE$ 	PROTO	filePath:ptr
	LOADLIB 	PROTO	filename:ptr
	LOF 		PROTO	path:ptr
    LPAD$       PROTO   srcString:ptr, fillCount:qword, fillChar:byte
    LTRIM$      PROTO   srcString:ptr
	memalloc 	PROTO	memsize:QWORD
	memcpy 		PROTO	dest:PTR, src:PTR, len:QWORD
	memfree 	PROTO	mem_ptr:PTR
	memset 		PROTO	dest:PTR, val:BYTE, len:QWORD
	MID$ 		PROTO	srcString:ptr, index:qword, numBytes:qword
	MKDIR 		PROTO	pathPtr:ptr, dirMode:dword
	NOW$ 		PROTO
	OPEN 		PROTO	filePath:ptr, fileFlags:qword, fileMode:qword
	PRINT 		PROTO	fmt:PTR, args:VARARG
	putn 		PROTO	num:QWORD
	puts 		PROTO	text:ptr
	READ 		PROTO	fileHandle:qword, buffer:ptr, numBytes:qword
	REMAIN$ 	PROTO	pSource:ptr, pMatch:ptr
	REMOVE$ 	PROTO	srcString:ptr, match:ptr
	REPEAT$ 	PROTO	count:qword, pattern:ptr
	REPLACE$ 	PROTO	src:ptr, pattern:ptr, replaceStr:ptr
	REVERSE$ 	PROTO	src:ptr
	RIGHT$ 		PROTO	src:ptr, count:qword
	RPAD$ 		PROTO	src:ptr, count:qword, fillChar:byte
	RTRIM$ 		PROTO	srcString:ptr
	SAVEFILE 	PROTO	filePath:ptr, srcString:ptr
	SCOPY 		PROTO	src:ptr
	SEEK 		PROTO	fileHandle:qword, fileOffset:qword, seekFlags:qword
	SHELL 		PROTO	cmd_str:ptr
	SORT 		PROTO	arrPtr:ptr
	SPLIT$ 		PROTO	srcString:ptr, delimiterString:ptr
	SPRINT 		PROTO	fmt:PTR, args:VARARG
	STR$ 		PROTO	num:QWORD     
	STRL$ 		PROTO	float:REAL8
	strrev 		PROTO	str_buf:PTR
	strstr 		PROTO	haystack:PTR, needle:PTR
	TALLY 		PROTO	srcString:ptr, matchStr:ptr
	TIME$ 		PROTO
	TRIM$ 		PROTO	srcString:ptr
	UCASE$ 		PROTO	str_buf:PTR
	WHERE$ 		PROTO	argv:ptr
	WRITE$ 		PROTO	fileHandle:qword, buffer:ptr, numBytes:qword





    ifdef AMP_MAIN                  ; defined only by the file that owns the entry point
        .data
            PUBLIC arena, g_envp, g_argv, g_argc, NULL
            arena   dq 0,0
            g_envp  dq 0
            g_argv  dq 0
            g_argc  dq 0
            NULL    dq 0

        .code
            _start proc
                mov     rdi, [rsp]                  ; argc
                lea     rsi, [rsp + 8]              ; argv
                lea     rdx, [rsp + 16 + rdi*8]     ; envp
                mov     g_envp, rdx                 ; assign envp to global g_envp
                mov     g_argc, rdi                 ; assign argc to global g_argc
                mov     g_argv, rsi                 ; assign argv to global g_argv
                and     rsp, -16                    ; align stack for calls
                call    main                        ; your normal proc, now with SysV args
                
                ret
            _start endp
    else
        EXTERNDEF arena     :qword
        EXTERNDEF g_envp    :qword
        EXTERNDEF g_argv    :qword
        EXTERNDEF g_argc    :qword
        EXTERNDEF NULL      :qword
    endif            
endif    

