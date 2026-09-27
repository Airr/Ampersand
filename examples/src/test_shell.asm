AMP_MAIN = 1

include amp.inc

.data


.code

; ==============================================================================
; Main Entry Point
; ==============================================================================
main PROC
    local result:qword
    ; Call the SHELL procedure passing the command string
    ; storing the return code in 'result'.
    mov result, SHELL("/bin/ls -la /tmp")
    .if result != 0
        PRINT("Error: %d\n", result)
        EXIT(result)
    .endif


    ; If execve succeeds, we fall through here. Exit cleanly.
    EXIT(0)
main ENDP

end
