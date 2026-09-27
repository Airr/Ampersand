AMP_MAIN = 1

include amp.inc

.data
    tstStr		db "filename",0

.code

main proc USES rbx
    local  count:ptr, result:ptr, prefix:ptr

    CLS()

	.for (rbx = 1: rbx <= 1000: rbx++)
	
        .if (rbx == 1)
            assign prefix, LPAD$, "", 3, '0'
        .elseif (rbx == 10)
            assign prefix, LPAD$, "", 2, '0'
        .elseif (rbx == 100)
            assign prefix, LPAD$, "", 1, '0'
        .elseif (rbx == 1000)
        	assign prefix, LPAD$, "", 0, '0'
        .endif

        mov count, rbx
        PRINT("%s%d - %s_%d.txt\n", prefix, count, addr tstStr, count)

    .endfor

    EXIT(0)                         
main endp

end