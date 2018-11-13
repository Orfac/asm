code segment para public 'code'
.486
	public inputWord, printOutput, parseWord

	; Считывает dword в символьной форме в EBX
	; Параметры: SI - адрес исходной строки
	parseWord proc near
		push cx
		push si
		
		mov cx, bx
		xor bx, bx
		
		cld
		mov di, 0
		parseWordLoop:
			xor ax, ax	
			mov al, [si] ; Al = input[i]

			; получаем значение
			cmp ax, '0'
			jl exception
			cmp ax, '9'
			jle WordDigitValue
			
			exception:
			mov ax, 1	; return code = 1 (ERROR)
			jmp	parseWordEnd

			WordDigitValue:
			sub ax, 48
			imul bx, 10
			
			; добавляем к сумме
			add bx, ax

			inc si
			dec cx
			cmp cx, 0
		jg parseWordLoop
		jmp parseEndWithZero

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
        mov ax,3d00h    ; открываем для чтения
        mov si, [bp + 8]     ; DS:dx указатель на имя файла
        lea dx, [si]     ; DS:dx указатель на имя файла
        int 21h     ; в ax деcкриптор файла
		
        mov bx,ax       ; копируем в bx указатель файла
		xor cx,cx
        xor dx,dx

        mov ax,4200h
        int 21h     ; идем к началу файла

        mov ah,3fh      ; будем читать из файла
        mov si, [bp + 10]
        mov cx, [si]
        mov dx, [bp + 6]     ; DS:dx указатель на имя файла
        int 21h 
		mov bx, ax
        mov ah,3eh        ; закрываем файл, после чтения
        int 21h
		xor ax,ax
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
		; int 20h
		
		pop ax
		pop dx
		; pop di
		
		pop bp
		ret 
		
	printOutput endp
code ends
end