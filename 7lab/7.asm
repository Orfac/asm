; Вариант 10
; � яд: E(-1^n * x^(2i + 1) / (2i-1)! )
; Функция: sinx
; ==========================================================================================

.686
.model flat, stdcall
option casemap: none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\msvcrt.lib

TABLE_WIDTH  equ 20
COLUMN_COUNT equ 4
BUFFER_SIZE  equ TABLE_WIDTH

print macro args:REQ
	irp arg, <args>
		invoke WriteConsole, handleOut, addr arg, length arg, NULL, NULL
	endm
endm

printS macro arg:REQ
	invoke WriteConsole, handleOut, addr arg, sizeof arg, NULL, NULL
endm

floatToString macro arg:REQ
	call clearBuffer
	invoke FloatToStr, arg, offset buffer
endm

input macro arg:REQ
	invoke crt_scanf, addr format, addr arg
endm

padLeft macro arg:REQ
	invoke WriteConsole, handleOut, addr arg, sizeof arg, NULL, NULL
	rept TABLE_WIDTH - sizeof arg
		print space
	endm
endm

.data
	; Сообщения
	message1 db 'xStart: ', 0
	message2 db 'xEnd: ', 0
	message3 db 'deltaX: ', 0
	message4 db 'Precision: ', 0
	
	; Заголовки таблицы
	header1 db 'Argument', 0
	header2 db 'Series sum', 0
	header3 db 'sin(x)', 0
	header4 db 'Element count', 0
	
	; Введённые значения
	currentX  dq ?
	finalX    dq ?
	deltaX 	  dq ?
	precision dq ?
	
	; Строка таблицы
	function  dq ?
	seriesSum dq ?
	element   dq ?
	elemCount dq 0
	
	; Ввод-вывод
	handleIn  dd ?
	handleOut dd ?
	buffer	  db BUFFER_SIZE dup(0)
	format 	  db "%lf", 0
	
	; Псевдографика
	upperLeft      db 201, 0
	upperRight     db 187, 0
	upperT         db 203, 0
	lowerLeft      db 200, 0
	lowerRight 	   db 188, 0
	lowerT         db 202, 0
	leftT          db 204, 0
	rightT         db 185, 0
	cross      	   db 206, 0
	verticalLine   db 186, 0
	horizontalLine db TABLE_WIDTH dup(205), 0	
	space		   db ' ', 0
	newline		   db 10, 13, 0
	
.code
; Вычисляет сумму ряда и кол-во элементов
getSeriesSum proc uses eax
	local count: dword
	local k: dword
	local sinx : qword

	mov count, 1
	mov k, 0
	finit

						; сумма = 0
	fld currentX				; \ элемент = 1
	fstp element		; /
	fldz 
	fstp sinx
@loop:  fld sinx
		fld element 
		fadd
		fstp sinx

		inc k
		fldz
		fld1
		fsub
		fld element	
		fmul 
		fld currentX		;  | Умножаем элемент на sin*x
		fmul			; /
		fld currentX
		fmul
		
		inc count
		fidiv count
		inc count
		fidiv count

		fstp element
		push offset precision
		push offset element
		call compare
	ja @loop

	fld sinx
	fstp seriesSum
	fild k
	fstp elemCount
	
	ret
getSeriesSum endp

; Вычисляет значение функции a^x
calcFunction proc
	
	finit
	fld currentX	; x --> st(1)
	fsin
	fstp function		; result --> function
	ret
calcFunction endp

; Сравнивает два числа double
compare proc uses eax X:dword, Y:dword 
	mov eax, Y
	fld qword ptr [eax]
	fld qword ptr [eax]
	fmul
	mov eax, X
	fld qword ptr [eax]
	fld qword ptr [eax]
	fmul
	fcompp	 	; сравнение двух чисел и удаление их из стека
	fstsw ax 	; сохраняем статусное слово в АХ
	sahf		; загружаем содержимое АН в регистр флагов
	ret 8
compare endp

; Очищает буфер
clearBuffer proc uses eax cx edi
	mov ecx, BUFFER_SIZE / 4
	lea edi, buffer
	xor eax, eax
	cld
@@: stosd
	loop @b
	ret
clearBuffer endp

drawHeader proc
	print upperLeft
	rept COLUMN_COUNT - 1
		print horizontalLine
		print upperT
	endm
	print <horizontalLine, upperRight, newline>
	
	irp header, <header1, header2, header3, header4>
		print verticalLine
		padLeft header
	endm
	print <verticalLine, newline>
	
	print leftT
	rept COLUMN_COUNT - 1
		print horizontalLine
		print cross
	endm
	print <horizontalLine, rightT, newline>
	
	ret
drawHeader endp

drawRow	proc
	irp value, <currentX, seriesSum, function, elemCount>
		print verticalLine
		floatToString value
		padLeft buffer
	endm
	print <verticalLine, newline>
	ret
drawRow endp

drawTable proc
	call drawHeader
	
@@: call getSeriesSum
	call calcFunction
	call drawRow
	fld currentX
	fld deltaX
	fadd
	fstp currentX
	push offset finalX
	push offset currentX
	call compare
	jna @b

	print lowerLeft
	rept COLUMN_COUNT - 1
		print horizontalLine
		print lowerT
	endm
	print <horizontalLine, lowerRight>
	ret
drawTable endp
	
Start:	  
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov handleIn, eax
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov handleOut, eax
	
	printS message1
	input currentX
	printS message2
	input finalX
	printS message3
	input deltaX
	printS message4
	input precision
	
	print newline
	call drawTable
			
	xor eax, eax
	invoke ReadConsole, handleIn, addr buffer, 1, NULL, NULL
	invoke ExitProcess, 0
end	Start