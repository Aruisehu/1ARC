
ORG    100h	

etiq:
mov ah, 0 ;prepare the interruption to read the keyboard input
int 16h ;The interruption, the program stops until you press a key
cmp ah, 1 ; Check if the key is "échap"
je fin ;Jump to the end if it is the case
mov ah, 0Eh ; int 16h puts BIOS scancode of the key in AH and the ASCII code in AL
		;Prepare next interruption
int 10h ;Display on the screen the ASCII characters stored in AL
jmp etiq ;Restart the code

fin:
ret
