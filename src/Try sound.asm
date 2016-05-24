ORG 07c00h

etiq:
in al, 61h  
push ax ;Save state of port 61h 
mov bx, 6818; 1193180/175 175 is the frequency we want to heard
mov al, 6Bh  ; Select Channel 2, write LSB/BSB mode 3
out 43h, al 
mov ax, bx 
out 42h, al  ; Send the LSB
mov al, ah  
out 42h, al  ; Send the MSB
in al, 61h   ; Get the 8255 Port Contence
or al, 00000011h      
out 61h, al  ;End able speaker and use clock channel 2 for input
mov cx, 03h ; High order wait value
mov dx, 0D04h; Low order wait value
mov ax, 86h;Wait service
int 15h        
pop ax;restore Speaker state
out 61h, al
int 20h


boot:
db 510-(offset boot-offset etiq) dup (00h)
dw 0xAA55