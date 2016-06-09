org 7e10h

push es
pop ds
;Main Menu
;Use F1, F2, F3 to select the mode
;Escape to quit program
main:
; print the menu
call refresh
mov al, ' ' ; character to print
mov bl, 00001001b; set the color (4 MSB -> background color, 4 LSB-> foreground color)
mov bh, 0 ; print on  page 1 
mov cx, 4000 ; number of character to print
mov ah, 9 ; prepare interruption
int 10h
mov al, 1 
mov bh, 0 
mov bl, 0000_1011b ; choose the color
mov cx, msg1end - offset msg1 ; calculate message size. 
mov dl, 30; select the column where to print the message
mov dh, 0 ; select the row
mov bp, offset msg1; select the string to be print
mov ah, 13h ; print the string pointed by es:bp
int 10h  
	; don't need to change ah value, so we are doing exactly the same thing
	; do it again, 3 times
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
mov dh, 10
mov dl, 0
mov bp, offset menu4
int 10h
;interaction in menu	
mov ah, 0
int 16h
cmp ah, 3Bh ; user pressed F1
je ftp ; go to free to play
cmp ah, 3Ch ; user pressed F2
je pap ; go to play a piece
cmp ah, 3Dh ; user pressed F3
je wmp ;go to watch me play
jne main ; user doesn't press a correct key

ftp:
call refresh ; make the screen blank
press_key:
    call print_piano
    mov ah, 0
    int 16h ; wait for a pressed key
    mov bx, offset pressed_key
    cmp ah, 1 ; escape pressed, we go back to menu
    je end_free
    sub ah, 10h
    cmp ah, 12
    jge press_key ;user doesn't press the right key
    mov [bx], ah ; put the pressed key in the pressed_key variable
    call print_piano
	call play_sound_freq ; play sound
    jmp press_key ; loop
    end_free:
jmp main

pap:
call refresh ; make the screen blank
menupap: 
    mov al, 1 
    mov bh, 0 
    mov bl, 0000_1111b ; choose the color
    mov cx, pap1end - offset pap1 ; calculate message size. 
    mov dl, 25; select the column where to print the message
    mov dh, 0 ; select the row
    mov bp, offset pap1; select the string to be print
    mov ah, 13h ; print the string pointed by es:bp
    int 10h
    ; do it again 3 times
    mov cx, pap2end - offset pap2 ; calculate message size. 
    mov dl, 3
    mov dh, 3
    mov bp, offset pap2
    int 10h
    mov cx, pap3end - offset pap3 ; calculate message size. 
    mov dh, 5
    mov bp, offset pap3
    int 10h
    mov cx, pap4end - offset pap4 ; calculate message size. 
    mov dh, 7
    mov bp, offset pap4
    int 10h
    mov cx, pap5end - offset pap5 ; calculate message size. 
    mov dh, 9
    mov bp, offset pap5
    int 10h
    ; interaction  
    mov ah, 0
    int 16h ;menu "Pick a song"
    cmp ah, 3Bh ; press F1, choose piece n°1
    jne other1
    mov bx, offset piece ; choose the piece n°1
    push bx ;put this pointer in the stack
    je play ;go to play
    other1:
    cmp ah, 3Ch
    jne pap_esc
    mov bx, offset piece2
    push bx
    je play
    ;back to menu if esc is pressed
    pap_esc:
    cmp ah, 1h ; escape pressed: leave to main menu
    jne other2
    jmp main
    other2:
    jmp menupap ; if invalid key, wait for a valid one 
    ;piano plays with azertyuiop^$
    play:
    call print_piano ; print piano
    pop bx ; restore the pointer of the chosen piece
    beginp:
    mov cl, 11 ; check which key is next (do it with loop)
    press_key1:
    cmp [bx], 13 ; if 13: the piece is done
    je end_play ; back to main menu
    cmp [bx], cl ; look if the current key point by cl is the next key to press
    jne next ; if not decrements cl and loop
    mov al, cl
    mov dl, 6
    mul dl ; multiply the key by 6 (so al*dl) results store in ax
    push bx ; store the pointer of piece in stack
    push cx ; store counter in stack
    call print_next
    pop cx ; restore counter value (FIFO stack)
    pop bx ; restore piece pointer
    next:
    cmp cl, 0 ; If loop finished go to piano
    je piano
    dec cl
    jmp press_key1 ; loop
    piano:
    mov ah, 0
    int 16h ; wait for a pressed key
    push bx ; store the pointer of piece in stack
    mov bx, offset pressed_key
    cmp ah, 1 ; escape pressed, we quit the program
    je end_play
    sub ah, 10h
    mov [bx], ah ; stock the pressed key in pressed_key var
    call print_piano
    call play_sound_freq  ; play sound
    pop bx ; restore piece pointer
    inc bx ; point to the next key to press
    jmp beginp ; loop
    end_play: 
jmp main 

wmp:
call refresh ; make screen all black
menuwmp:
; same as pap 
    mov al, 1 
    mov bh, 0 
    mov bl, 0000_1111b ; choose the color
    mov cx, pap1end - offset pap1 ; calculate message size. 
    mov dl, 25; select the column where to print the message
    mov dh, 0 ; select the row
    mov bp, offset pap1; select the string to be print
    mov ah, 13h ; print the string pointed by es:bp
    int 10h
    mov cx, pap2end - offset pap2 ; calculate message size. 
    mov dl, 3
    mov dh, 3
    mov bp, offset pap2
    int 10h
    mov cx, pap3end - offset pap3 ; calculate message size. 
    mov dh, 5
    mov bp, offset pap3
    int 10h
    mov cx, pap4end - offset pap4 ; calculate message size. 
    mov dh, 7
    mov bp, offset pap4
    int 10h
    mov cx, pap5end - offset pap5 ; calculate message size. 
    mov dh, 9
    mov bp, offset pap5
    int 10h  
    mov ah, 0
    int 16h ;menu "Pick a song"
    cmp ah, 3Bh
    jne wmp_key
    mov bx, offset piece
    push bx 

    je wmp_play
 
    wmp_key:
    cmp ah, 3Ch
    jne wmp_esc
    mov bx, offset piece2
    push bx
    je wmp_play
    ;back to menu if esc is pressed
    wmp_esc:
    cmp ah, 1h
    jne wmp_invalid_key
    jmp main
    wmp_invalid_key:
    jmp menuwmp ; if invalid key, wait for a valid one 
    ;piano plays with azertyuiop^$
    wmp_play:
    call print_piano
    pop bx ; restore piece pointer
    beginw:
    mov cl, 11
    press_key2:
    cmp [bx], 13
    je end_play_w
    cmp [bx], cl
    jne next_w
    mov al, cl
    mov dl, 6
    mul dl
    push bx
    push cx
    call print_next
    pop cx 
    pop bx
    next_w:
    cmp cl, 0
    je piano_w
    dec cl
    jmp press_key2 ; same as play a piece
    ; display key + sound
    piano_w:
    mov dx, [bx]
    push bx ; store the value of the key to be pressed
    mov bx, offset pressed_key
    mov [bx], dx ; make the computer press the right key
    call print_piano
    call play_sound_freq ; play sound
    mov bx, offset pressed_key
    mov [bx], 12h ; looks like the key is released
    call print_piano ; print piano to see the effect
    mov cx, 07h
    mov dx, 0A120h
    mov ah, 86h
    int 15h ; wait 0.5 second
    pop bx ;restore piece pointer value
    inc bx ; go see the next key to print
    jmp beginw ; loop
    end_play_w: 
jmp main

refresh PROC
    ;use to make the screen white 
    mov cl, 26
    xor bx, bx ;put bx to 0
    rowr:
    dec cl
    mov dh, cl
    mov dl, 0
    mov ah, 2
    int 10h
    mov al, ' ' ; character to print
    push cx
    mov cx, 80 ; number of character to print
    mov ah, 9 ; prepare interruption
    int 10h 
    pop cx
    cmp cl, 0
    jne rowr
    ret
refresh ENDP
    
print_next PROC
    mov dl, al ;set the cursor position on the column  
    mov dh, 14
    mov bh, 0 ; change page's 1 cursor
    mov ah, 2 ; prepare interruption
    int 10h ; change cursor position
    mov al, '-' ; character to print
    mov bl, 00001001b; set the color (4 MSB -> background color, 4 LSB-> foreground color)
    mov bh, 0 ; print on  page 1 
    mov cx, 6 ; number of character to print
    mov ah, 9 ; prepare interruption
    int 10h ; printing
    ret
print_next ENDP
    
print_piano PROC
    mov cl, 26
    xor bx, bx ;put bx to 0
    rowrp:
    dec cl
    mov dh, cl
    mov dl, 0
    mov ah, 2
    int 10h
    mov al, ' ' ; character to print
    push cx
    mov cx, 80 ; number of character to print
    mov ah, 9 ; prepare interruption
    int 10h 
    pop cx
    cmp cl, 0
    jne rowrp
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
    pop cx ;restore cx value
    dec cx 
    cmp cx, 0
    jnz etiq ; loop while cx>0
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
    int 10h ; printing ; print end of the touch
    pop cx ; restore this value
    mov bx, offset key_off
    add [bx], 6 ; use to change key
    inc cx
    cmp cx, 12
    jnz key ;loop
    
    mov dl, 0
    mov dh, 14
    mov bh, 0
    mov ah, 2
    int 10h  ; move cursor to the right position 
    mov al, ' ' ; character to print
    mov bl, 0
    mov bh, 0 ; print on  page 1 
    mov cx, 50h ; number of character to print
    mov ah, 9 ; prepare interruption
    int 10h ; printing
    ret
print_piano ENDP

play_sound_freq PROC
	mov bx, offset pressed_key
	cmp [bx], 0
	je freq_key_0 
	cmp [bx], 1
	je freq_key_1
	cmp [bx], 2
	je freq_key_2  
	cmp [bx], 3
	je freq_key_3 
	cmp [bx], 4
	je freq_key_4 
	cmp [bx], 5
	je freq_key_5
	cmp [bx], 6
	je freq_key_6 
	cmp [bx], 7
	je freq_key_7 
	cmp [bx], 8
	je freq_key_8 
	cmp [bx], 9
	je freq_key_9 
	cmp [bx], 10
	je freq_key_10 
	cmp [bx], 11
	je freq_key_11 
    jmp ply_snd

	freq_key_0:
	   mov bx, offset frequency
	   mov [bx], 4560; do (C4)
	   jmp ply_snd
	freq_key_1:
	   mov bx, offset frequency
	   mov [bx], 4305; do# (C4#)
	   jmp ply_snd  
	freq_key_2:
	   mov bx, offset frequency
	   mov [bx], 4063; re (D4) 
	   jmp ply_snd
	freq_key_3:
	   mov bx, offset frequency
	   mov [bx], 3835; re# (D4#)
	   jmp ply_snd
	freq_key_4:
	   mov bx, offset frequency
	   mov [bx], 3620; mi (E4)
	   jmp ply_snd
	freq_key_5:
	   mov bx, offset frequency
	   mov [bx], 3417; fa (F4)
	   jmp ply_snd   
	freq_key_6:
	   mov bx, offset frequency
	   mov [bx], 3225; fa# (F4#) 
	   jmp ply_snd
	freq_key_7:
	   mov bx, offset frequency
	   mov [bx], 3044; sol (G4)
	   jmp ply_snd
	freq_key_8:
	   mov bx, offset frequency
	   mov [bx], 2873; sol# (G4#)
	   jmp ply_snd
	freq_key_9:
	   mov bx, offset frequency
	   mov [bx], 2712; la (A4)
	   jmp ply_snd
	freq_key_10:
	   mov bx, offset frequency
	   mov [bx], 2560; la# (A4#)
	   jmp ply_snd
	freq_key_11:
	   mov bx, offset frequency
	   mov [bx], 2416; si (B4)
	   jmp ply_snd
			 
	ply_snd:       
	    MOV     DX,10000         ; Number of times to repeat whole routine.

    	MOV     BX, offset frequency           ; Frequency value.
    
    	MOV     AL, 10110110B    ; The Magic Number (use this binary number only)
    	OUT     43H, AL          ; Send it to the initializing port 43H Timer 2.
    
    	NEXT_FREQUENCY:          ; This is were we will jump back to 2000 times.
    
    	MOV     AX, [BX]           ; Move our Frequency value into AX.
    
    	OUT     42H, AL          ; Send LSB to port 42H.
    	MOV     AL, AH           ; Move MSB into AL  
    	OUT     42H, AL          ; Send MSB to port 42H.
    
    	IN      AL, 61H          ; Get current value of port 61H.
    	OR      AL, 00000011B    ; OR AL to this value, forcing first two bits high.
    	OUT     61H, AL          ; Copy it to port 61H of the PPI Chip
    							 ; to turn ON the speaker.
    
    	MOV     CX, 100          ; Repeat loop 100 times
    	DELAY_LOOP:              ; Here is where we loop back too.
    	LOOP    DELAY_LOOP       ; Jump repeatedly to DELAY_LOOP until CX = 0
    
    	DEC     DX               ; Decrement repeat routine count
    
    	CMP     DX, 0            ; Is DX (repeat count) = to 0
    	JNZ     NEXT_FREQUENCY   ; If not jump to NEXT_FREQUENCY
    							 ; and do whole routine again.
    
    							 ; Else DX = 0 time to turn speaker OFF
    
    	IN      AL,61H           ; Get current value of port 61H.
    	AND     AL,11111100B     ; AND AL to this value, forcing first two bits low.
    	OUT     61H,AL           ; Copy it to port 61H of the PPI Chip 
	ret
play_sound_freq ENDP
  
msg1 db " PIaNOS "
msg1end: 
menu1 db "F1   Free-To-play"
menu1end:
menu2 db "F2   Play a piece"
menu2end:
menu3 db "F3   Watch me play"
menu3end: 
menu4 db "Please read the user manual before playing" 
menu4end:
pap1 db "Choose a piece: "
pap1end: 
pap2 db "F1   By night, in the moonlight"
pap2end:
pap3 db "F2   Ode To Joy - Beethoven"
pap3end:
pap4 db "More releases in the future!"
pap4end:
pap5 db "ESC Main Menu"
pap5end: 
color db 00001111b
column db 0 ; must change value in code to display other touch
row db 0 
key_off db 0
pressed_key db 9h
frequency dw 12h
next_key db 12h
piece db 5,5,5,7,9,7,5,9,7,7,5,5,5,5,7,9,7,5,9,7,7,5,7,7,7,7,2,2,7,5,4,2,0,5,5,5,7,9,7,5,9,7,7,5,13
piece2 db 4,4,5,7,7,5,4,2,0,0,2,4,4,2,2,4,4,5,7,7,5,4,2,0,0,2,4,2,0,0,13