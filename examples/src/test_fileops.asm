AMP_MAIN = 1

include amp.inc


.data
    filename db "JUNK.BIN",0
.code

main proc
    local fd:qword, junk:ptr, read_buf:ptr, fileSize:qword

    CLS()
    
    ; Open "JUNK.BIN" for writing (O_WRONLY | O_CREAT = 65) with 0644 permissions
    mov fd, OPEN(addr filename, 65, 644q )
    
    ; Generate repeating text data
    mov junk, REPEAT$(500, "Hello Everyone!\n")
    
    ; Write the generated text payload to the file and close it
    WRITE$(fd, junk, LEN(junk))
    CLOSE(fd)

    ; Query the total file size in bytes and store it in fileSize
    mov fileSize, LOF(addr filename)
    
    ; Request a memory buffer from the arena matching the exact file size
    mov read_buf, ALLOC(fileSize)
    
    ; Reopen "JUNK.BIN" for reading (O_RDONLY = 0)
    mov fd, OPEN(addr filename, 0, 0 )
    
    ; Reposition file offset 500 bytes from the beginning (SEEK_SET = 0)
    SEEK(fd, 500, 0)
    
    ; Read 5 bytes from that offset into the buffer
    READ(fd, read_buf, 5)

    ; Rewind the file pointer back to the absolute beginning
    SEEK(fd, 0, 0)
    
    ; Read all bytes from the start into the buffer and print it
    READ(fd, read_buf, fileSize)
    ; PRINT("** Loaded Buffer **\n\n")
    ; putn(fileSize)
    PRINT("%s\n", read_buf)
    ; puts(read_buf)
    
    ; Close the active file descriptor and delete the file from disk
    CLOSE(fd)
    KILL(addr filename)
    
    ; Terminate program with a success code
    EXIT(0)                         
main endp

end