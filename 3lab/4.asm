code segment para public 'code'
.486
	public inputWord, printOutput, parseWord

	; Считывает dword в символьной форме в EBX
	; Параметры: SI - адрес исходной строки
	parseWord proc near
		push cx
		push si
		
		xor ebx, ebx
		
		cld
		mov di, 0
		mov cx, 1
		parseWordLoop:
			xor eax, eax	
			mov al, [si] ; Al = input[i]

			; получаем значение
			cmp ax, '0'
			jl exception
			cmp ax, '9'
			jl WordDigitValue
			
			exception:
			mov ax, 1	; return code = 1 (ERROR)
			jmp	parseWordEnd

			WordDigitValue:
			imul ebx, 16
			sub eax, 48
			; добавляем к сумме
			add ebx, eax

			inc di
			inc si
			cmp di, 8
			je parseEndWithZero
		jmp parseWordLoop

		setMinus:
		mov cx, 1
		inc di
		inc si
		jmp parseWordLoop

		parseEndWithZero:
		xor ax, ax ; return code = 0 (OK)
		
		parseWordEnd:
		pop si
		pop cx
		ret
	
	parseWord endp

	; Ввод числа
	; Параметр: адрес буфера
	; 			максимальный размер буфера
	; 			путь к файлу
	inputWord proc far
		push bp
		mov bp,sp
		push dx

		;открываем файл
        mov  ah,  30h  ;  open file
		mov  al,  0    ; для чтения
        mov si, [bp + 8]     ; DS:dx указатель на имя файла
        lea dx, [si]     ; DS:dx указатель на имя файла
        int 21h     ; в ax деcкриптор файла
		jc error1
       
	    
	    mov bx,ax       ; находим длину файла
		push ax
		mov ah, 42h
		mov al, 0
		xor cx,cx
        xor dx,dx
        int 21h    
		jc error1
		push ax


		mov ah, 42h		; ставим в начало
		mov al, 0
		xor cx,cx
        xor dx,dx
        int 21h    
		jc error1

		

        mov ah,3fh      ; будем читать из файла
        pop cx
		pop bx
        mov dx, [bp + 6]     ; DS:dx указатель на буфер
        push bx
		int 21h 
        
		mov ah,3eh        ; закрываем файл, после чтения
        pop bx
		int 21h
		jc error4
		error1:
		nop
		
		error4:
		pop dx
		pop bp
		ret 4
		
	inputWord endp

	; Печатает строку c указанным цветом текста
	; Параметры: строка, столбец, адрес строки для вывода
	printOutput proc far
	
		push bp
		mov bp,sp

		push dx
		push ax
		xor ebx, ebx

		mov ah, 09h
		mov cx, 1000h
		mov bl, [bp+6]
		int 10h

		mov ah, 09h
		mov dx, [bp+8]
		int 21h		
		int 20h
		
		pop ax
		pop dx
		pop di
		
		pop bp
		ret 6
		
	printOutput endp
code ends
end