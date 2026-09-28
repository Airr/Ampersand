AMP_MAIN = 1

include amp.inc


.data


.code

main proc argc:dword, argv:ptr
    local text_dup:ptr
    local custom_buf:ptr

    ; Test memalloc, memcpy, and memfree
    mov custom_buf, MEM_ALLOC(256)

    MEM_COPY(custom_buf, "Hello from MEM_ALLOC!", 21)

    ; Print and final cleanup
    PRINT("%s\n", custom_buf)

    MEM_FREE(custom_buf)     ; Free the custom_buf buffer
    EXIT(0)
main endp

end
