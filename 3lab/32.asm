; Вариант 3 (вспомогательный модуль)
; Преобразовать данные  представленные  в  шестнадцатеричном  виде (DWORD) в  восьмеричное число без знака в символьной форме. 
; Число параметров 2.  Первый - исходное значение.  Второй - адрес,  начиная с которого размещается результат.
; ==========================================================================================

code segment para public 'code'
.486

	public wordToTernary

	; Возвращает размер строки в СX
	; Параметры: SI - адрес строки
	getsize proc far 
		
		xor cx, cx
		getsizeLoop:
		
			cmp byte ptr [si], '$'
			je getsizeEnd
			inc si
			inc cx
			jmp getsizeLoop
			
		getsizeEnd:
		sub si, cx
		
		ret
		
	getsize endp
	
	; Переворачивает строку
	; Параметры: DI - адрес строки
	reverse proc near
	
		push dx
		push cx
		push si
		push di
		
		call getsize
		mov di, si
		add di, cx
		dec di
		shr cx, 1
		reverseLoop:
			mov dl, [si]
			xchg [di], dl
			mov [si], dl
			inc si
			dec di
		loop reverseLoop
		
		pop di
		pop si
		pop cx
		pop dx
		
		ret
	
	reverse endp
	
	; Конвертирует слово в 3-чное символьное представление. 
	wordToTernary proc far
		
		push bp
		mov bp,sp

		; получение параметров из стека
		push ebx
		push di
		push si
		mov ebx, [bp+6]	  	 ; исходное значение
		mov di, [bp+7]      ; адрес строки результата
		mov si, di
		
		;==================================================
		push eax			; ЕАХ - текущий символ
		wordToTernaryLoop:
		
			mov eax, ebx	; остаток от деления на 8
			and ax, 7
			add ax, '0'		; преобразование в символ
		
			mov [di], al		; dest[i] = ax; i++
			inc di
			
			shr ebx, 3
			cmp ebx, 0
		
		jne wordToTernaryLoop
		pop eax
		
		call reverse
		
		pop si
		pop di
		pop ebx
		pop bp
		ret 6
		
	wordToTernary endp

code ends
end