org 100h
global _start

section .data ; секция памяти 
    array: dd 1,2,3,-4,-5,6,7,-8,9,5 ; стартовый массив
    result: times 10 dd 0 ; результирующий массив

    length: dd 10 ; стартовая длина
    new_length: dd 0 ; новая длина

    first_elem: dd 0 
    last_elem: dd 0

    i: dd 0 ; индекс итерирования
    t: dd 0 ; 

    msg: dd 'hello world','$'

section .text

_start: ; начало
set_first_last_elems: ; задаются первое и последнее число
        mov ebx, part2
        mov ebx, [result]
        mov ebx, [array]
        mov [first_elem], ebx ; занесли первое число
        mov eax, [length]
        dec eax
        mov edx, 4
        mul edx
        add eax, array
        mov esi, eax
        mov ebx, [esi]
        mov [last_elem], ebx ; занесли последнее число


part1:
        mov eax, 1
        mov [t], eax
        mov eax, [length]
        cmp eax, 1
        jg sorting_array
        mov eax, 4c00h
        int 21h
        sorting_array:
            mov eax, 1
            mov [t], eax
            mov eax, 0
            mov [i], eax
            cycle_iteration:
                mov eax, [i] ; получаем i-ый элемент массива
                mov edx, 4
                mul edx
                add eax, array
                mov esi, eax
                mov ebx, [esi]

                cmp ebx, 0 ; если i-ый элемент массива <= 0, то продолжаем итерации
                jle cicle2_end

                mov eax, [i] ; получаем i + 1 -ый элемент массива
                inc eax
                mov edx, 4
                mul edx
                add eax, array
                mov esi, eax
                mov ecx, [esi]

                cmp ecx, 0 ; если i+1 элемент <= 0, то его нужно менять с i-ым
                jle swap

                cmp ebx, ecx ; если i+1 элемент больше i-ого, то их нужно менять
                jle cicle2_end
            swap:
                mov eax, [i] ;заносим правый элемент влево
                mov edx, 4
                mul edx
                add eax, array
                mov esi, eax
                mov [esi], ecx 

                mov eax, [i] ; заносим левый элемент вправо
                inc eax
                mov edx, 4
                mul edx
                add eax, array
                mov esi, eax
                mov [esi], ebx

            sorting_falsed:
                mov eax, 0
                mov [t], eax
                jmp cicle2_end

            cicle2_end:
                mov eax, [i]
                inc eax
                mov [i], eax
                mov eax, [length]
                dec eax
                mov ecx, [i]
                cmp eax, ecx
                jg cycle_iteration
        sorting_end:
            mov eax, [t]
            cmp eax, 0
            je sorting_array    
            mov eax, 0
            mov [t], eax

part2:
    checking_elems: ; берем в результирующий массив только числа не между первым и последним
        nop
        mov eax, [i]
        mov edx, 4 
        mul edx
        mov ecx, eax
        add ecx, array
        mov esi, ecx
        mov ebx, [esi] ; заносим i-ый эелмент
        jmp check_number_not_between_first_last
        inserting_array:
            mov eax, [t]
            cmp eax, 0
            je cicle_end
            mov eax, [new_length]
            inc eax
            mov [new_length], eax
            mov eax, [new_length]
            dec eax
            mov edx, 4
            mul edx
            add eax, result
            mov esi, eax
            mov [esi], ebx
        cicle_end:
            mov eax, [i]
            inc eax
            mov [i], eax
            mov eax, [length]
            mov ecx, [i]
            cmp eax, ecx
            jg checking_elems
end:
    mov eax, 4c00h
    int 21h

check_number_not_between_first_last: ; проверка что число не находится 
    mov eax, [first_elem]
    cmp ebx, eax
    jg check_last_elem_greater
    je check_false
    mov eax,[last_elem]
    cmp ebx, eax
    jl check_true
    mov eax, 0
    mov [t], eax
    jmp inserting_array
    check_last_elem_greater:
        mov eax, [last_elem]
        cmp ebx, eax
        jg check_true
    check_false:
        mov eax, 0
        mov [t], eax
        jmp inserting_array
    check_true:
        mov eax, 1
        mov [t], eax
       jmp inserting_array