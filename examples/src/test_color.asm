AMP_MAIN = 1

include amp.inc

.data

.code

main proc USES rbx 
    local tmpStr:ptr, index:qword

	.for (rbx=0 : rbx < 8 : rbx++)    
	    mov tmpStr, COLOR("Hello World!", rbx)
	    PRINT("%s\n",tmpStr)
	.endfor

    EXIT(0)                         ; cleanly exit program
main endp

end