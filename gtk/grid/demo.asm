Define AMP_MAIN

include amp.inc
include gtk.inc

.data
    eText       db  "Button %d Clicked",0

.data?
    win         dq  ?
    but1        dq  ?
    but2        dq  ?
    but3        dq  ?
    container   dq  ?
    grid        dq  ?
    entry1      dq  ?

.code

; callback for buttons
; the USES keyword preserves registers used by GTK
on_button_clicked PROC USES r12 r13 rbx rsi rdi widget:QWORD, data:QWORD

    xor     r13, r13

    .if widget == but1
        mov r13, 1
    .elseif widget == but2
        mov r13, 2
    .elseif widget == but3
        mov r13, 3
    .endif


    .if r13 !=0
        mov rbx, SPRINT("Button %d Clicked", r13)
        SET_PROP(entry1, "text", rbx)
    .endif

    xor eax, eax ; Clear return register (GTK expects 0/FALSE for handled click)
    ret
on_button_clicked endp

main proc
    
    GUI_INIT(0,0)

    ; Create a new window
    mov win, NEW_WINDOW(0) ; Create a new window and store the pointer in rbx

    ; Set the window properties
    SET_PROP(win, "title", "GTK Grid Demo", \
                  "default-width", 600, \
                  "default-height", 300, \
                  "border-width", 10, 0 \
            )

    ; Create a new grid
    mov grid, NEW_GRID()
    SET_PROP(grid, "row-spacing", 10, "column-spacing", 10, "halign", 0, "valign", 0, 0)

    ; Add the grid to the window
    CONTAINER_ADD(win, grid)    

    ; Create buttons
    mov but1, NEW_BUTTON("Button 1")
    mov but2, NEW_BUTTON("Button 2")
    mov but3, NEW_BUTTON("Button 3")

    ; Right-Align the buttons
    SET_PROP(but1, "halign", 2, 0)
    SET_PROP(but2, "halign", 2, 0)
    SET_PROP(but3, "halign", 2, 0)

    ; Create entry (textbox
    mov entry1, NEW_ENTRY()
    SET_PROP(entry1, "hexpand", 1, 0)


    ; Add the widgets to the grid
    ; Column, Row, Width, Height - Width spans Columns, Height spans Rows
    GRID_ATTACH(grid, entry1, 0, 0, 1, 1)    
    GRID_ATTACH(grid, but1,   1, 0, 1, 1) ; Attach Button 1 to the grid at Column 1, Row 0
    GRID_ATTACH(grid, but2,   1, 1, 1, 1) ; Attach Button 2 to the grid at Column 1, Row 1
    GRID_ATTACH(grid, but3,   1, 2, 1, 1) ; Attach Button 3 to the grid at Column 1, Row 2


    SET_CALLBACK(win,"destroy", addr gtk_main_quit)
    SET_CALLBACK(but1, "clicked", CALLBACK(on_button_clicked))
    SET_CALLBACK(but2, "clicked", CALLBACK(on_button_clicked))
    SET_CALLBACK(but3, "clicked", CALLBACK(on_button_clicked))

    ; Show all widgets in the window
    GUI_SHOW(win)

    ; Start the GTK main loop
    GUI_RUN()

    EXIT(0)
main endp
end