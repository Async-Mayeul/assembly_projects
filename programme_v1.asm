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
;   Fonctions :
;     --> _start fonction principale.
;     --> _read_string, fonction qui s'occupe de lire sur l'entrée standard pour récuperer la chaîne de caractere saisie.
;     --> _display, fonction qui s'occupe de l'affichage.
;     --> _check_special_char, fonction qui s'occupe de vérifier si la chaîne contient uniquement des lettres.

%include 'asm_io.inc' ; Librairie externe utilisée pour importer les fonctions print_nl et print_string
%define taille_max_chaine 200 ; taille maximum de la chaîne pouvant être entrée par l'utilisateur.

section .data
  message db 'Entrez une chaine de 18 caracteres minimum et 21 caracteres maximum avec uniquement des lettres : ', 0 ; message pour la saisie de l'entrée
  chaine_trop_courte db 'Votre entree est trop courte, elle doit contenir minimum 18 caracteres.', 0 ; message d'erreur si la chaîne entrée est trop courte
  chaine_trop_longue db 'Votre entree est trop longue, elle doit contenir maximum 21 caracteres.', 0 ; message d'erreur si la chaîne entrée est trop longue
  chaine_non_conforme db 'Votre entree doit contenir uniquement des lettres.', 0 ; message d'erreur si la chaîne entrée ne contient pas que des lettres

  ; Constantes pour faciliter la lecture du programme :
  STDIN equ 0 ; 0 représente l'entrée standard
  STDOUT equ 1 ; 1 représente la sortie standard
  WRITE_CALL equ 4 ; 4 est le numéro dans la table des appels systèmes pour l'appel système write(), qui permet d'écrire sur le flux spécifié
  READ_CALL equ 3 ; 3 est le numéro dans la table des appels systèmes pour l'appel système read(), qui permet de lire sur le flux spécifié.
  EXIT_CALL equ 1 ; 1 est le numéro dans la table des appels systèmes pour l'appel système exit(), qui permet de terminer un programme.
  SYS_CALL equ 0x80 ; entier pour réaliser une interruption afin de réaliser un appel système et pouvoir passer dans le kernel-mode.

section .bss
  entree_buffer: resd taille_max_chaine ; allocation d'un espace mémoire afin de stocker la saisie de l'utilisateur

section .text
  global _start

  ; Bloc d'instructions de la fonction principale _start
  ; La fonction _start fait appelle à plusieurs fonctions. Pour afficher le message demandant une saisie de l'utilisateur elle appelle la fonction _display.
  ; Elle appelle ensuite la fonction _read_string qui récupere et verifie si la chaîne entrée contient uniquement des lettres et si elle est comprise
  ; entre 18 et 21 caracteres.
  ; Ensuite elle quitte le programme. Renvoie 0 si tout c'est bien passé.
  _start:
    mov eax, message ; passage de la variable message au registre eax qui est passé en argument à la fonction _display
    call _display ; appel de la fonction _display pour afficher la chaîne contenue dans message

    push entree_buffer ; On passe entree_buffer comme argument de la fonction _read_string par la pile 
    call _read_string ; appel de la fonction _read_string

    cmp eax, 0 ; _read_string renvoie 0 dans le registre eax en cas de réussite sinon elle renvoie 1
    jne exit_start ; Si _read_string renvoie 1 alors on sort du programme

    mov eax, entree_buffer ; passage en argument de la chaîne nouvellement saisie à la fonction _display
    call _display ; appel de la fonction _display pour afficher la chaîne saisie
    
    ; Bloc d'instructions pour sortir du programme
    exit_start:
      mov eax, EXIT_CALL
      mov ebx, 0
      int SYS_CALL


  ; Nom de la fonction : _display
  ; Argument(s) : eax --> contenant la chaîne à afficher 
  ; Rôle : La fonction _display affiche les chaînes passées en argument sur la sortie standard à l'aide des fonctions
  ; importées de la Librairie asm_io print_string et print_nl.
  ; Retour : N/A
  _display:
    ; Prologue de la fonction _display
    push ebp
    mov ebp, esp

    call print_string ; Fonction importé de la librairie asm_io, elle affiche le string donné en argument
    call print_nl ; Fonction importé de la librairie asm_io, elle affiche un retour à la ligne

    ; Epilogue de la fonction _display
    mov esp, ebp
    pop ebp

    ret

  ; Nom de la fonction : _read_string
  ; Argument(s) : entree_buffer --> passé par la pile, buffer pour récuperer la saisie de l'utilisateur
  ; Rôle : La fonction _read_string lit sur l'entrée standard la saisie de l'utilisateur. Elle stocke cette saisie dans le buffer
  ; entree_buffer. Ce buffer est ensuite vérifié par l'appel à la fonction _check_special_char, afin de vérifier si la chaîne contient seulement
  ; des lettres. _read_string vérifie aussi la taille de la chaîne à l'aide du registre eax qui contient la taille de la saisie après l'appel système READ.
  ; Retour : eax --> 0 ou 1. 0 si la fonction réussit, 1 si elle faillit.
  _read_string:
    push ebp
    mov ebp, esp

  ; Appel système READ
  ;-------------------------------
    mov eax, READ_CALL
    mov ebx, STDIN
    mov ecx, [ebp+8]
    mov edx, taille_max_chaine
    int SYS_CALL
  ;-------------------------------

    cmp eax, 22 ; Vérifie si la chaîne comporte plus de 21 caracteres plus le caractere de retour à la ligne.
    jg error_too_long 
    cmp eax, 18 ; Vérifie si la chaîne n'est pas inferieur à 18 caracteres
    jb error_too_short

    mov eax, 0 ; Si _read_string réussit elle renvoie 0
    mov esi, [ebp+8] ; l'adresse d'entree_buffer se trouve dans la pile à +8 octets de ebp, on la copie dans esi

    ; Boucle qui itère sur la chaîne de caracteres
    ; Elle s'arrete quand elle rencontre le caracteres de retour à la ligne
    ; La boucle vérifie si chaque caractere est bien une lettre à l'aide de la fonction _check_special_char
    loop_check: 
      mov dl, [esi] ; copie d'un caractere du buffer entree_buffer dans le sous-registre 8-bit de edx.
      cmp dl, 10 ; On compare ce caractere au caractere de retour à la ligne
      je exit_read_string ; Si le caractere est un \n alors on quitte la boucle

      call _check_special_char ; Appel de la fonction _check_special_char pour vérifier si le caractere dans le registre dl
      ; est un caracteres autre qu'une lettre

      cmp eax, 0 ; Si _check_special_char renvoie 0 alors le registre dl contient une lettre sinon on sort de la fonction et du programme
      jne exit_read_string

      inc esi ; on se déplace d'un octet dans entree_buffer pour obtenir le caractere suivant

      jmp loop_check

    ; Affichage des messages d'erreur si la chaîne n'est pas comprise entre
    ; 18 et 21 caracteres
    error_too_short:
      mov eax, chaine_trop_courte
      call _display
      mov eax, 1 ; _read_string renvoie 1 en cas d'erreur
      jmp exit_read_string

    error_too_long:
      mov eax, chaine_trop_longue
      call _display
      mov eax, 1
      jmp exit_read_string

    ; sortie de la fonction _read_string
    exit_read_string:
      mov esp, ebp
      pop ebp

      ret

  ; Nom de la fonction : _check_special_char
  ; Argument(s) : dl --> sous-registre 8-bit de edx qui contient le caractere à vérifier
  ; Rôle : La fonction _check_special_char permet de vérifier si le caractere contenue dans le sous-registre dl 
  ; est bien une lettre. Pour cela elle utilise les valeurs hexadecimal de la table ASCII pour vérifier si la valeur
  ; hexadecimal du caractere dans dl est bien comprise dans les intervalles des lettres dans la table ASCII.
  _check_special_char:
    push ebp
    mov ebp, esp

    cmp dl, 0x41 ; 41 représente un 'A' en ASCII
    jl error_special_char ; Si le caractere entree est inférieur à 41 ce n'est pas une lettre
    cmp dl, 0x5a ; 0x5a représente Z en ASCII
    jg check_min_maj ; jump pour vérifier si le caractere est dans les miniscules
    jmp continue

    check_min_maj:
      cmp dl, 0x61 ; 61 représente 'a' en ASCII
      jl error_special_char ; Si le caractere est ni dans les majuscules ni dans les miniscules alors ce n'est pas une lettre
      jmp continue

    error_special_char:
      mov eax, chaine_non_conforme
      call _display
      mov eax, 1 ; _check_special_char renvoie 1 dans le registe eax en cas d'erreur
      jmp exit_check_char

    continue:
      cmp dl, 0x7a ; 0x7a est 'z' en ASCII
      jg error_special_char ; si le caractere a une valeur hexadecimal supérieur à z en ASCII ce n'est pas une lettre
      jmp exit_check_char

    exit_check_char:
      mov esp, ebp
      pop ebp

      ret
