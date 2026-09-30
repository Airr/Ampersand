Define AMP_MAIN

include amp.inc
include gtk.inc

.data

.data?
    win     dq ?
    but     dq ?

.code

on_button_clicked PROC widget:QWORD, data:QWORD
    PRINT("Button was clicked!\n")
    xor eax, eax
    ret
on_button_clicked ENDP

main PROC 

    ; 1. Initialize GTK
    GUI_INIT(0,0)

    ; 2. Create window -> store pointer in 'win' variable
    mov win, NEW_WINDOW(0)

    ; 3. Set Window Properties
    SET_PROP(win, "title", "UASM GTK3 Demo","default-width", 600,"default-height", 300,0)
  
    ; 4. Create button -> store pointer in 'but' variable
    mov but, NEW_BUTTON("Click Me")

    ; 5. Add button to win container
    CONTAINER_ADD(win, but)

    ; 6. Connect signals
    SET_CALLBACK(but,"clicked", CALLBACK(on_button_clicked))
    SET_CALLBACK(win,"destroy", CALLBACK(gtk_main_quit))

    ; 7. Show all widgets and start main loop
    GUI_SHOW(win)
    GUI_RUN()

    EXIT(0)
main ENDP

end