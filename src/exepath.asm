; -----------------------------------------------------------------------------
; Name:         LOF (Length of File)
; Description:  Retrieves the size of a file given its file path string.
;               Mirrors BASIC's LOF function using Linux system calls.
; C Prototype:  int64_t LOF(const char* filepath);
; Parameters:   rdi - Pointer to a null-terminated C string (filepath)
; Returns:      rax - File size in bytes on success, or 0 on failure.
; -----------------------------------------------------------------------------
OPTION LITERALS:ON
option casemap:none
option frame:auto 

extrn APPNAME$     :proto
extrn APPPATH$     :proto
extrn SPRINT       :proto :PTR, :VARARG

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

.code
PUBLIC EXEPATH$
EXEPATH$ PROC USES rbx r12 r13

    mov r12, APPNAME$()
    mov r13, APPPATH$()
    mov rbx, SPRINT("%s/%s", r13, r12)
    mov rax, rbx
    ret
EXEPATH$ endp

END