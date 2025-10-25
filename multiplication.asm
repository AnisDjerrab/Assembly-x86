segment .data   
    input1 db "Enter the first number : "
    input2 db "Enter the second number : "
    output1 db "here's the addition result : "
    output2 db "here's the soustraction result : "
    output3 db "here's the multiplication result : "
    output4 db "here's the division result : "
    newLine db  10
segment .bss
    temp1 resb 32
    temp2 resb 32
    buffer1 resb 32 ; ici 32 oects reserves
    buffer2 resb 32
    Integer1 resb 4 ; et ici 32 bits. c'est le strict necessaire.
    Integer2 resb 4
    index resb 4
segment .text
    global _start
_start: 

    ; print input1
    mov eax, 4
    mov ebx, 1
    mov ecx, input1
    mov edx, 25
    int 0x80

    ; get value 1
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer1
    mov edx, 32
    int 0x80

    ; print input2
    mov eax, 4
    mov ebx, 1
    mov ecx, input2
    mov edx, 26
    int 0x80

    ; get value 2
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer2
    mov edx, 32
    int 0x80

    mov esi, buffer1
    xor eax, eax
    xor ebx, ebx

loop1:
    mov bl,[esi]
    cmp bl, 10 ; voir si bl est \n
    je temp
    sub bl, '0' ; les chiffres dans l'ASCII commencent de 0 a 9 -- en soustrayant le 0, on s'assure que le 0x00 = '0'
    imul eax, eax, 10
    movzx ebx, bl ; efface le sbits superieurs
    add eax, ebx
    inc esi
    jmp loop1
temp:
    mov [Integer1], eax ; reellement implementer Integer 1
    mov esi, buffer2
    xor eax, eax
    xor ebx, ebx
loop2:
    mov bl,[esi]
    cmp bl, 10
    je program
    sub bl, '0' 
    imul eax, eax, 10
    movzx ebx, bl
    add eax, ebx
    inc esi
    jmp loop2
program:
    mov [Integer2], eax
    ; add and print result
    mov eax, 4
    mov ebx, 1
    mov ecx, output1
    mov edx, 29
    int 0x80
    mov ecx,[Integer1]
    add ecx,[Integer2]
    push ecx
    call _convert_in_ASCII
    add esp, 4

    ; soustact and print result
    mov eax, 4
    mov ebx, 1
    mov ecx, output2
    mov edx, 33
    int 0x80
    mov ecx,[Integer1]
    sub ecx,[Integer2]
    push ecx
    call _convert_in_ASCII
    add esp, 4

    ; multiply and print result 
    mov eax, 4
    mov ebx, 1
    mov ecx, output3
    mov edx, 35
    int 0x80
    mov ecx, [Integer1]
    imul ecx, [Integer2]
    push ecx
    call _convert_in_ASCII
    add esp, 4

    ; divide and print result 
    mov eax, 4
    mov ebx, 1
    mov ecx, output4
    mov edx, 29
    int 0x80
    mov eax, [Integer1]
    cdq  ; etend le signe dans ebx
    idiv dword [Integer2]
    push eax
    call _convert_in_ASCII
    add esp, 4

    mov eax, 1
    xor ebx, 0
    int 0x80


_convert_in_ASCII:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]

    mov esi, temp1
    mov edx, 0
    ; this produces first an inversed number that'll have to be reversed.
loop3: 
    mov ebx, 10
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi], dl
    inc esi
    cmp eax, 0
    je code1
    jmp loop3
code1:    
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
    mov eax, 4
    mov ebx, 1
    mov ecx, temp2 
    mov edx, [index]
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newLine 
    mov edx, 1
    int 0x80

    pop ebp
    ret 
