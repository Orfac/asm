; 1) Чтение элемента из моделируемого массива по его порядковому номеру в ЕВХ
; Аргументы:
; 	SI = индекс 
; Используются:
;	ЕАХ = временное хранение второй части элемента
; 	CL = счётчик для сдвига
getElement macro
local endRead
	push esi
	push cx
	
	; получаем индекс элемента в битах
	imul si, WORD_SIZE
	; получаем бит, с которого в этом двойном слове начинается нужный элемент (остаток от деления на 32)
	mov cx, si
	and cx, 31
	; получаем двойное слово, где начинается элемент
	sub si, cx	; биты
	shr si, 3	; байты
	
	; Первая часть нашего элемента
	mov ebx, [ebp + esi]	
	shl ebx, cl			; сдвигаем на оставшиеся биты
	and ebx, WORD_MASK	; срезаем лишние 10 битов справа
	
	; Проверяем, остались ли биты нашего элемента в следующем слове
	; Если элемент начинается с бита < 11, то он целиком умещается в одно слово
	cmp cx, 16
	jl endRead
	push eax
	
		mov eax, [ebp+esi+4]
		xchg si, cx
		mov cx, 32
		sub cx, si
		shr eax, cl
	
	or ebx, eax
	and ebx, WORD_MASK
	
	pop eax
	endRead:
	pop cx
	pop esi
endm

; 2) Запись элемента в массив на указанное место
; Аргументы:
;	EBX = элемент для записи
;	DI = индекс
; Используются:
;	EAX = маска
;	CX = счётчик сдвига
;	DX = промежуточные данные
setElement macro
local endWrite
	push di
	push cx
	push dx
	push eax
	
	and ebx, WORD_MASK
	
	; получаем индекс элемента в битах
	imul di, WORD_SIZE
	; получаем бит, с которого в этом двойном слове начинается нужный элемент (остаток от деления на 32)
	mov cx, di
	and cx, 31
	; получаем двойное слово, где начинается элемент
	sub di, cx	; биты
	shr di, 3	; байты
	
	; Первая часть нашего элемента
	; С помощью маски обнуляем существующий элемент в массиве
	mov eax, WORD_MASK		
	shr eax, cl			
	not eax
	and eax, [ebp+edi]
	
	; Применяем логическое ИЛИ к маске и аргументу
	push ebx
	shr ebx, cl
	or eax, ebx
	pop ebx
	
	mov [ebp+edi], eax
	
	; Проверяем, остались ли биты нашего элемента в следующем слове
	; Если элемент начинается с бита < 11, то он целиком умещается в одно слово
	cmp cx, 16
	jl endWrite
	
		; 32 - СХ = количество бит элемента, уместившееся в предыдущем слове
		mov dx, 32
		sub dx, cx
		xchg cx, dx
		
		; С помощью маски обнуляем существующий элемент в массиве
		mov eax, WORD_MASK
		shl eax, cl
		not eax
		and eax, [ebp+edi+4]
	
		; Применяем логическое ИЛИ к маске и аргументу
		push ebx
		shl ebx, cl
		or eax, ebx
		pop ebx
	
		mov [ebp+edi+4], eax
	
	endWrite:
	pop eax
	pop dx
	pop cx
	pop di
endm

; 3) Подсчёт числа единиц в двоичном представлении элемента
; Аргументы:
;	SI = индекс
; Возвращает:
;	DX = количество единиц
; Используются:
;	EBX = элемент
;	CX = счётчик цикла
countSetBits macro
local COUNT_LOOP, ONE_LAST, endd
	push ebx
	push cx
	push eax

	xor edx, edx
	
	getElement
	mov cx, 1
	
	COUNT_LOOP:
		mov eax, ebx
		and eax, LOW_MASK
		cmp eax, 1
		jg ONE_LAST
		mov eax, ebx
		ror eax, 1
		and eax, WORD_MASK
		jmp endd
		ONE_LAST:
		mov eax, ebx
		ror eax, 1
		and eax, WORD_MASK
		or eax, HIGH_MASK
		endd:
		mov ebx, eax
	loop COUNT_LOOP
	mov edx, ebx
	pop eax
	pop cx
	pop ebx
endm