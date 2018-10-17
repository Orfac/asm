.model small

stack segment para stack 'stack'
	 db 100h DUP(?)
stack ends
	
data segment public 'data'	
	
	string db  'FGADCADWEQCD/62\k+-ls?93|-+t!s f764^URd-k:s-+33jdskf83-=\ . 17j', '$'
	bitmask dq  000100101110100010101111010001010001001011101100101001010100100b	

	res1 db sizeof string DUP('$') ; ожидаемый результат: DDEQC
	res2 db sizeof string DUP('$') ; ожидаемый результат: Rd-k:s-+33jdskf83-=\ . 17lsj наоборот
	
	init_message_intro db 'Initial string:', '$'
	first_result_intro db 'First result string:', '$'
	second_result_intro db 'Second result string:', '$'
	
	R_is_found db 0	; показывает, был ли предыдущий символ R

data ends	

code segment public 'code'
assume ds:data, ss:stack, cs:code
.486

main:
    jmp start
print macro arg:REQ
    mov ah, 09h
    lea dx, arg
    int 21h
	printLine
endm

printLine macro ; печатает символы 10 и 13 (перенос строки)
	mov ah, 02h
	mov dx, 10
	int 21h
	mov ah, 02h
	mov dx, 13
	int 21h
endm

; EBX - аргумент
printBinaryWord proc near
	push ax
	push dx
	push cx

	mov cx, 32 ; word
	
	PROC_LOOP:
		
		shl ebx, 1 
		jc print_1	; if (CF != 1)
		
			mov dl, '0'
			jmp print_bit
		
		print_1:
		mov dl, '1'
		
		print_bit:
		mov ah, 02h
		int 21h
		
	loop PROC_LOOP
	
	pop cx
	pop dx
	pop ax
	
	ret
	
printBinaryWord endp
		
start:	  
	
	mov ax, data
	mov ds, ax
	
	print init_message_intro
	print string
	
	; Первая строка
	; EAX - половина маски
	; EBX - промежуточное хранение данных
	; SI - индекс исходной строки
	; DI - индекс строки результата
	; DL - текущий символ
	; DH - индекс в маске
	mov eax, dword ptr bitmask + 4
	mov ebx, eax
	call printBinaryWord
	
	xor si, si
	xor di, di

	mov dh, 31
	mov cx, sizeof string
	dec cx
	FIRST_LOOP:
	
		mov dl, string[si]
		
		cmp si, 32	; if (si == 32)
		jne letter_check
			; когда дойдём до 32 символа, переходим на вторую половину маски
			mov eax, dword ptr bitmask
			mov ebx, eax
			call printBinaryWord
			printLine
			printLine
			
			mov dh, 31
		
		letter_check:
		cmp dl, 'A'	; if(dl >= 'A' && dl <= 'Z')
		jl end_if1
		cmp dl, 'Z'
		jg end_if1
		
			push cx
			
			mov ebx, 1    ; ebx = 1 << dh
			mov cl, dh
			shl ebx, cl
			and ebx, eax  ; ebx = ebx & eax
			
			pop cx
			
			cmp ebx, 0
			je end_if1
						
			mov res1[di], dl	; res1 += dl
			inc di 
			
		end_if1:
		
		inc si
		dec dh
	
	loop FIRST_LOOP
	
	print first_result_intro
	print res1
	printLine

second_part:
	; Печатаем вторую строку результата
	; SI - индекс исходной строки (идём справа налево)
	; DI - индекс строки результата
	; DL - текущий символ
	xor di, di
	mov cx, sizeof string
	mov si, cx
	sub si, 2
	SECOND_LOOP:
	
		mov dl, string[si]
		
		cmp dl, 'R'	; if(dl == '-') R_is_found = 1
		jne else_if2
		
			mov R_is_found, 1
			jmp end_if2
			
		else_if2:
		cmp R_is_found, 1	 ; if(R_is_found)
		jne end_if2
		mov R_is_found, 0 ; R_is_found = 0
		cmp dl, 'U'			 ; if(dl == 'U')...
		je loop2_end
		
		end_if2:
		mov res2[di], dl
		
		inc di 
		dec si
		
	loop SECOND_LOOP
	
	loop2_end:
	print second_result_intro
	print res2
	
	xor eax, eax
	mov ax, 4c00h	
	int	21h		

code ends
end	main