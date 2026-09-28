AMP_MAIN = 1

include amp.inc


.data


.code

main proc uses r12
	mov r12, CURDIR$()
	
	PRINT("Current Directory:\t\t'%s'\n", r12)

	.if CHDIR("/tmp")
		mov r12, CURDIR$()
		PRINT("Directory after CHDIR():\t'%s'\n", r12)
	.endif		

	EXIT(0)
main endp

end