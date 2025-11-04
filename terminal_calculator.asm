segment .data
    CalculatorText db "                                ", 10, " sqrt()   DEL     OFF      AC   ", 10, "   7      8       9        /    ", 10, "   4      5       6        *    ", 10, "   1      2       3        +    ", 10, "   ^      0       =        +    ", 10, 10, "Press [h] to see your history", 10, "Press [SUPPR] for DEL", 10, "Press [x] for OFF", 10, "Press [r] for AC", 10, "Press [s] for sqrt()", 10
    ; that's executed in compilation time !
    shiftTable:
        %assign i, 1
        %rep 307
            db 27, '[', '0'+i, 'C'
            %assign i i+1
        %endrep
    numberOfCaractersInNumberOne db 0
    numberOfCaractersInNumberTwo db 0
    BoolState db 1
segment .bss
    AdressWhereToWrite resb 4
    number1 resb 9
    number2 resb 9
    operator resb 1
    FirstNumberOperator resb 1
    SecondNumberOperator resb 1
    termiosSaved resb 36 ; contains all termios settings
    termios resb 36
    buffer resb 0 ; all entered characters end up here 
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

    ; set some flags : ECHO and ICANON. 
    mov eax, [termios + 12]
    and eax, 0xFFFFFFF5
    mov [termios + 12], eax

MainLoop:
    ; read the user input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1
    int 0x80

    ; parse it
    cmp buffer, '0'
    jb NonNumericCaraceter
    cmp buffer, '10'
    ja NonNumericCaraceter
    xor AdressWhereToWrite, AdressWhereToWrite
    cmp BoolState, 1
    je case1
    cmp BoolState, 2
    je case2
case1:
    add AdressWhereToWrite, 8
    add AdressWhereToWrite, numberOfCaractersInNumberOne
    mov esi, number1
    mov edi, numberOfCaractersInNumberOne
    mov [esi + edi], [buffer]
    jmp PrintNumber
case2:
    add AdressWhereToWrite, 22
    add AdressWhereToWrite, numberOfCaractersInNumberTwo
    mov esi, number2
    mov edi, numberOfCaractersInNumberTwo
    mov [esi + edi], [buffer]
    jmp PrintNumber
NonNumericCaraceter:
PrintNumber:
    ; print it
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, AdressWhereToWrite
    int 0x80
    jmp MainLoop

Exit:
    ; exiting the program
    mov eax, 1
    xor ebx, ebx
    int 0x80