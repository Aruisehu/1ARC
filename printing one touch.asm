org 100h 

call print_key
ret
print_key PROC
    mov bx, offset column
    mov dl, [bx] ; load cursor's column
    mov bx, offset row
    mov dh, [bx] ; load cursor's row
    call print_key_row ; call function
    mov cx, 12 ;use to loop
    etiq:
    mov bx, offset column
    mov [bx], 0
    mov dl, [bx]
    mov bx, offset row
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
    mov bx, offset column
    mov [bx], 0
    mov dl, [bx]
    mov bx, offset row
    inc [bx]
    mov dh, [bx]
    mov bh, 0
    mov ah, 2
    int 10h 
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

color db 00001111b
column db 0 ; must change value in code to display other touch
row db 0