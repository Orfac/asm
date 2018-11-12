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
	
    message db 'Hello world!','$'
	newLine db 10, 13, '$'
	color equ 0Ah
data ends	

code segment para public 'code'
assume ds:data, ss:stack, cs:code
.486		
	

_main:

    mov   ax,seg message
    mov   ds,ax

    mov   ah,09
    lea   dx,message
    int   21h

    mov   ax,4c00h
    int   21h

code   ends
end _main