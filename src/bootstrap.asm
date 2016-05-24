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

code:
mov ah, 0
int 16h
cmp ah, 1
je fin
mov ah, 0Eh
int 10h
jmp code

fin:
int 20h ;Like RET instructions                                     



