org 7c00h      ; set location counter.

boot:
mov ax, 0 ; Reset floppy system
int 13h

mov ax, 0000h
mov es, ax
mov bx, 7e10h ; Point to the future location of the code we load
mov dl, 0h ; Floppy Number
mov dh, 0h ; Head Number
mov ch, 0h ; Cylinder number
mov cl, 2h ; Sector Number
mov al, 4 ; Number of sector to load
mov ah, 2 ; set the interruption mode
int 13h   ; Load code pointed in RAM 
jnc exit
jmp boot


exit:
jmp 0000:7e10h ;jump to the code we load
ret

db 504-(offset exit-offset boot) dup (00h) ; Put 0 in the memory
dw 0xAA55 ; Way to stop bootstrap  





