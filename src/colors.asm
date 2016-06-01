ORG 07c00h

etiq:

call disp_square         

disp_square PROC
    mov al, 13h
    mov ah, 0
    int 10h
    
    mov cx, 10  ;col
    mov dx, 10  ;row
    mov ah, 0Ch ; put pixel
    mov al, 0000b
    
    colcount:
    inc cx
    int 10h
    cmp cx, 100
    JNE colcount
    
    mov cx, 100  ; reset to start of col
    inc dx      ;next row
    inc al
    cmp dx, 100
    JNE colcount

    ret
    
disp_square ENDP


boot:
db 510-(offset boot-offset etiq) dup (00h)
dw 0xAA55