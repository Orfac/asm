code segment para public 'code'
.486

	public wordToTernary, getsize

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
	; Конвертирует число в десятиричное. 
	wordToTernary proc far
		
		push bp
		mov bp,sp

		; получение параметров из стека
		push ebx
		push di
		push si
		mov bx, [bp+6]	  	 ; исходное значение
		mov di, [bp+8]      ; адрес строки результата
		;==================================================
		push ax			; ЕАХ - текущий символ
		mov ax, bx
		wordToTernaryLoop:
			mov bx, 3
			div bx
			add dx, '0'		; преобразование в символ	
			mov [di], dx		; dest[i] = bx; i++
			mov dx, 0
			inc di
			cmp ax, 0
		jg wordToTernaryLoop	
			
		pop ax
		
		call reverse

		pop si
		pop di
		pop ebx
		pop bp
		ret 6
		
	wordToTernary endp

code ends
end