.model tiny
.code
org 100h

main:
    jmp setup

    SCREEN_SIZE equ 25 * 80

    SCANCODE_Q equ 10h
    SCANCODE_M equ 32h
    SCANCODE_R equ 13h

    flags db 16 dup(' ')
    ALT_PRESSED_MASK equ 0001000b ; 0 bit - right shift, 1 bit - left, 3 bit - alt
    SHIFT_PRESSED_MASK equ 0000011b
    REPLACED_INTERRUPT equ 09h
    isActive dw 0
    screen dw SCREEN_SIZE dup(' ')

    installMessage db 'Program has been started. Press Shift+Alt+M to show flags register or Shift+Alt+Q to terminate.', '$'
    runningMessage db 'Program is already running. Press Shift+Alt+M to show flags register or Shift+Alt+Q to terminate.', 10, 13, '$'
    terminateMessage db 10, 13, 'Program was terminated.', 10, 13, '$'
    interCalled db 10, 13, 'Interruption called.', 10, 13, '$'
    systemHandler dd 00000000h

print macro string:REQ
    mov ax, cs
    mov ds, ax
    lea dx, string
    mov ah, 09h
    int 21h
endm

; резидентный обработчик
customHandler proc far uses ax cx di si ds es
; Checking keyboard flags
    mov ah, 02h
    int 16h
    test al, ALT_PRESSED_MASK
    jz invokeSystemInterrupt
    test al, SHIFT_PRESSED_MASK
    jz invokeSystemInterrupt

    in al, 60h ; Copies value from I/O port 60h to al
    ; Unload program if Alt+Shift+Q is pressed
    ; cmp word ptr cs:isActive, 1
    ; je restoreScreen
    cmp al, SCANCODE_Q
    je terminate
    ; Save screen, clear screen and show register if Alt+Shift+M is pressed
    cmp al, SCANCODE_M
    je saveScreenAndShowFlags ; makes isActive = 1
    cmp al, SCANCODE_R
    je restoreScreen
    jmp invokeSystemInterrupt

    saveScreenAndShowFlags:
        mov word ptr cs:isActive, 1
        ; SAVE SCREEN
        ; Size of the screen
        mov cx, SCREEN_SIZE
        ; DS:SI - screen address
        mov ax, 0b800h
        mov ds, ax
        mov si, 0
        ; ES:DI - where to write
        mov ax, cs
        mov es, ax
        mov di, offset screen
        cld

        rep movsw ; Move CX words from DS:SI to ES:DI
        ; SCREEN CLEAR
        ; Size of the screen
        mov cx, SCREEN_SIZE
        ; ES:DI Screen address
        mov ax, 0b800h
        mov es, ax
        mov di, 0
        ; New content of the screen
        mov ax, 0720h
        ; Fill CX words at ES:DI with AX
        rep stosw
        ; print registers
        pushf
        pop ax
        mov cx, 8
        mov di, 20 * 80 + 50
        mov ax, 0b800h
        mov es, ax

        mov byte ptr es:[di], 'M'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], 'O'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], 'D'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], 'E'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], ':'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], ' '
        inc di
        mov byte ptr es:[di], 14
        inc di

        xor ax, ax
        mov ah, 0Fh
        int 10h
        xor bx, bx
        mov bh, al
        cycle:
        shl bh, 1
        jnc zero

    
        mov byte ptr es:[di], '1'
        inc di
        mov byte ptr es:[di], 14
        jmp endIteration

        zero:
            mov byte ptr es:[di], '0'
            inc di
            mov byte ptr es:[di], 14
        endIteration:
        inc di
        loop cycle

        mov di, 22 * 80 + 50
        mov ax, 0b800h
        mov es, ax
        mov byte ptr es:[di], 'C'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], 'O'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], 'L'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], 'U'
        inc di
        mov byte ptr es:[di], 14
        inc di

        mov byte ptr es:[di], 'M'
        inc di
        mov byte ptr es:[di], 14
        inc di

        mov byte ptr es:[di], 'N'
        inc di
        mov byte ptr es:[di], 14
        inc di

        mov byte ptr es:[di], 'S'
        inc di
        mov byte ptr es:[di], 14
        inc di
        mov byte ptr es:[di], ':'
        inc di
        mov byte ptr es:[di], 14
        inc di

        mov byte ptr es:[di], ' '
        inc di
        mov byte ptr es:[di], 14
        inc di

        mov cx, 8
        xor ax, ax
        mov ah, 0Fh
        int 10h
        xor bx, bx
        mov bh, ah
        scycle:
        shl bh, 1
        jnc szero

    
        mov byte ptr es:[di], '1'
        inc di
        mov byte ptr es:[di], 14
        jmp ssendIteration

        szero:
            mov byte ptr es:[di], '0'
            inc di
            mov byte ptr es:[di], 14
        ssendIteration:
        inc di
        loop scycle
    jmp skipSystemInterrupt
    restoreScreen:
    ; cmp al, 01h
    ; jl skipSystemInterrupt
    ; cmp al, 32h
    ; jg skipSystemInterrupt
    ; inc word ptr cs:count
    ; cmp word ptr cs:count, 8
    ; jle skipSystemInterrupt
        mov word ptr cs:isActive, 0
        ; mov word ptr cs:isActive, 1
        mov cx, SCREEN_SIZE
        ; DS:SI - from where to write
        mov ax, cs
        mov ds, ax
        mov si, offset screen
        ; ES:DI Screen address
        mov ax, 0b800h
        mov es, ax
        mov di, 0
        rep movsw ; Move CX words from DS:SI to ES:DI
    jmp invokeSystemInterrupt
    terminate:
    ; return old handler to the table of interruptions
        mov ax, word ptr cs:systemHandler[2]
        mov ds, ax
        mov dx, word ptr cs:systemHandler
        mov ax, 2509h
        int 21h
        ; set flags
        mov ax, 25FFh
        mov dx, 0000h
        int 21h
        push es
        ; free block of memory which starts at ES:0000
        mov es, cs:2Ch
        mov ah, 49h
        int 21h
        ; delete resident
        push cs
        pop es
        mov ah, 49h
        int 21h
        pop es
        ; print message
        push ds
        print cs:terminateMessage
        pop ds
    jmp skipSystemInterrupt
    ; calling system interuuption
    invokeSystemInterrupt:
    pushf
    call cs:systemHandler

    jmp exit
    ; skipping system interruption
    skipSystemInterrupt:
        in al, 61H
        mov ah, al
        or al, 80h
        out 61H, al
        xchg ah, al
        out 61H, al
        mov al, 20H
        out 20H, al
    exit:
    iret
customHandler endp

customHandlerEnd:
    setup:
    ; Getting interrupt vector
        mov ax, 35FFh
        int 21h ; AL - interrupt number = FF; returns ES:BX - current interrupt handler
        cmp bx, 0000h
        jne running
    install:
        print installMessage
        ; setting interruption vector FF
        mov ax, 25FFh
        mov dx, 0001h
        int 21h ; DS:DX - new interrupt handler
        ; getting address of interruptions
        mov ah, 35h
        mov al, REPLACED_INTERRUPT
        int 21h
        mov word ptr cs:systemHandler, bx
        mov word ptr cs:systemHandler+2, es
        ; setting interruption vector
        mov ah, 25h
        mov al, REPLACED_INTERRUPT
        lea dx, customHandler
        int 21h
        mov dx, offset customHandler - offset customHandlerEnd
        mov cl, 4
        shr dx, cl
        inc dx
        ; finish and keep resident, AL - exit code 0, in DX - amount of program's memory in paragraphs
        ; paragraphs - block with length 16 bytes
        mov ax, 3100h
        int 21h
    running:
        print runningMessage
        mov ax, 4C00h
        int 21h
end main