segment .data
    CalculatorText db "                                ", 10, " sqrt()   DEL     OFF      AC   ", 10, "   7      8       9        /    ", 10, "   4      5       6        *    ", 10, "   1      2       3        +    ", 10, "   ^      0       =        +    ", 10, 10, "Press [h] to see your history", 10, "Press [SUPPR] for DEL", 10, "Press [x] for OFF", 10, "Press [r] for AC", 10, "Press [s] for sqrt()", 10
    numberOfCaractersInNumberOne db 0
    numberOfCaractersInNumberTwo db 0
    BoolState db 1
    ShiftAdress db 307
    ShiftLeft db 27, '[', 'D'
    ShiftRight db 27, '[', 'C'
segment .bss
    results resb 8
    temp1 resb 32
    temp2 resb 32
    Shift resb 6
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
    ; set the cursor at the right position
    mov eax, 4
    mov ebx, 1
    mov ecx, [shiftTable + AdressWhereToWrite]
    ; print the number
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    jmp MainLoop

Exit:
    ; exiting the program
    mov eax, 1
    xor ebx, ebx
    int 0x80




ShiftCaracterToAnAdress:
    push ebp
    mov ebp, esp

    mov edi, [ebp + 8] ; this contains the length of the shift ! 

    mov eax, [ShiftAdress]
    sub eax, esi ; extracts the length of the first shift

    push eax
    call _convert_in_ASCII

    mov esi, eax
    mov [Shift], [ShiftLeft]
    mov [Shift + 3], [esi]

    ; reset the cursor postion to zero
    mov eax, 4
    mov ebx, 1
    mov ecx, Shift
    mov edx, [esi + 4]
    int 0x80

    ; shift to the correct position
    mov eax, edi

    push eax
    call _convert_in_ASCII

    mov esi, eax
    mov [Shift], [ShiftRight]
    mov [Shift + 3], [esi]

    ; print the shift
    mov eax, 4
    mov ebx, 1
    mov ecx, Shift
    mov edx, [esi + 4]
    int 0x80

    pop ebp
    ret
    



_convert_in_ASCII:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]

    mov esi, temp1
    ; this produces first an inversed number that'll have to be reversed.
loop1: 
    mov ebx, 10
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi], dl
    inc esi
    cmp eax, 0
    je code1
    jmp loop3
code2:    
    mov eax, esi
    sub eax, temp1
    mov [index], eax
    dec esi
    mov edi, esi
    mov esi, temp2
loop4:
    mov al, [edi]
    mov [esi], al
    cmp edi, temp1
    je code2
    dec edi
    inc esi
    jmp loop4 
code2:
    mov [results], temp2
    mov [results + 4], [index]
    mov eax, results
    pop ebp
    ret 


_convert_in_Binary:
    push ebp
    xor eax, eax
    xor ecx, ecx
    mov esi, [ebp + 8]
    mov edx, [ebp + 12]
loop3:
    inc ecx
    mov [esi], al
    mov ebx, al
    sub ebx, '0'
    mul eax, eax, 10
    add eax, ebx
    cmp ecx, ebx
    je return
    jmp loop3
return:
    pop ebp
    ret


    
