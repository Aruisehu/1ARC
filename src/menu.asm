org 07e1h


call main

;Main Menu
;Use F1, F2, F3 to select the mode
;Escape to quit program

main PROC
    ; print the menu
    mov al, 1 
	mov bh, 0 
	mov bl, 0000_1011b ; choose the color
	mov cx, msg1end - offset msg1 ; calculate message size. 
	mov dl, 30; select the column where to print the message
	mov dh, 0 ; select the row
	push cs ; use to access to variable
	pop es
	mov bp, offset msg1; select the string to be print
	mov ah, 13h ; print the string pointed by es:bp
	int 10h  
	; don't need to change ah value, so we are doing exactly the same thing
	mov cx, menu1end - offset menu1 ; calculate message size. 
	mov dl, 3
	mov dh, 3
	mov bp, offset menu1
	int 10h 
	
	mov cx, menu2end - offset menu2 ; calculate message size. 
	mov dh, 5
	mov bp, offset menu2
	int 10h 
	
	mov cx, menu3end - offset menu3; calculate message size. 
	mov dh, 7
	mov bp, offset menu3
	int 10h
	
	mov cx, menu4end - offset menu4; calculate message size. 
	mov dh, 11
	mov bp, offset menu4
	int 10h 
	
	mov ah, 0
	int 16h
	cmp ah, 1
	je fin
	cmp ah, 10h
	je ftp
	cmp ah, 3Ch
	je pap
	cmp ah, 3Dh
	je wmp
	msg1 db " PIaNOS "
    msg1end: 
    menu1 db "F1   Free-To-play"
    menu1end:
    menu2 db "F2   Play a piece"
    menu2end:
    menu3 db "F3   Watch me play"
    menu3end:
    menu4 db "ESC  Exit" 
    menu4end:
main ENDP

fin:
int 20h

ftp:
call free_to_play ; doesn't exist for now
jmp fin

pap:
;call play_a_piece ; doesn't exist for now
jmp fin

wmp:
;call watch_me_play ; doesn't exist for now
jmp fin



free_to_play PROC 
    jmp start 
    start:
    ;piano plays with azertyui
    mov bx, offset pressed_key
    mov [bx], 12h
    call print_piano
    press_key:
    mov ah, 0
    int 16h ; wait for a pressed key
    mov bx, offset pressed_key
    cmp ah, 1 ; escape pressed, we quit the program
    je endf
    sub ah, 10h
    mov [bx], ah
    call print_piano
    jmp press_key
    endf:
    ret
free_to_play ENDP

print_piano PROC
    mov bx, offset column
    mov [bx], 0
    mov bx, offset key_off
    mov [bx], 0; put the value to 0
    mov dx, 0000h
    mov bh, 0
    mov ah, 2
    int 10h ; puts the cursor on the first column, first row
    mov cx, 0; use as a counter
    key:
    mov bx, offset color
    mov [bx], 00001111b
    mov bx, offset row
    mov [bx], 0 ; restore the value of the row
    mov bx, offset pressed_key
    cmp [bx], cl
    jnz continue:
    mov bx, offset color
    mov [bx], 00001100b
    continue:
    push cx ; save the value of the counter
    call print_key
    pop cx ; restore this value
    mov bx, offset key_off
    add [bx], 6 ; use to change key
    inc cx
    cmp cx, 12
    jnz key ;loop
    ret
print_piano ENDP

print_key PROC
    mov bx, offset key_off
    mov dh, [bx]
    mov bx, offset column
    mov [bx], dh
    mov dl, [bx] ; look which key to print (by looking which offset of key we have)
    mov cx, 8
    mov bx, offset row
    mov dh, [bx] ; load cursor's row
    mov bh, 0
    mov ah, 2
    int 10h ; move the cursor to print this key
    call print_key_row ; call function
    mov cx, 12 ;use to loop
    etiq:
    mov bx, offset key_off
    mov dh, [bx]
    mov bx, offset column
    mov [bx], dh
    mov dl, [bx]
    mov bx, offset row ;restore the value
    inc [bx]
    mov dh, [bx]
    mov bh, 0
    mov ah, 2
    int 10h ;move cursor
    push cx ; store cx (modified in function)
    call print_key_row
    pop cx ;restore cx value
    dec cx 
    cmp cx, 0
    jnz etiq ; loop while cx>0
    call print_key_end ; print end of the touch
    ret
print_key ENDP

print_key_end PROC
    ;function printing the end of a keyboard
    mov bx, offset key_off
    mov dh, [bx]
    mov bx, offset column
    mov [bx], dh
    mov dl, [bx]
    mov bx, offset row
    inc [bx]
    mov dh, [bx]
    mov bh, 0
    mov ah, 2
    int 10h  ; move cursor to the right position 
    mov al, '-' ; character to print
    mov bx, offset color
    mov bl,[bx]; set the color (4 MSB -> background color, 4 LSB-> foreground color)
    mov bh, 0 ; print on  page 1 
    mov cx, 6 ; number of character to print
    mov ah, 9 ; prepare interruption
    int 10h ; printing 
    ret
print_key_end ENDP

print_key_row PROC 
    ;function for printing a part of a keyboard 
    mov al, '|' ; character to print
    mov bx, offset color
    mov bl,[bx]; set the color (4 MSB -> background color, 4 LSB-> foreground color)
    mov bh, 0 ; print on  page 1 
    mov cx, 1 ; number of character to print
    mov ah, 9 ; prepare interruption
    int 10h ; printing
    mov bx, offset column ; pick up the address of the column
    inc [bx] ; add 1 to the column
    mov dl, [bx] ;set the cursor position on the column
    mov bh, 0 ; change page's 1 cursor
    mov ah, 2 ; prepare interruption
    int 10h ; change cursor position
    mov al, ' '
    mov bx, offset color
    mov bl,[bx]; set the color (4 MSB -> background color, 4 LSB-> foreground color)
    mov bh, 0 ; print on  page 1
    mov cx, 4
    mov ah, 9
    int 10h
    mov bx, offset column
    add [bx], 4
    mov dl, [bx]
    mov bh, 0
    mov ah, 2
    int 10h 
    mov al, '|'  
    mov bx, offset color
    mov bl,[bx]; set the color (4 MSB -> background color, 4 LSB-> foreground color)
    mov bh, 0 ; print on  page 1
    mov cx, 1
    mov ah, 9
    int 10h
    ret
print_key_row ENDP

color db 00001111b
column db 0 ; must change value in code to display other touch
row db 0 
key_off db 0
pressed_key db 12h
