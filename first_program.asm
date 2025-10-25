
segment .data  ; contains initialized data
    input db "Entre a number : ", 0
    output db "you entered : ", 0
    newLine db 10,0
segment .bss ; contains unitialized data
    buffer resb 32
segment .text
    global _start
_start:
    
    ; afficher le texte
    mov eax, 4
    mov ebx, 1
    mov ecx, input
    mov edx, 18
    int 0x80 ; le "int 0x80" est une interruption kernel. le process change de mode pour passer au mode kernel, execute un service, puis revient !!

    ; lire l'entree utilisateur
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 32
    int 0x80
    mov esi, eax            ; nombre de caracteres lus.

    ; sauter ligne
    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, 1
    int 0x80 ;

    ; afficher le output
    mov eax, 4
    mov ebx, 1
    mov ecx, output
    mov edx, 14
    int 0x80 ;

    ; afficher le output
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, esi
    int 0x80 

    ; sauter ligne
    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, 1
    int 0x80 ;

    ; quitter proprement
    mov eax, 1
    xor ebx, 0
    int 0x80



