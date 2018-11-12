.model small

stack segment para stack 'stack'
	 db 100h DUP(?)
stack ends
	
data segment public 'data'	
	value dw 26
	check db 1
	output db 12 DUP('$'), '$'
data ends	

code segment public 'code'
assume ds:data, ss:stack, cs:code
.486

main:
		
start:	  
	
	mov ax, data
	mov ds, ax
	mov ax, [value]
	lea si, output
	wordToTernaryLoop:
			mov bx, 3
			div bx
			add dx, '0'		; преобразование в символ	
			mov [si], dx		; dest[i] = bx; i++
			mov dx, 0
			inc si
			mov bx, ax
			cmp bx, 0
	jg wordToTernaryLoop	
	xor eax, eax
	mov ax, 4c00h	
	int	21h		

code ends
end	main