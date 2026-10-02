ifndef AMP_GTK
    AMP_GTK equ 1
    gtk_init                    PROTO :QWORD, :QWORD
    gtk_window_new              PROTO :DWORD
    gtk_window_set_title        PROTO :QWORD, :PTR
    gtk_window_set_default_size PROTO :QWORD, :SDWORD, :SDWORD
    gtk_button_new_with_label   PROTO :PTR
    gtk_container_add           PROTO :QWORD, :QWORD
    g_signal_connect_data       PROTO :QWORD, :PTR, :QWORD, :QWORD, :QWORD, :DWORD
    gtk_widget_show_all         PROTO :QWORD
    gtk_main                    PROTO
    gtk_main_quit               PROTO
    g_object_set                PROTO :QWORD, :PTR, :VARARG
    g_object_get                PROTO :QWORD, :PTR, :VARARG
    gtk_grid_new                PROTO
    gtk_grid_attach             PROTO :QWORD, :QWORD, :DWORD, :DWORD, :DWORD, :DWORD
    gtk_entry_new               PROTO
    gtk_container_add           PROTO :QWORD, :QWORD

    ; GTK BUILDER PROTOS
    gtk_builder_new             PROTO
    gtk_builder_add_from_file   PROTO :QWORD, :PTR, :QWORD
    gtk_builder_connect_signals PROTO :QWORD, :QWORD
    gtk_builder_get_object      PROTO :QWORD, :PTR
    gtk_widget_get_name         PROTO :QWORD    
    

    SET_CALLBACK                PROTO :QWORD, :PTR, :QWORD,:QWORD
    


    .const
        CALLBACK                equ addr
        NEW_BUTTON              equ gtk_button_new_with_label
        NEW_WINDOW              equ gtk_window_new
        WINDOW_TITLE            equ gtk_window_set_title
        WINDOW_SIZE             equ gtk_window_set_default_size
        CONTAINER_ADD           equ gtk_container_add
        GUI_INIT                equ gtk_init
        GUI_SHOW                equ gtk_widget_show_all
        GUI_RUN                 equ gtk_main
        SET_PROP                equ g_object_set
        GET_PROP                equ g_object_get
        NEW_GRID                equ gtk_grid_new
        GRID_ATTACH             equ gtk_grid_attach
        NEW_ENTRY               equ gtk_entry_new
        CONTAINER_ADD           equ gtk_container_add

        NEW_BUILDER             equ gtk_builder_new
        BUILDER_ADD             equ gtk_builder_add_from_file
        BUILDER_CONNECT         equ gtk_builder_connect_signals
        BUILDER_GET             equ gtk_builder_get_object
        GET_NAME                equ gtk_widget_get_name

    .code

    SET_CALLBACK proc handle:qword, signal_name:ptr, callback:qword, data:qword
        g_signal_connect_data(handle,signal_name, callback,data,0,0)
        ret
    SET_CALLBACK endp    
        
endif
