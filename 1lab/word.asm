org 100h
global _start

section .data ; секция памяти 
    array: dw 1,2,3,-4,-5,6,7,-8,9,5 ; стартовый массив
    result: times 10 dw 0 ; результирующий массив

    length: dw 10 ; стартовая длина
    new_length: dw 0 ; новая длина

    first_elem: dw 0 
    last_elem: dw 0

    i: dw 0 ; индекс итерирования
    t: dw 0 ; 

    msg: dw 'hello world','$'

section .text

_start: ; начало
set_first_last_elems: ; задаются первое и последнее число
        mov bx, part2
        mov bx, [result]
        mov bx, [array]
        mov [first_elem], bx ; занесли первое число
        mov ax, [length]
        dec ax
        mov dx, 2
        mul dx
        add ax, array
        mov si, ax
        mov bx, [si]
        mov [last_elem], bx ; занесли последнее число


part1:
        mov ax, 1
        mov [t], ax
        mov ax, [length]
        cmp ax, 1
        jg sorting_array
        mov ax, 4c00h
        int 21h
        sorting_array:
            mov ax, 1
            mov [t], ax
            mov ax, 0
            mov [i], ax
            cycle_iteration:
                mov ax, [i] ; получаем i-ый элемент массива
                mov dx, 2
                mul dx
                add ax, array
                mov si, ax
                mov bx, [si]

                cmp bx, 0 ; если i-ый элемент массива <= 0, то продолжаем итерации
                jle cicle2_end

                mov ax, [i] ; получаем i + 1 -ый элемент массива
                inc ax
                mov dx, 2
                mul dx
                add ax, array
                mov si, ax
                mov cx, [si]

                cmp cx, 0 ; если i+1 элемент <= 0, то его нужно менять с i-ым
                jle swap

                cmp bx, cx ; если i+1 элемент больше i-ого, то их нужно менять
                jle cicle2_end
            swap:
                mov ax, [i] ;заносим правый элемент влево
                mov dx, 2
                mul dx
                add ax, array
                mov si, ax
                mov [si], cx 

                mov ax, [i] ; заносим левый элемент вправо
                inc ax
                mov dx, 2
                mul dx
                add ax, array
                mov si, ax
                mov [si], bx

            sorting_falsed:
                mov ax, 0
                mov [t], ax
                jmp cicle2_end

            cicle2_end:
                mov ax, [i]
                inc ax
                mov [i], ax
                mov ax, [length]
                dec ax
                mov cx, [i]
                cmp ax, cx
                jg cycle_iteration
        sorting_end:
            mov ax, [t]
            cmp ax, 0
            je sorting_array    
            mov ax, 0
            mov [t], ax

part2:
    checking_elems: ; берем в результирующий массив только числа не между первым и последним
        nop
        mov ax, [i]
        mov dx, 2 
        mul dx
        mov cx, ax
        add cx, array
        mov si, cx
        mov bx, [si] ; заносим i-ый эелмент
        jmp check_number_not_between_first_last
        inserting_array:
            mov ax, [t]
            cmp ax, 0
            je cicle_end
            mov ax, [new_length]
            inc ax
            mov [new_length], ax
            mov ax, [new_length]
            dec ax
            mov dx, 2
            mul dx
            add ax, result
            mov si, ax
            mov [si], bx
        cicle_end:
            mov ax, [i]
            inc ax
            mov [i], ax
            mov ax, [length]
            mov cx, [i]
            cmp ax, cx
            jg checking_elems
end:
    mov ax, 4c00h
    int 21h

check_number_not_between_first_last: ; проверка что число не находится 
    mov ax, [first_elem]
    cmp bx, ax
    jg check_last_elem_greater
    je check_false
    mov ax,[last_elem]
    cmp bx, ax
    jl check_true
    mov ax, 0
    mov [t], ax
    jmp inserting_array
    check_last_elem_greater:
        mov ax, [last_elem]
        cmp bx, ax
        jg check_true
    check_false:
        mov ax, 0
        mov [t], ax
        jmp inserting_array
    check_true:
        mov ax, 1
        mov [t], ax
       jmp inserting_array