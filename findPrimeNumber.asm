segment .data
    input1 db "Entrez un nombre : "
    input2 db "Voulez vous entrer un autre nombre ? "
    input3 db "Vous ne pouvez entrer que y ou n (oui ou non). Alors ? "
    output1 db "Le nombre : "
    output2 db " est un nombre premier"
    output3 db " n'est pas un nombre premier"  
    output4 db "nombre invalide."
    newLine db 10
segment .bss
    number resb 32 
    answer resb 32 
    convertedNumber resb 32
    temp resb 32
    temp2 resb 32
    index resb 4
segment .text
    global _start
_start:
main_loop:
    ; print prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, input1
    mov edx, 19
    int 0x80
    ; read user input in number
after1:
    mov eax, 3
    mov ebx, 0
    mov ecx, number
    mov edx, 32
    int 0x80

    mov esi, number
    ; check if number contains only numbers
checkLoop:
    mov al, [esi]
    cmp al, 10
    je program1
    cmp al, '0'
    jb error
    cmp al, '9'
    ja error
after2:
    inc esi
    jmp checkLoop
error:
    mov eax, 4
    mov ebx, 1
    mov ecx, output4
    mov edx, 16
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, 1
    int 0x80
    jmp userFeedback
program1:
    ; convert it into binary format
    mov esi, number
    xor eax, eax
    xor ebx, ebx
loop3:
    mov bl,[esi]
    cmp bl, 10 
    je program2
    sub bl, '0' 
    imul eax, eax, 10
    movzx ebx, bl
    add eax, ebx
    inc esi
    jmp loop3
program2:
    ; voir si c'est un nombre premier
    mov [convertedNumber], eax
    cmp eax, 2
    je Premier
    cmp eax, 0
    je PasPremier
    cmp eax, 1
    je PasPremier
    mov ebx, 2
    mov edx, 0
    div ebx
    cmp edx, 0
    je PasPremier

    mov edi, convertedNumber
    xor esi, esi
    ; ici, on va calculer sqrt de maniere custom. here, the loop is called Newton loop becuse Newton gave us the equation used here.
newtonLoop:
    cmp esi, eax    
    je confirmation
    dec esi
    cmp esi, eax
    je confirmation
    mov esi, eax
    mov eax, [edi]
    mov ebx, esi
    xor edx, edx
    div ebx
    add eax, esi
    mov ebx, 2
    xor edx, edx
    div ebx
    jmp newtonLoop
confirmation:
    ; voila la boucle pour voir si c'est un nombre premier
    mov ebx, 3
    mov esi, eax
FinalLoop:
    ; on voit si le nombre accepte la division sur le moindre des nombres < sqrt(convertedNumber)
    cmp eax, esi
    je Premier 
    ja Premier
    mov eax, [edi]
    xor edx, edx
    div ebx
    cmp edx, 0
    je PasPremier
    add ebx, 2
    jmp FinalLoop
Premier:
    ; affiche le message
    mov eax, 4
    mov ebx, 1
    mov ecx, output1
    mov edx, 12
    int 0x80

    ; convertir le nombre
    mov eax, [convertedNumber]
    push eax
    call _convert_in_ASCII
    add esp, 4

    ; afficher le texte  apres le caractere
    mov eax, 4
    mov ebx, 1
    mov ecx, output2
    mov edx, 22
    int 0x80

    ; retour a la ligne
    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, 1
    int 0x80
    jmp userFeedback
PasPremier:
    ; affiche le message
    mov eax, 4
    mov ebx, 1
    mov ecx, output1
    mov edx, 12
    int 0x80

    ; convertir le nombre
    mov eax, [convertedNumber]
    push eax
    call _convert_in_ASCII
    add esp, 4

    ; afficher le texte  apres le caractere
    mov eax, 4
    mov ebx, 1
    mov ecx, output3
    mov edx, 28
    int 0x80

    ; retour a la ligne
    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, 1
    int 0x80
userFeedback:
    ; affiche le prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, input2
    mov edx, 37
    int 0x80

    ; accueillir reponse de l'utilisateur 
    mov eax, 3
    mov ebx, 1
    mov ecx, answer
    mov edx, 32
    int 0x80

    ; verifier que c'est OK 
    mov esi, answer
    mov al, [esi]
    cmp al, 'y'
    je Yes
    cmp al, 'n'
    je No
    jmp TypingError
Yes:
    inc esi
    mov al, [esi]
    cmp al, 10
    jmp main_loop
    jmp TypingError
No:
    inc esi
    mov al, [esi]
    cmp al, 10
    jmp Exit
    jmp TypingError
TypingError:
    ; afficher le message d'erreur
    mov eax, 4
    mov ebx, 1
    mov ecx, input3
    mov edx, 55
    int 0x80

    ; user input
    mov eax, 3
    mov ebx, 0
    mov ecx, answer
    mov edx, 32
    int 0x80

    ; verifier que c'est OK 
    mov esi, answer
    mov al, [esi]
    cmp al, 'y'
    je Yes
    cmp al, 'n'
    je No
    jmp TypingError
Exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

_convert_in_ASCII:
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]

    mov esi, temp
    mov edx, 0
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
    jmp loop1
code1:    
    mov eax, esi
    sub eax, temp
    mov [index], eax
    dec esi
    mov edi, esi
    mov esi, temp2
loop2:
    mov al, [edi]
    mov [esi], al
    cmp edi, temp
    je code2
    dec edi
    inc esi
    jmp loop2
code2:
    mov eax, 4
    mov ebx, 1
    mov ecx, temp2
    mov edx, [index]
    int 0x80

    pop ebp
    ret 
