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
  ;mot_de_passe db 'ecilaollehbobruojnob', 0
  ;taille_mdp equ $-mot_de_passe
  msg_bon_pwd db 'Mot de passe valide.', 0
  msg_mauvais_pwd db 'Mauvais mot de passe.', 0
  to_many_try db 'Trop de tentatives.', 0
  erreur_lecture_fichier db 'Erreur lecture du fichier mot de passe.', 0
  filename db 'password.txt', 0
  message db 'Entrez une chaine de 18 caracteres minimum et 21 caracteres maximum avec uniquement des lettres : ', 0 ; message pour la saisie de l'entrée
  chaine_trop_courte db 'Votre entree est trop courte, elle doit contenir minimum 18 caracteres.', 0 ; message d'erreur si la chaîne entrée est trop courte
  chaine_trop_longue db 'Votre entree est trop longue, elle doit contenir maximum 21 caracteres.', 0 ; message d'erreur si la chaîne entrée est trop longue
  chaine_non_conforme db 'Votre entree doit contenir uniquement des lettres.', 0 ; message d'erreur si la chaîne entrée ne contient pas que des lettres

  ;Constantes pour faciliter la lecture du programme :
  OPEN_CALL equ 5 
  CLOSE_CALL equ 6
  STDIN equ 0
  STDOUT equ 1
  WRITE_CALL equ 4
  READ_CALL equ 3
  EXIT_CALL equ 1
  SYS_CALL equ 0x80

section .bss
  mot_de_passe: resd taille_max_chaine
  entree_buffer: resd taille_max_chaine

section .text
  global _start

  ; Bloc d'instructions de la fonction principale _start
  ; La fonction _start permet d'afficher le message pour demander une entrée utilisateur.
  ; Elle appelle ensuite la fonction _readString qui récupere et verifie si la chaîne entrée contient uniquement des lettres et si elle est comprise
  ; entre 18 et 21 caracteres.
  _start:
    call _read_file
    cmp eax, 0
    jne exit_start

    mov eax, message ; Appel de la fonction _display pour afficher les messages
    call _display ; eax contient la chaîne qui va être utilisé par print_string

    mov eax, entree_buffer
    call _read_string

    cmp eax, 0 ; _readString renvoie 0 dans le registre eax en cas de réussite sinon elle renvoie 1
    jne exit_start
    
    mov eax, entree_buffer
    call _invert_string
    mov eax, entree_buffer
    mov edx, mot_de_passe
    call _check_password
    
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

  _check_special_char:
    push ebp
    mov ebp, esp

    mov eax, 0

    cmp dl, 0x41 ; 41 représente un A en ASCII
    jb error_special_char ; Si le caractere entree est inférieur à 41 ce n'est pas une lettre
    cmp dl, 0x5a ; 0x5a représente Z en ASCII
    ja check_min_maj ; jump pour vérifier si le caractere est dans les miniscules
    jmp continue

    check_min_maj:
      cmp dl, 0x61 ; 61 représente a en ASCII
      jb error_special_char ; Si le caractere est ni dans les majuscules ni dans les miniscules alors ce n'est pas une lettre
      jmp continue

    error_special_char:
      mov eax, chaine_non_conforme
      call _display
      mov eax, 1 ; _check_special_char renvoie 1 dans le registe eax en cas d'erreur
      jmp exit_check_spe_char

    continue:
      cmp dl, 0x7a ; 0x7a est z en ASCII
      ja error_special_char ; si le caractere a une valeur hexadecimal supérieur à z en ASCII ce n'est pas une lettre
      jmp exit_check_spe_char

    exit_check_spe_char:
      mov esp, ebp
      pop ebp

      ret

  _read_string:
    push ebp
    mov ebp, esp

    mov esi, eax

    mov eax, READ_CALL
    mov ebx, STDIN
    mov ecx, esi
    mov edx, taille_max_chaine
    int SYS_CALL

    cmp eax, 22 ; Vérifie si la chaîne comporte plus de 21 caracteres
    jg error_too_long 
    cmp eax, 18 ; Vérifie si la chaîne n'est pas inferieur à 18 caracteres
    jb error_too_short

    dec eax
    mov BYTE [esi + eax], 0

    mov eax, 0 ; Si _readString réussit elle renvoie 0
    mov ecx, 0

    lea esi, [esi] ; Charge la chaîne dans entree_buffer dans le registre esi

    ; Boucle qui itère sur la chaîne de caracteres
    ; Elle s'arrete quand elle rencontre le caracteres de retour à la ligne
    ; La boucle vérifie si chaque caractere est bien une lettre à l'aide de la fonction _check_special_char
    loop_check: 
      mov dl, [esi]
      cmp dl, 0
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

  _check_password:
    push ebp
    mov ebp, esp

    mov ecx, 4
    loop_check_pwd:
      push ecx
      push edx
      push eax
      call _check_equal
      cmp eax, 0
      je right_pwd
      pop eax
      push eax
      call _read_string
      pop eax
      call _invert_string
      ;pop esi
      ;pop edi
      pop edx
      pop ecx

      loop loop_check_pwd

    mov eax, to_many_try
    call _display
    jmp exit_check_pwd 
    
    right_pwd:
      mov eax, msg_bon_pwd
      call _display
      jmp exit_check_pwd

    exit_check_pwd:
      mov esp, ebp
      pop ebp

      ret

  _check_equal:
    push ebp
    mov ebp, esp

    lea esi, [eax]
    lea edi, [edx]

    loop:
      mov dl, [esi]
      mov bl, [edi]

      inc esi
      inc edi

      cmp dl, bl
      jne char_not_equal

      cmp bl, 0
      jne loop

    mov eax, 0
    jmp exit_check_equal

    char_not_equal:
      mov eax, msg_mauvais_pwd
      call _display
      mov eax, 1
      jmp exit_check_equal

    exit_check_equal:
      mov esp, ebp
      pop ebp

      ret

  _invert_string:
    push ebp
    mov ebp, esp

    call _size_of_string
    
    dec ecx
    mov edi, 0
    mov dl, BYTE [eax + ecx]
    mov bl, BYTE [eax + edi]
    mov BYTE [eax + edi], dl
    mov BYTE [eax + ecx], bl

    loop_invert:
      inc edi
      dec ecx
      cmp edi, ecx
      je exit_invert_string
      cmp ecx, edi
      jb exit_invert_string
      mov dl, BYTE [eax + ecx]
      mov bl, BYTE [eax + edi]
      mov BYTE [eax + edi], dl
      mov BYTE [eax + ecx], bl
      jmp loop_invert

    exit_invert_string:
      mov esp, ebp
      pop ebp

      ret

  _size_of_string:
    push ebp
    mov ebp, esp
    
    lea esi, [eax]
    mov ecx, 0

    loop_size:
      mov dl, [esi]
      inc esi
      inc ecx
      cmp dl, 0
      jne loop_size
    
    dec ecx

    mov esp, ebp
    pop ebp

    ret

  _read_file:
    push ebp
    mov ebp, esp

    mov ebx, filename
    mov eax, OPEN_CALL
    mov ecx, 0 ; read only
    int SYS_CALL

    cmp ecx, 0
    jl error_read_file

    push eax

    mov ebx, eax
    mov eax, READ_CALL 
    mov ecx, mot_de_passe
    mov edx, taille_max_chaine
    int SYS_CALL

    dec eax
    mov BYTE [mot_de_passe + eax], 0

    cmp ecx, 0
    jl error_read_file

    pop eax

    mov ebx, eax
    mov eax, CLOSE_CALL
    int SYS_CALL

    mov eax, 0
    jmp exit_read_file

    error_read_file:
      mov eax, erreur_lecture_fichier
      call _display
      mov eax, 1
      jmp exit_read_file
     
    exit_read_file: 
      mov esp, ebp
      pop ebp

      ret
