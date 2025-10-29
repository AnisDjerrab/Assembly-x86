segment .data
    CalculatorText db "                                ", 10, " sqrt()   DEL     OFF      AC   ", 10, "   7      8       9        /    ", 10, "   4      5       6        *    ", 10, "   1      2       3        +    ", 10, "   ^      0       =        +    ", 10, 10, "Press [h] to see your history", 10, "Press [SUPPR] for DEL", 10, "Press [x] for OFF", 10, "Press [r] for AC", 10, "Press [s] for sqrt()", 10
    ; that's executed in compilation time !
    shiftTable:
        %assign i, 1
        %rep 307
            db 27, '[', '0'+i, 'C'
            %assign i i+1
        %endrep
    lengthShiftTable:
        %assign i, 1
        %rep 307
            %if i < 10
                dw 4
            %elif i < 100
                dw 5
            %else 
                dw 6
            %endif
            %assign i i+1
        %endrep
segment .bss
    number1 resb 9
    number2 resb 9
    operator resb 1
    termiosSaved resb 36 ; contains all termios settings
    termios resb 36
segment .text
    global _start
_start:

    ; printing the calcultor general form
    mov eax, 4
    mov ebx, 1
    mov ecx, CalculatorText
    mov edx, 307
    int 0x80

    ; recover termios settings
    mov eax, 54
    mov ebx, 1
    mov ecx, 0x5401
    mov edx, termiosSaved
    int 0x80
    mov termios, termiosSaved

    ; set some flags
    mov eax, [termios + 4]
    and eax, 0xFFFFFFFE
    mov [termios + 4], eax
    mov eax, [termios + 12]
    and eax, 0xFFFFFFF7
    mov [termios + 12], eax

    ; exiting the program
    mov eax, 1
    xor ebx, ebx
    int 0x80