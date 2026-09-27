AMP_MAIN = 1

include amp.inc

getElement proto :ptr, :ptr, :qword


.data
    probe               db  "/usr/bin/ffprobe -hide_banner -stats -i ", 0
    ffmpeg              db  "/usr/bin/ffmpeg -hide_banner -stats -v quiet -y -i ",0
    ffmpeg_params       db " -c:a libmp3lame -b:a 128k -map_metadata -1 ",0
    srcDir              db  "/home/riveraa/Music/80s Party Mix/",0
.code

main proc USES rbx r12 r13
    local entries:ptr, res:qword, command:ptr, filePath:ptr, quotedPath:ptr
    local song_track:ptr, song_artist:ptr, song_title:ptr, metadata:ptr
    local full_command:ptr, song_metadata:ptr, output_fle:ptr, dest_file:ptr

    mov entries, DIR$(addr srcDir)
    .if entries == 0
        PRINT("DIR$() Failed.\n")
        EXIT(1)
    .endif

    mov res, CONCAT$(addr srcDir, "MP3")
    mov res, MKDIR(res, 755q)
    .if res != 0
        PRINT("MKDIR() Failed with Error Code: %d\n", res)
        EXIT(res)
    .endif

    SORT(entries)

    xor  rbx, rbx
    mov  r12, entries


    .while r12 != 0
        .if ENDSWITH(r12, ".m4a")
            CLS()
            mov output_fle, REPLACE$(r12, ".m4a", ".mp3")
            PRINT("Encoding: %s\n", output_fle)
            mov filePath, CONCAT$(addr srcDir, r12)
            mov quotedPath, ENC$(filePath, 0)
            mov command, CONCAT$(addr ffmpeg, quotedPath)
            mov r12, REPLACE$(r12, "–", "-")
            mov metadata, SPLIT$(r12, " - ")

            mov song_track, getElement(metadata, "track",0)
            mov song_artist, getElement(metadata, "artist",1)
            mov song_title, getElement(metadata, "title",2)

            mov output_fle, JOIN$(3,addr srcDir,"MP3/",output_fle)
            mov dest_file, ENC$(output_fle,0)
            mov song_title, REPLACE$(song_title, ".m4a","")

            mov song_metadata, JOIN$(3, song_track, song_artist, song_title)
            mov full_command, JOIN$(6, addr ffmpeg, quotedPath, addr ffmpeg_params, song_metadata, " ", dest_file)

            mov res, SHELL(full_command)
            .if res != 0
                PRINT("Error: %d\n", res)
                EXIT(res)
            .endif
        .endif

        inc  rbx
        mov  r12, entries
        mov  r12, [r12 + rbx*sizeof(qword)]
    .endw

    EXIT(0)
main endp

getElement proc USES r13 array:ptr, atom:ptr, index:qword
    mov     rax, array                          ; rax = base
    mov     rcx, index                          ; rcx = element number
    mov     rax, [rax + rcx * sizeof(qword)]    ; rax = array[index]
    mov     rax, JOIN$(3,atom,"=",rax)
    mov     rax, ENC$(rax, 0)
    mov     rax, CONCAT$(" -metadata ",rax)
    ret
getElement endp

end
