segment .data 
    Text db "Hello World!"
    newLine db 10,1
segment .bss
segment .text
    global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, Text
    mov edx, 12
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, 0
    int 0x80