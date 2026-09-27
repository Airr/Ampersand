AMP_MAIN = 1

include amp.inc

.data

.code

; ==============================================================================
; Main Entry Point
; ==============================================================================
main PROC USES r13
    ; split into arena-backed string array (no direct memory allocations for array OR elements)
        mov r13, SPLIT$("Apple, Banana, Cherry", ", ")

    ; if returned array is null, bail
    .if r13 == 0
        PRINT("Split failed.\n")
        EXIT(1)
    .endif

    ; array is zero-terminated, making looping through the elements simple
    .while qword ptr [r13]      ; derefence array via brackets to get element, cast to qword pointer, check if null (0)
        PRINT("%s\n", [r13])    ; dereference in order to print current string element
        add r13, sizeof qword   ; move to next element. each element pointer is 8 bytes (qword) in this case
    .endw

    EXIT(0)                     ; clean exit
main ENDP

end
