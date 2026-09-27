AMP_MAIN = 1

include amp.inc

.data
    tstStr  db  "Counts occurrences of a regular null-terminated string 'target' in the string 's'.",0

.code

main proc
    local  result:qword

    CLS()

    mov result, TALLY(addr tstStr, "string")
    .if result > 0
        PRINT("Original String: '%s'\n", addr tstStr)
        PRINT("Total count of the word 'string': %d\n", result)
    .else
        PRINT("No Results.\n")
    .endif

    
    EXIT(result)                         
main endp

end