; Вариант 3 (главный модуль)
; Преобразовать данные  представленные  в  шестнадцатеричном  виде (DWORD) в  восьмеричное число без знака в символьной форме. 
; Число параметров 2.  Первый - исходное значение.  Второй - адрес,  начиная с которого размещается результат.
; ==========================================================================================

.model small

stack segment para stack 'stack'
	db 100h DUP(?)
stack ends
	
data segment para public 'data'	
	
	value DWORD 231

	output db 12 DUP('$'), '$'
	
	resultMsg db 'Result: ', '$'
	
	newLine db 10, 13, '$'
	
	OUT_ROW equ 7
	OUT_COL equ 6
	
data ends	

code segment para public 'code'
assume ds:data, ss:stack, cs:code
.486		
	
	extrn wordToTernary: far

	printOutput proc 
		
		ret
		
	printOutput endp


	print macro arg:REQ
		mov ah, 09h
		lea dx, arg
		int 21h
	endm

	main:	
		mov ax, data
		mov ds, ax
		
		; Проверяем число на 0
		cmp value, 0
		jge converting
		not value
		inc value
		
		converting:
		lea si, output
		push si
		push value
		call wordToTernary
		; проверка на ошибку
		cmp ax, 0
		je noError
		cmp ax, 1
		je mainParseError
	
		
		print newLine
		print resultMsg
		
		; вывод результата
		push si
		push OUT_COL
		push OUT_ROW
		call printOutput
		
		; конец программы
		jmp mainEnd
		
		
		
		mainEnd:
		xor ebx, ebx
		xor dx, dx
		xor si, si
		
		mov ax, 4c00h	; функция выхода с кодом 0
		int	21h		
		
code ends
end main