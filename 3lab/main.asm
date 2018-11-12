.model small

stack segment para stack 'stack'
	db 100h DUP(?)
stack ends
	
data segment para public 'data'	
	
	input dw ?
	output db 12 DUP('$'), '$'
	
	path db "input.txt",0 ; имя файла для открытия

	bufferMax db 11
	bufferLen db ?
	buffer db 12 DUP('$')		

	resultMsg db 'Result: ', '$'
	successMsg db 'You entered: ', '$'
	parseErrMsg db 'Error: incorrect hex number format', '$'
	sizeErrMsg db 'Error: input must be a DWORD', '$'
	
	newLine db 10, 13, '$'
	color equ 0Ah
data ends	

code segment para public 'code'
assume ds:data, ss:stack, cs:code
.486		
	
	 extrn wordToTernary: far
	 
	parseHex proc near
		push cx
		push si
		
		xor ebx, ebx
		
		cld
		mov di, 0
		mov cx, 1
		parseHexLoop:
			xor eax, eax	
			mov al, [si] ; Al = input[i]

			; получаем значение
			cmp ax, '0'
			jl exception
			cmp ax, '9'
			jle hexDigitValue
			
			exception:
			mov ax, 1	; return code = 1 (ERROR)
			jmp	parseHexEnd

			hexDigitValue:
			imul ebx, 16
			sub eax, 48
			; добавляем к сумме
			add ebx, eax

			inc di
			inc si
			cmp di, 3
			je parseEndWithZero
		jmp parseHexLoop

		parseEndWithZero:
		xor ax, ax ; return code = 0 (OK)
		
		parseHexEnd:
		pop si
		pop cx
		ret
	
	parseHex endp

	; Ввод числа
	; Параметр: адрес буфера
	; 			максимальный размер буфера
	; 			путь к файлу
	inputHex proc far
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
        mov ah,3eh        ; закрываем файл, после чтения
        int 21h
		pop dx
		pop bp
		ret 4
		
	inputHex endp

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
	print macro arg:REQ
		mov ah, 09h
		lea dx, arg
		int 21h
	endm

	main:	
		mov ax, data
		mov ds, ax

		lea ax, bufferMax
		push ax
		lea ax, path
    	push ax
		; ввод числа
		lea si, buffer
		push si
		call inputHex
		print newLine
		print successMsg
		print buffer
		cmp ax, 0
		je noErrorR

		cmp al, 10
		jne mainSizeError
		
		noErrorR:
		; чтение числа из строки
		lea si, buffer
		call parseHex
		mov input, bx
		cmp ax, 0
		je noError
		; проверка на ошибку
		cmp ax, 1
		je mainParseError
		jmp mainEnd

		mainSizeError:
		; Некорректный размер
		print newLine
		print sizeErrMsg
		jmp mainEnd
		
		; Некорректный формат
		mainParseError:
		print newLine
		print parseErrMsg
		jmp mainEnd
		
		noError:
		; проверка на отрицательность
		cmp input, 0
		jge formResult
		not input
		inc input
		
		formResult:
		; формирование результата
		
		lea si, output
		push si
		push input
		call wordToTernary
		
		print newLine
		print resultMsg
		push si
		push color
		call printOutput
		mainEnd:
		xor ebx, ebx
		xor dx, dx
		xor si, si
		xor eax,eax

		mov ax, 4c00h
		int	21h		
code ends
end main