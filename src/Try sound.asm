ORG 07c00h

etiq:
MOV al, 0B6h
OUT 43h, al
MOV ax, 2711
OUT 42h, al
mov al, ah
OUT 42h, al
IN al, 61h
OR al, 3
OUT 61h, al
jmp etiq

boot:
db 510-(offset boot-offset etiq) dup (00h)
dw 0xAA55