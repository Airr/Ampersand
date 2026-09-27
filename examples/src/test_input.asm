AMP_MAIN = 1

include amp.inc

.data

.code

main proc argc:dword, argv:ptr
    local answer:ptr, tmpStr:ptr                            ; variables on stack

    CLS()                                                   ; clear the screen
    mov answer, INPUT$("Enter Your Name: ")                 ; prompt for name, assign response to 'answer' variable

    .if LEN(answer) > 1                                     ; check if valid string
        PRINT("You Entered: '%s'\n", answer)                ; print the prompt string
        epause()                                            ; pause program
        EXIT(0)                                             ; clean exit
    .else                                                   ; no input provided, show error
        PRINT("ERROR: You did not provide a valid name.\n") ; print error message 
        epause()                                            ; pause program
        EXIT(1)                                             ; exit with error code    
    .endif                                                  ; end of IF block


    EXIT(2)                                                 ; if this line is reached, we have a problem
main endp

end    