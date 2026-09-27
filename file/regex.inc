ifndef REGEX_INC

    `.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
    `.note.GNU-stack` ENDS

    REGEX_INC equ 1

    OPTION LITERALS:ON
    option casemap:none
    option frame:auto

    extrn regex_parse :proto :ptr, :ptr, :ptr, :ptr, :ptr
    ; extrn printf      :proto :ptr, :VARARG
    extrn strtok      :proto :ptr, :ptr
    ; extrn strchr      :proto :ptr, :dword
    extrn free        :proto :ptr

endif