define AMP_MAIN

include amp.inc
include curl.inc

.const
	
.data
	
.code

; simple callbac that writes web link content to stdout
write_callback proc USES rbx rbp
    mov     rbx, rdi            ; rbx = buf (survives invoke)
    imul    rsi, rdx            ; rsi = size * nmemb (size and nmemb are passed via the callback in rdi and rdx)
    mov     rbp, rsi            ; rbp = count (saves result of multiplication)
    WRITE$(1, rbx, rbp)         ; output to stdout
    mov     rax, rbp            ; return size*nmemb to curl
    ret
write_callback endp

main proc argc:dword, argv:ptr
    LOCAL curlHnd:qword, curlURL:ptr

    .if CMDCOUNT() == 0         ; check directly, no intermediate register - result is in rax
        jmp usage_error
    .endif

    ; Get argv[1]
	mov     curlURL, COMMAND$(1)	; we want to keep a copy of argv[1] for use later
	.if curlURL == 0
        jmp usage_error
	.endif  

    ; Init curl with custom curl_init proc, passing *address* of curl handle
    .if curl_init(addr curlHnd) != 0
        jmp     error
    .endif    

    ; Use URL from command line (curlURL points to the string)
    .if curl_easy_setopt(curlHnd, CURLOPT_URL, curlURL)
    	jmp error
    .endif  

    ; set the callback function
    .if curl_easy_setopt(curlHnd, CURLOPT_WRITEFUNCTION, addr write_callback)
        jmp error
    .endif

    ; follow redirects
    .if curl_easy_setopt(curlHnd, CURLOPT_FOLLOWLOCATION, 1)
        jmp error
    .endif  

    ; connect and proccess web link
    .if curl_easy_perform(curlHnd) != 0
    	jmp error
    .endif    

    curl_easy_cleanup(curlHnd)
    curl_global_cleanup()

    EXIT(0)

    usage_error:

        PRINT("Usage: %s <URL>\n", APPNAME$())
        EXIT(1)

    error:
        .if curlHnd !=0
            curl_easy_cleanup(curlHnd) 
        .endif 

        curl_global_cleanup()
        EXIT(1)

main endp

end