; Prototypes needed for INVOKE
curl_global_init    PROTO :QWORD
curl_easy_init      PROTO
curl_easy_perform   PROTO :QWORD
curl_easy_setopt    PROTO :QWORD, :QWORD, :VARARG
curl_easy_cleanup   PROTO :QWORD
curl_global_cleanup PROTO
curl_init			proto :ptr qword


CURLOPT_URL             equ     10002
CURLOPT_WRITEFUNCTION   equ     20011
CURL_GLOBAL_DEFAULT     equ     3
CURLOPT_FOLLOWLOCATION  equ     52

.code

curl_init proc uses rbx, hndPtr:ptr qword
    mov     rbx, hndPtr          ; save the pointer FIRST, before it can be clobbered
    
    .if curl_global_init(CURL_GLOBAL_DEFAULT) != 0
        mov     rax, 1
        ret
    .endif

    .if curl_easy_init() == 0
        mov     rax, 1
        ret
    .endif

    mov     [rbx], rax            ; rbx still holds hndPtr, untouched by the calls above
    xor     eax, eax
    ret
curl_init endp

; TODO:
;   curl_download   - download to file with optional progress
;   curl_string     - download and add to arena string for parsing, etc
;                   - will probably use curl download, and then LOADFILE$()