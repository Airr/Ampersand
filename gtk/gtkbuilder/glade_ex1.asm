Define AMP_MAIN

include amp.inc
include gtk.inc

.data
	
.code


on_button_clicked PROC USES r12 r13 rbx rsi rdi widget:QWORD, data:QWORD
	mov r12, widget
	mov r13, data
	
	mov rbx, GET_NAME(r12)
	mov rbx, SPRINT("%s Clicked!", rbx)
	SET_PROP(r13,"text", rbx, 0)
	
	; Clear return register (GTK expects 0/FALSE for handled click)
    xor eax, eax 
    ret
on_button_clicked endp

main proc argc:qword, argv:ptr
    ; Initialize GTK
    GUI_INIT(0, 0)

    ; Create a new GtkBuilder instance
    mov r13, NEW_BUILDER()

    ; Load UI file: gtk_builder_add_from_file(builder, filename, NULL)
    BUILDER_ADD(r13, "interface.ui", 0)
    
	; Connect signals defined in Glade (e.g., gtk_main_quit on destroy)
    BUILDER_CONNECT(r13, 0)

    ; Get window1 object: gtk_builder_get_object(builder, name)
    mov r12, BUILDER_GET(r13, "window1")
	
    ; Show widget and run main loop
    GUI_SHOW(r12)
    GUI_RUN()

    EXIT(0)
main endp

end