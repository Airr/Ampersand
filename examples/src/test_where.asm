AMP_MAIN = 1

include amp.inc

.data

.code

; ==============================================================================
; Main Entry Point
; ==============================================================================
main PROC USES r12

    mov r12, WHERE$("aacgain")
    .if r12
        PRINT("'aacgain' was found at: %s\n", r12)
    .endif
    EXIT(0)
main ENDP

end