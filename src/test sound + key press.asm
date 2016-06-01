ORG 07c00h

etiq:
;piano plays with azertyui
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

add dx, [bx]
mov bx, offset frequency
mov [bx], dx
    
call play_sound 

jmp press_key
endf:
ret
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
    mov [bx], 00000100b
    continue:
    push cx ; save the value of the counter
    call print_key
    pop cx ; restore this value
    mov bx, offset key_off
    add [bx], 7 ; use to change key
    inc cx
    cmp cx, 8
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
    etiq2:
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
    jnz etiq2 ; loop while cx>0
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
    mov cx, 7 ; number of character to print
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
    mov cx, 5
    mov ah, 9
    int 10h
    mov bx, offset column
    add [bx], 5
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

play_sound PROC      
	;cli                      ; Clear interuption

	MOV     DX,5000         ; Number of times to repeat whole routine.

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

	MOV     CX, 1000          ; Repeat loop 100 times
	DELAY_LOOP:              ; Here is where we loop back too.
	LOOP    DELAY_LOOP       ; Jump repeatedly to DELAY_LOOP until CX = 0


	;INC     BX               ; Incrementing the value of BX lowers 
							 ; the frequency each time we repeat the
							 ; whole routine

	DEC     DX               ; Decrement repeat routine count

	CMP     DX, 0            ; Is DX (repeat count) = to 0
	JNZ     NEXT_FREQUENCY   ; If not jump to NEXT_FREQUENCY
							 ; and do whole routine again.

							 ; Else DX = 0 time to turn speaker OFF

	IN      AL,61H           ; Get current value of port 61H.
	AND     AL,11111100B     ; AND AL to this value, forcing first two bits low.
	OUT     61H,AL           ; Copy it to port 61H of the PPI Chip
    ret          ; to turn OFF the speaker.
play_sound ENDP

color db 00001111b
column db 0 ; must change value in code to display other touch
row db 0 
key_off db 0
pressed_key db 12h
frequency dw 24h

boot:
db 510-(offset boot-offset etiq) dup (00h)
dw 0xAA55