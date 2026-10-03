ifndef AMP_GTKBUILD
    AMP_GTKBUILD equ 1
    
	include amp.inc
	include gtk.inc


	; interface.ui when embedded in binary
		extern _binary_ui_interface_ui_start : byte
		extern _binary_ui_interface_ui_end   : byte

	; GTK BUILDER PROTOS
		gtk_builder_new             PROTO
		gtk_builder_add_from_file   PROTO :QWORD, :PTR, :QWORD
		gtk_builder_connect_signals PROTO :QWORD, :QWORD
		gtk_builder_get_object      PROTO :QWORD, :PTR
		gtk_widget_get_name         PROTO :QWORD 
		gtk_builder_add_from_string PROTO :QWORD, :PTR, :QWORD, :QWORD
		gtk_builder_new_from_string PROTO :QWORD, :PTR, :QWORD, :QWORD

	; GTK BUILDER ALIASES
	    NEW_UI		            equ gtk_builder_new
	    UI_ADD    		        equ gtk_builder_add_from_file
	    UI_CONNECT				equ gtk_builder_connect_signals
	    UI_GET					equ gtk_builder_get_object
	    GET_NAME                equ gtk_widget_get_name

	; Aliases to embedded interface.ui
		UI_START equ _binary_ui_interface_ui_start
		UI_END   equ _binary_ui_interface_ui_end

	; Custom Protos
		UI_LOAD proto builder_obj:qword ;, res_start:ptr, res_end:ptr
		UI_NEW  proto


	.code

	; Loads interface.ui from embedded resource
		UI_LOAD proc builder_obj:qword ;, res_start:ptr, res_end:ptr
		    local builder:qword
		    
		    mov builder, builder_obj
		    
		    ; mov rsi, res_start    ; Start address passed as argument
		    ; mov rax, res_end      ; End address passed as argument
		    lea rsi, UI_START
		    lea rax, UI_END
		    
		    sub rax, rsi
		    mov rdx, rax          ; rdx holds the exact size in bytes
		    
		    gtk_builder_add_from_string(builder, rsi, rdx, 0)
		     
		    ret
		UI_LOAD endp

	; Returns GTKBuilder object in rax
		UI_NEW proc uses r13     
			local pad:qword	; padding to avoid segfault

		    mov r13, NEW_UI()
		    UI_LOAD(r13)

		    UI_CONNECT(r13,0)

		    mov rax, r13
		    ret
		UI_NEW endp
endif		