.model small

stack segment para stack 'stack'
	 db 100h DUP(?)
stack ends
	
data segment public 'data'	
	value dw 26
	check db 1
	output db 12 DUP('$'), '$'
	WORD_MASK EQU 11111111111111111000000000000000b
	LOW_MASK EQU 00000000000000000100000000000000b
	HIGH_MASK EQU 10000000000000000000000000000000b
data ends	

code segment public 'code'
assume ds:data, ss:stack, cs:code
.486

main:
		
start:	  
	
	mov eax, 170
	ror eax, 1
	mov edx, 0 
	mov ebx, 2
	div ebx

	ror eax, 1
	and eax, WORD_MASK
	cmp edx, 1
	jne endd
	or eax, HIGH_MASK 
	endd:
	xor eax, eax
	mov ax, 4c00h	
	int	21h		

code ends
end	main