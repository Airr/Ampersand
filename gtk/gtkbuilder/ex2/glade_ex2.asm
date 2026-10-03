Define AMP_MAIN
Define USE_RESOURCE

include gtkbuilder.inc

.data
	
.code

; button click callback - all buttons in this example point to this
on_button_clicked PROC USES r12 r13 rbx rsi rdi widget:QWORD, data:QWORD
	mov r12, widget						; button
	mov r13, data						; entry1 specified in ui file,
										; passed as userdata for each button
	
	mov rbx, GET_NAME(r12)				; get name of button clicked
	mov rbx, SPRINT("%s Clicked!", rbx)
	SET_PROP(r13,"text", rbx, 0)		; set entry1 text
	
	; Clear return register (GTK expects 0/FALSE for handled click)
    xor eax, eax 
    ret
on_button_clicked endp


main proc argc:qword, argv:ptr
    ; Initialize GTK
    GUI_INIT(0, 0)


    ; Create a new GtkBuilder instance
    ; loads the ui file from embeded resource
    mov r13, UI_NEW()

    mov r12, UI_GET(r13, "window1")
	
    ; Show widget and run main loop
    GUI_SHOW(r12)
    GUI_RUN()

    EXIT(0)
main endp

end