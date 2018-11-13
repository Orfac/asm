.model small

stack segment para stack 'stack'
	db 100h DUP(?)
stack ends
	
data segment para public 'data'	
	
	input dd ?
	output db 12 DUP('$'), '$'
	
	path db "input.txt",0 ; имя файла для открытия

	bufferMax db 12
	bufferLen db ?
	buffer db 12 DUP('$')		

	resultMsg db 'Result: ', '$'
	successMsg db 'You entered: ', '$'
	parseErrMsg db 'Error: incorrect Word number format', '$'
	sizeErrMsg db 'Error: input must be a DWORD', '$'
	
	newLine db 10, 13, '$'
	color equ 0Ah
data ends	

code segment para public 'code'
assume ds:data, ss:stack, cs:code
.486		
	
	 extrn WordToTernary: far, inputWord: far, parseWord: far, printOutput: far

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
		call inputWord
		print newLine
		print successMsg
		print buffer
		

		
		lea si, buffer
		call parseWord
		mov input, ebx
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
		call WordToTernary
		
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