OPTION LITERALS:ON
option casemap:none
option frame:auto 

`.note.GNU-stack` SEGMENT READONLY WRITE ALIGN(1)
`.note.GNU-stack` ENDS   

.code

;
;==============================================================================
; SORT
;   Sorts an array of qwords in ascending order using a simple 
;   bubble sort algorithm.
;
; Parameters:
;   arrPtr (ptr): A pointer to the first element of the array to be sorted.
;
; Returns:
;   None. The function sorts the array in place and does not return any value.
;==============================================================================

PUBLIC SORT
SORT PROC USES rbx r12 r13 r14  arrPtr:ptr

    mov     r12, arrPtr            ; r12 = base
    xor     r13, r13            ; r13 = count

    sort_count:
        cmp     qword ptr [r12 + r13 * sizeof(qword)], 0
        je      sort_counted
        inc     r13
        jmp     sort_count

    sort_counted:
        cmp     r13, 2
        jb      sort_done           ; 0 or 1 element
        mov     r14, 1              ; r14 = i

    sort_outer:
        cmp     r14, r13
        jae     sort_done
        mov     rbx, [r12 + r14 * sizeof(qword)]  ; key = arr[i]
        mov     r8, r14             ; j = i

    sort_inner:
        test    r8, r8
        jz      sort_place

        mov     r9, rbx
        mov     r10, [r12 + r8 * sizeof(qword) - sizeof(qword)]

    sort_cmp:
        movzx   eax, byte ptr [r9]
        movzx   ecx, byte ptr [r10]
        cmp     eax, ecx
        jne     sort_cmp_done
        test    eax, eax
        jz      sort_cmp_done
        inc     r9
        inc     r10
        jmp     sort_cmp

    sort_cmp_done:
        cmp     eax, ecx
        jae     sort_place

        mov     rax, [r12 + r8 * sizeof(qword) - sizeof(qword)]
        mov     [r12 + r8 * sizeof(qword)], rax
        dec     r8
        jmp     sort_inner

    sort_place:
        mov     [r12 + r8 * sizeof(qword)], rbx
        inc     r14
        jmp     sort_outer

    sort_done:
        ret
SORT endp

end
