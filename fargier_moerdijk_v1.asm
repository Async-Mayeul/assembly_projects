;----------------------------------------------------------------------------
; Auteur : Fargier Mayeul, Moerdijk Jean-Leonard 
;
; Objectif du programme :Ce programme en langage d'assemblage permet de récupérer 
; une chaîne de caractère entre 18 et 21 caractères saisie par l'utilisateur.
; 
; Entree : Une chaine de caractere.
; Sortie : Erreur si la chaîne contient un caractere special ou n'est pas comprise entre 18 et 21 caracteres.
;
; Architecture :
;   section .data
;     --> La section .data contient les différents message à afficher.
;     --> Elle contient aussi des constantes pour faciliter la lecture du programme.
;   section .bss
;     --> La section .bss contient le buffer pour la chaîne de caractere.
;   section .text
;     --> La section .text contient la fonction principale _start qui s'occupe simplement d'appeler les fonctions pour afficher
;     et récuperer la chaîne.

%include 'asm_io.inc' ; Librairie externe utilisée pour afficher des messages
%define taille_max_chaine 200 ; taille maximum pouvant être entrée par l'utilisateur

section .data
  message db 'Entrez une chaine de 18 caracteres minimum et 21 caracteres maximum avec uniquement des lettres : ', 0 ; message pour la saisie de l'entrée
  chaine_trop_courte db 'Votre entree est trop courte, elle doit contenir minimum 18 caracteres.', 0 ; message d'erreur si la chaîne entrée est trop courte
  chaine_trop_longue db 'Votre entree est trop longue, elle doit contenir maximum 21 caracteres.', 0 ; message d'erreur si la chaîne entrée est trop longue
  chaine_non_conforme db 'Votre entree doit contenir uniquement des lettres.', 0 ; message d'erreur si la chaîne entrée ne contient pas que des lettres

  ;Constantes pour faciliter la lecture du programme :
  STDIN equ 0
  STDOUT equ 1
  WRITE_CALL equ 4
  READ_CALL equ 3
  EXIT_CALL equ 1
  SYS_CALL equ 0x80

section .bss
  entree_buffer: resd taille_max_chaine

section .text
  global _start

  ; Bloc d'instructions de la fonction principale _start
  ; La fonction _start permet d'afficher le message pour demander une entrée utilisateur.
  ; Elle appelle ensuite la fonction _readString qui récupere et verifie si la chaîne entrée contient uniquement des lettres et si elle est comprise
  ; entre 18 et 21 caracteres.
  _start:
    mov eax, message ; Appel de la fonction _display pour afficher les messages
    call _display ; eax contient la chaîne qui va être utilisé par print_string

    push entree_buffer ; On passe entree_buffer comme argument de la fonction _read_string 
    call _read_string

    cmp eax, 0 ; _read_string renvoie 0 dans le registre eax en cas de réussite sinon elle renvoie 1
    jne exit_start

    mov eax, entree_buffer
    call _display
    
    ; Bloc d'instructions pour sortir du programme
    exit_start:
      mov eax, EXIT_CALL
      mov ebx, 0
      int SYS_CALL

  _display:
    push ebp
    mov ebp, esp

    call print_string ; Fonction importé de la librairie asm_io, elle affiche le string donné en argument
    call print_nl ; Fonction importé de la librairie asm_io, elle affiche un retour à la ligne

    mov esp, ebp
    pop ebp

    ret

  _read_string:
    push ebp
    mov ebp, esp

    mov eax, READ_CALL
    mov ebx, STDIN
    mov ecx, [ebp+8]
    mov edx, taille_max_chaine
    int SYS_CALL

    cmp eax, 22 ; Vérifie si la chaîne comporte plus de 21 caracteres
    jg error_too_long 
    cmp eax, 18 ; Vérifie si la chaîne n'est pas inferieur à 18 caracteres
    jb error_too_short

    mov eax, 0 ; Si _read_string réussit elle renvoie 0
    mov ecx, 0
    mov esi, [ebp+8] ; Charge la chaîne dans entree_buffer dans le registre esi

    ; Boucle qui itère sur la chaîne de caracteres
    ; Elle s'arrete quand elle rencontre le caracteres de retour à la ligne
    ; La boucle vérifie si chaque caractere est bien une lettre à l'aide de la fonction _check_special_char
    loop_check: 
      mov dl, [esi]
      cmp dl, 10
      je exit_read_string

      push ecx
      call _check_special_char
      pop ecx

      cmp eax, 0
      jne exit_read_string

      inc esi
      inc ecx

      jmp loop_check

    ; Affichage des messages d'erreur si la chaîne n'est pas comprise entre
    ; 18 et 21 caracteres
    error_too_short:
      mov eax, chaine_trop_courte
      call _display
      mov eax, 1 ; _readString renvoie 1 en cas d'erreur
      jmp exit_read_string

    error_too_long:
      mov eax, chaine_trop_longue
      call _display
      mov eax, 1
      jmp exit_read_string

    exit_read_string:
      mov esp, ebp
      pop ebp

      ret

  _check_special_char:
    push ebp
    mov ebp, esp
    mov eax, 0

    cmp dl, 0x41 ; 41 représente un A en ASCII
    jl error_special_char ; Si le caractere entree est inférieur à 41 ce n'est pas une lettre
    cmp dl, 0x5a ; 0x5a représente Z en ASCII
    jg check_min_maj ; jump pour vérifier si le caractere est dans les miniscules
    jmp continue

    check_min_maj:
      cmp dl, 0x61 ; 61 représente a en ASCII
      jl error_special_char ; Si le caractere est ni dans les majuscules ni dans les miniscules alors ce n'est pas une lettre
      jmp continue

    error_special_char:
      mov eax, chaine_non_conforme
      call _display
      mov eax, 1 ; _check_special_char renvoie 1 dans le registe eax en cas d'erreur
      jmp exit_check_char

    continue:
      cmp dl, 0x7a ; 0x7a est z en ASCII
      jg error_special_char ; si le caractere a une valeur hexadecimal supérieur à z en ASCII ce n'est pas une lettre
      jmp exit_check_char

    exit_check_char:
      mov esp, ebp
      pop ebp

      ret
