; BIOS reads 512 bytes from cylinder: 0, head: 0, sector: 1
; of bootable floppy drive, then it loads this data into
; memory at 0000:7c00h and starts the execution from the first byte.

; note: this file is assembled into .bin file.
;       default configuration for .binf file:
;       load segment: 0000, load offset: 7c00, 
;       same values are set to CS and IP registers accordingly.

; .binf file is used by the emulator to decide at what memory
; address to load binary file and start the execution, when 
; loading address is set to 0000:7c00 it emulates the way BIOS
; loads the boot record into the memory.

; the output of this format is identical to format created from
; bin template, both templates create plain binary files.
; .boot output type is outdated because of its redundancy.
; you can write .bin file to boot record of a real
; floppy drive using writebin.asm (it's required to assemble this file first)

; note: you may not use dos interrupts for boot record code,
;       unless you manually replace them in interrupt vector table.
;       (refer to global memory map in documentation)
 
org 7c00h      ; set location counter.

boot:
mov ax, 0 ; Reset floppy system
int 13h

mov ax, 4F00h
mov es, ax
mov bx, 0F00h ; Point to the future location of the code we load
mov dl, 0h ; Floppy Number
mov dh, 0h ; Head Number
mov ch, 0h ; Cylinder number
mov cl, 2h ; Sector Number
mov al, 2 ; Number of sector to load
mov ah, 2 ; set the interruption mode
int 13h   ; Load code pointed in RAM 
jnc exit
jmp boot  ; else retry

exit:
jmp 4F00h:0F00h ;jump to the code we load
ret

db 504-(offset exit-offset boot) dup (00h) ; Put 0 in the memory
dw 0xAA55 ; Way to stop bootstrap  
 
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
    mov [bx], 00001100b
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
key_off db 0
pressed_key db 12h


