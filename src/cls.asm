OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS

extern puts:proto :PTR

.const
    ESC = 1Bh

.data
    ; ESC [ H (home) + ESC [ 2 J (clear visible screen) + ESC [ 3 J (clear scrollback)
    szAnsiClear     db  ESC, "[H", ESC, "[2J", ESC, "[3J", 0

.code

;
;==============================================================================
; CLS
;   Clears the screen, homes the cursor, and wipes the scrollback buffer 
;   using ANSI escape sequences via pure UASM system calls.
;
; Parameters:
;   None
;
; Returns:
;   Nothing
;==============================================================================

PUBLIC CLS
CLS PROC
    puts( addr szAnsiClear )
    ret
CLS ENDP

END