segment .data
    CalculatorText db "                                ", 10, " sqrt()   DEL     OFF      AC   ", 10, "   7      8       9        /    ", 10, "   4      5       6        *    ", 10, "   1      2       3        +    ", 10, "   ^      0       =        +    ", 10, 10, "Press [h] to see your history", 10, "Press [SUPPR] for DEL", 10, "Press [q] for OFF", 10, "Press [r] for AC", 10, "Press [s] for sqrt()", 10
    History db "Press [q] to Exit", 10
    numberOfCaractersInNumberOne db 0
    numberOfCaractersInNumberTwo db 0
    BoolState db 1
    ShiftAdress dd 0
    ShiftLeft db 27, '[', 'D'
    ShiftRight db 27, '[', 'C'
    Empty db '                                '
    filename db 'Operations.log', 0
    permissions equ 0644
    InHistory db 0
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
    buffer resb 1 ; all entered characters end up here
    LargeBuffer resb 34 
    LastEntriesInLogFile resb 340
    index resb 4
segment .text
    global _start
_start:
    ; create the log file
    mov eax, 5
    mov ebx, filename
    mov ecx, 0x51 ; O_CREAT (0x40) + O_WRONLY (0x1)
    mov edx, permissions
    int 0x80

    ; recover termios settings
    mov eax, 54
    mov ebx, 1
    mov ecx, 0x5401
    mov edx, termiosSaved
    int 0x80
    ; copies by byte
    mov esi, termiosSaved
    mov edi, termios
    mov ecx, 36
    rep movsb

    ; set some flags : ECHO and ICANON. 
    mov eax, [termios + 12]
    and eax, 0xFFFFFFF5
    mov [termios + 12], eax

CalculatorRestart:
    ; shift to the initial adress
    mov eax, 0
    push eax
    call ShiftCursorToAnAdress
    ; printing the calcultor general form
    mov eax, 4
    mov ebx, 1
    mov ecx, CalculatorText
    mov edx, 307
    int 0x80

MainLoop:
    ; read the user input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 1
    int 0x80

    ; parse it
    cmp [InHistory], 1
    je History
    cmp [buffer], '0'
    jb NonNumericCaracter
    cmp [buffer], '9'
    ja NonNumericCaracter
    mov [AdressWhereToWrite], 0
    cmp [BoolState], 1
    je case1
    cmp [BoolState], 2
    je case2
case1:
    mov [AdressWhereToWrite], 8
    cmp [numberOfCaractersInNumberOne], 9
    jmp MainLoop
    inc [numberOfCaractersInNumberOne]
    mov eax, [numberOfCaractersInNumberOne]
    add [AdressWhereToWrite], eax
    jmp PrintNumber
case2:
    mov [AdressWhereToWrite], 22
    cmp [numberOfCaractersInNumberTwo], 9
    jmp MainLoop
    inc [numberOfCaractersInNumberTwo]
    mov eax, [numberOfCaractersInNumberTwo]
    add [AdressWhereToWrite], eax
    jmp PrintNumber
case3:
    cmp [buffer], 'q'
    mov [InHistory], 0
    jmp AC
NonNumericCaracter:
    cmp [buffer], '*'
    mov [buffer], 'X'
    je PrintOperation
    cmp [buffer], 'X'
    je PrintOperation
    cmp [buffer], '/'
    je PrintOperation
    cmp [buffer], '+'
    je PrintOperation
    cmp [buffer], '-'
    je PrintOperation
    cmp [buffer], '^'
    je PrintOperation
    cmp [buffer], 's'
    je DoSquareRoot
    cmp [buffer], 'h'
    je SeeHistory
    cmp [buffer], '='
    je PrintResult
    cmp [buffer], 8
    je DeleteLastEnteredCaraceter
    cmp [buffer], 'q'
    je Exit
    cmp [buffer], 'r'
    je AC
PrintOperation:
    ; move to the right index
    mov eax, 22
    push eax
    call ShiftCursorToAnAdress
    ; print the operation
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    ; fill the operator variable
    mov eax, [buffer]
    mov [operator], eax
    mov [BoolState], 2
DoSquareRoot:
    cmp [BoolState], 1
    je FirstCase
    jmp SecondCase
FirstCase:
    mov eax, number1
    push eax
    call _convert_in_Binary
    push eax
    call _SquareRoot
    push eax
    call _convert_in_ASCII
    ; set cursor position 
    mov ebx, 8
    push ebx
    call ShiftCursorToAnAdress
    ; print the new number
    mov eax, 4
    mov ebx, 1
    mov ecx, [eax]
    mov edx, [eax + 4]
    int 0x80
SecondCase:
    mov eax, number2
    push eax
    call _convert_in_Binary
    push eax
    call _SquareRoot
    push eax
    call _convert_in_ASCII
    ; set cursor position 
    mov ebx, 22
    push ebx
    call ShiftCursorToAnAdress
    ; print the new number
    mov eax, 4
    mov ebx, 1
    mov ecx, [eax]
    mov edx, [eax + 4]
    int 0x80
SeeHistory:
    ; open the file
    mov eax, 5
    mov ebx, filename
    mov ecx, 0
    int 0x80
    mov esi, eax
    ; lseek
    mov eax, 19
    mov ebx, esi
    mov ecx, -64
    mov edx, 2
    int 0x80
    ; read
    mov eax, 3
    mov ebx, esi
    mov ecx, LastEntriesInLogFile
    mov edx, 340
    int 0x80
    ; close the file
    mov eax, 6
    mov ebx, esi
    int 0x80
    ; set cursor position to max
    mov ebx, 0
    push ebx
    call ShiftCursorToAnAdress
    ; write
    mov eax, 4
    mov ebx, 1
    mov ecx, LastEntriesInLogFile
    mov edx, 340
    int 0x80
    mov eax, 0
    mov ebx, 1
    mov ecx, History
    mov edx, 18
    int 0x80
    mov [InHistory], 1
PrintResult:
    ; convert first number in binary
    mov eax, number1
    mov ebx, numberOfCaractersInNumberOne
    push eax
    push ebx
    call _convert_in_Binary
    mov esi, eax
    ; convert second number in binary
    mov eax, number2
    mov ebx, numberOfCaractersInNumberTwo
    push eax
    push ebx
    call _convert_in_Binary
    mov edi, eax
    ; do the operation
    cmp [operator], '+'
    je Addition
    cmp [operator], '-'
    je Substraction
    cmp [operator], '*'
    je Multiplication
    cmp [operator], '/'
    je Division
    cmp [operator], '^'
    je Power
Addition:
    add esi, edi
    mov eax, esi
    jmp Reset
Substraction:
    sub esi, edi
    mov eax, edi
    jmp Reset
Division:
    mov eax, esi
    mov ebx, edi
    xor edx, edx
    div ebx
    jmp Reset
Multiplication:
    mov eax, esi
    mov ebx, edi
    mul ebx
    jmp Reset
Power:
    mov ebx, 0
    mov eax, esi
loop5:
    cmp ebx, edi
    jmp Reset
    inc ebx
    mul ebx
Reset:
    ; shift to the initial adress
    mov ebx, 0
    push ebx
    call ShiftCursorToAnAdress
    ; Convert in ASCII
    push eax
    call _convert_in_ASCII
    ; write in the log file
    mov ecx, [number1]
    mov [LargeBuffer], ecx
    mov ecx, [number1 + 4]
    mov [LargeBuffer + 4], ecx
    mov cl, [number1 + 8]
    mov [LargeBuffer + 8], cl
    mov [LargeBuffer + 9], ' '
    mov cl, [operator]
    mov [LargeBuffer + 10], cl
    mov [LargeBuffer + 11], ' '
    mov ecx, [number2]
    mov [LargeBuffer + 12], ecx
    mov ecx, [number2 + 4]
    mov [LargeBuffer + 16], ecx
    mov cl, [number1 + 8]
    mov [LargeBuffer + 17], cl
    mov [LargeBuffer + 21], ' '
    mov [LargeBuffer + 22], '='
    mov [LargeBuffer + 23], ' '
    mov ecx, [eax]
    mov [LargeBuffer + 24], eax
    mov ecx, [eax + 4]
    mov [LargeBuffer + 28], ecx
    mov cl, [eax + 8]
    mov [LargeBuffer + 32], cl 
    mov [LargeBuffer + 33], 10
    mov eax, 4
    mov ebx, filename
    mov ecx, LargeBuffer
    mov edx, 34
    int 0x80
    ; reset the high bar
    mov eax, 4
    mov ebx, 1
    mov ecx, Empty
    mov edx, 32
    int 0x80
    ; shift to the correct adress
    mov ebx, 15
    push ebx
    call ShiftCursorToAnAdress
    ; print the result
    mov [LargeBuffer], '='
    mov [LargeBuffer + 1], ' '
    mov ecx, [esi]
    mov [LargeBuffer + 2], ecx
    mov ecx, [esi + 4]
    mov [LargeBuffer + 6], ecx
    mov cl, [esi + 8]
    mov [LargeBuffer + 10], cl
    mov eax, 4
    mov ebx, 1
    mov ecx, LargeBuffer
    mov edx, 11
    int 0x80

    jmp AC
AC:
    mov [numberOfCaractersInNumberOne], 0
    mov [numberOfCaractersInNumberTwo], 0
    mov [number1], 0
    mov [number1 + 4], 0
    mov [number1 + 8], 0
    mov [number2], 0
    mov [number2 + 4], 0
    mov [number2 + 8], 0
    mov [operator], 0
    jmp CalculatorRestart

DeleteLastEnteredCaraceter:
    cmp [BoolState], 1
    je DeleteCaracterOfNumberOne
    jmp DeleteCaracterOfNumberTwo
DeleteCaracterOfNumberOne:
    dec [numberOfCaractersInNumberOne]
    mov edi, [numberOfCaractersInNumberOne]
    mov esi, [number1 + edi]
    mov esi, ' '
    ; change the cursor position
    mov eax, 9
    push eax
    call ShiftCursorToAnAdress
    ; write number 1
    mov eax, 4
    mov ebx, 1
    mov ecx, number1
    mov edx, 9
    int 0x80

    jmp MainLoop
DeleteCaracterOfNumberTwo:
    dec [numberOfCaractersInNumberTwo]
    mov edi, [numberOfCaractersInNumberTwo]
    mov esi, [number2 + edi]
    mov esi, ' '
    ; change the cursor position
    mov eax, 22
    push eax
    call ShiftCursorToAnAdress
    ; write number 1
    mov eax, 4
    mov ebx, 1
    mov ecx, number1
    mov edx, 9
    int 0x80

    jmp MainLoop
PrintNumber:
    ; set the cursor at the right position
    mov eax, AdressWhereToWrite
    push eax
    call ShiftCursorToAnAdress
    ; print the number
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    jmp MainLoop

Exit:
    ; restauring termios
    mov eax, 54
    mov ebx, 0
    mov ecx, 0x5402
    mov edx, termiosSaved
    int 0x80
    ; exiting the program
    mov eax, 1
    xor ebx, ebx
    int 0x80




ShiftCursorToAnAdress:
    push ebp
    mov ebp, esp

    mov edi, [ebp + 8] ; this contains the length of the shift ! 

    mov eax, [ShiftAdress]
    sub eax, esi ; extracts the length of the first shift

    push eax
    call _convert_in_ASCII

    mov esi, [eax]
    mov eax, [ShiftLeft]
    mov [Shift], eax
    mov [Shift + 3], esi

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
    mov eax,  [ShiftRight]
    mov [Shift], eax
    mov eax, [esi]
    mov [Shift + 3], eax

    ; print the shift
    mov eax, 4
    mov ebx, 1
    mov ecx, Shift
    mov edx, [esi + 4]
    int 0x80

    mov esp, ebp
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
    je code5
    jmp loop1
code5:    
    mov eax, esi
    sub eax, temp1
    mov [index], eax
    dec esi
    mov edi, esi
    mov esi, temp2
loop2:
    mov al, [edi]
    mov [esi], al
    cmp edi, temp1
    je code6
    dec edi
    inc esi
    jmp loop2
code6:
    mov ebx, temp2
    mov [results], ebx
    mov ebx, [index]
    mov [results + 4], ebx
    mov eax, results
    mov esp, ebp
    pop ebp
    ret 


_convert_in_Binary:
    push ebp
    mov esi, [ebp + 8]
    mov edx, [ebp + 12]
    xor edi, edi
    xor eax, eax
loop3:
    inc edi
    inc [edx]
    sub [edx], '0'
    mov ebx, 10
    mul ebx
    add eax, [edx]
    cmp [esi], edi
    je return
    jmp loop3
return:
    mov esp, ebp
    pop ebp
    ret


    
_SquareRoot:
    push ebp 
    mov esi, [ebp + 8]
    
    mov eax, esi
    mov ebx, 2
    div ebx

    ; here's the loop to calculate the sqrt() -> we follow this equation : ((X_original / X_actuel) + X_actuel) / 2 until the results are roughly the same every time.
newtonLoop:
    cmp edi, eax
    je quit
    inc edi
    cmp edi, eax
    je quit
    mov edi, eax
    mov eax, [esi]
    mov ebx, edi
    xor edx, edx
    div ebx
    add eax, edi
    mov ebx, 2
    xor ecx, ecx
quit:
    mov esp, ebp
    pop ebp 
    ret