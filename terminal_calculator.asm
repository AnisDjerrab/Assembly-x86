segment .data
    CalculatorText db "                                ", 10, " sqrt()   DEL     OFF      AC   ", 10, "   7      8       9        /    ", 10, "   4      5       6        *    ", 10, "   1      2       3        +    ", 10, "   ^      0       =        +    ", 10, 10, "Press [h] to see your history", 10, "Press [SUPPR] for DEL", 10, "Press [x] for OFF", 10, "Press [r] for AC", 10, "Press [s] for sqrt()", 10
segment .bss
    number1 resb 9
    number2 resb 9
    operator resb 1
segment .text
    global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, CalculatorText
    mov edx, 307
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80