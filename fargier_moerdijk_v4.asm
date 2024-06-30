;----------------------------------------------------------------------------
; Auteur : Fargier Mayeul, Moerdijk Jean-Leonard 
;
; Objectif du programme :Ce programme en langage d'assemblage permet de récupérer 
; une chaîne de caractère entre 18 et 21 caractères saisie par l'utilisateur.
; Il inverse ensuite la chaine et vérifie si la chaîne de caractere inversé saisie correspond au mot de passe inversé enregistré
; dans un fichier.
; 
; Entree : Une chaine de caractere.
; Sortie : Erreur si la chaîne contient un caractere special, n'est pas comprise entre 18 et 21 caracteres ou ne correspond pas au mot de passe.
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
;     --> _display, fonction qui s'occupe de l'affichage.
;     --> _read_string, fonction qui s'occupe de lire sur l'entrée standard pour récuperer la chaîne de caractere saisie.
;     --> _check_password, fonction qui vérifie si les deux mots de passes correspondent.
;     --> _check_equal, fonction qui permet vérifier si deux caracteres sont égaux.
;     --> _invert_string, fonction qui inverse la chaîne de caracteres saisie.
;     --> _size_of_string, fonction qui renvoie la taille d'une chaîne de caracteres.
;     --> _check_special_char, fonction qui s'occupe de vérifier si la chaîne contient uniquement des lettres.
;     --> _read_file, fonction qui lit le contenue d'un fichier.
%include 'asm_io.inc' ; Librairie externe utilisée pour importer les fonctions print_nl et print_string
%define taille_max_chaine 200 ; taille maximum de la chaîne pouvant être entrée par l'utilisateur.

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
  OPEN_CALL equ 5; numéro pour l'appel système open()
  CLOSE_CALL equ 6 ; numéro pour l'appel système close()
  STDIN equ 0 ; 0 représente l'entrée standard
  STDOUT equ 1 ; 1 représente la sortie standard
  WRITE_CALL equ 4 ; 4 est le numéro dans la table des appels systèmes pour l'appel système write(), qui permet d'écrire sur le flux spécifié
  READ_CALL equ 3 ; 3 est le numéro dans la table des appels systèmes pour l'appel système read(), qui permet de lire sur le flux spécifié.
  EXIT_CALL equ 1 ; 1 est le numéro dans la table des appels systèmes pour l'appel système exit(), qui permet de terminer un programme.
  SYS_CALL equ 0x80

section .bss
  mot_de_passe: resd taille_max_chaine
  entree_buffer: resd taille_max_chaine

section .text
  global _start

   ; Bloc d'instructions de la fonction principale _start
  ; La fonction _start fait appelle à plusieurs fonctions. Pour afficher le message demandant une saisie de l'utilisateur elle appelle la fonction _display.
  ; Elle appelle ensuite la fonction _read_string qui récupere et verifie si la chaîne entrée contient uniquement des lettres et si elle est comprise
  ; entre 18 et 21 caracteres. De plus elle inverse la chaîne de caracteres et vérifie si la chaîne correspond au mot de passe inversé.
  ; Ensuite elle quitte le programme. Renvoie 0 si tout c'est bien passé.
  _start:
    call _read_file ; appel de la fontion _read_file pour lire le contenue du fichier spécifié par filename
    cmp eax, 0 ; on vérifie si la lecture c'est bien passé 
    jne exit_start ; sinon on sort du programme

    mov eax, message ; Appel de la fonction _display pour afficher les messages
    call _display ; eax contient la chaîne qui va être utilisé par print_string

    push entree_buffer ; On passe entree_buffer comme argument de la fonction _read_string par la pile, elle servira aussi pour la fonction _check_password 
    call _read_string ; appel de la fonction _read_string

    cmp eax, 0 ; _read_string renvoie 0 dans le registre eax en cas de réussite sinon elle renvoie 1
    jne exit_start
    
    mov eax, entree_buffer ; eax contient l'adresse de début du buffer entree_buffer
    ; et eax est utilisé comme argument pour la fonction _invert_string
    call _invert_string ; appel de la fonction _invert_string pour inverser la chaîne contenue
    ; dans entree_buffer
    mov eax, entree_buffer ; 1er argument pour la fonction _check_password
    mov edx, mot_de_passe ; 2ème argument pour la fonction _check_password
    call _check_password ; appel de la fonction _check_password
    
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
    push ebp
    mov ebp, esp

    call print_string ; Fonction importé de la librairie asm_io, elle affiche le string donné en argument
    call print_nl ; Fonction importé de la librairie asm_io, elle affiche un retour à la ligne

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

  ; Nom de la fonction : _read_string
  ; Argument(s) : entree_buffer --> passé par la pile, buffer pour récuperer la saisie de l'utilisateur
  ; Rôle : La fonction _read_string lit sur l'entrée standard la saisie de l'utilisateur. Elle stocke cette saisie dans le buffer
  ; entree_buffer. Ce buffer est ensuite vérifié par l'appel à la fonction _check_special_char, afin de vérifier si la chaîne contient seulement
  ; des lettres. _read_string vérifie aussi la taille de la chaîne à l'aide du registre eax qui contient la taille de la saisie après l'appel système READ.
  ; Retour : eax --> 0 ou 1. 0 si la fonction réussit, 1 si elle faillit.
  _read_string:
    push ebp
    mov ebp, esp

    mov esi, eax ; eax contient l'adresse du premiere octet du buffer entree_buffer
    ; on copie cette adresse dans esi car eax va changer de valeur plusieurs fois dans la fonction

    mov eax, READ_CALL
    mov ebx, STDIN
    mov ecx, esi
    mov edx, taille_max_chaine
    int SYS_CALL

    cmp eax, 22 ; Vérifie si la chaîne comporte plus de 21 caracteres
    jg error_too_long 
    cmp eax, 18 ; Vérifie si la chaîne n'est pas inferieur à 18 caracteres
    jb error_too_short

    ; bloc qui remplace le caractere de retour à la ligne par
    ; un caractere de fin de chaîne
    dec eax
    mov BYTE [esi + eax], 0

    mov eax, 0 ; Si _read_string réussit elle renvoie 0

    lea esi, [esi] ; Charge la chaîne dans entree_buffer dans le registre esi

    ; Boucle qui itère sur la chaîne de caracteres
    ; Elle s'arrete quand elle rencontre le caracteres de retour à la ligne
    ; La boucle vérifie si chaque caractere est bien une lettre à l'aide de la fonction _check_special_char
    loop_check: 
      mov dl, [esi] ; copie un caractere du buffer entree_buffer dans dl
      cmp dl, 0 ; on compare dl à 0
      je exit_read_string ; si dl est égal à 0, qui est le caractere de fin de chaîne alors on sort de la fonction

      call _check_special_char ; appel de la fonction _check_special_char pour vérfier si dl ne contient pas de caractere
      ; spécial

      cmp eax, 0 ; _check_special_char renvoie 0 si dl est bien une lettre
      jne exit_read_string ; si dl ne contient pas de lettre alors on sort de la fonction

      inc esi

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

  ; Nom de la fonction : _check_password
  ; Rôles : La fonction _check_password fait appelle à la fonction _check_equal pour vérifier caractere par caractere
  ; si l'entree de l'utilisateur est égal au mot de passe.
  ; Retour : Affiche si le mot de passe est valide ou non, ou si le nombre maximum d'essais a été atteint.
  _check_password:
    push ebp
    mov ebp, esp

    mov ecx, 4 ; compteur de la boucle, initialisé à 4
    loop_check_pwd:
      push ecx ; sauvegarde du compteur
      push edx ; 1er argument pour la fonction _check_equal, edx contient l'adresse du premier octet pour mot_de_passe
      push eax ; 2ème argument pour la fonction _check_equal, eax contient l'adresse du premier octet pour entree_buffer
      call _check_equal ; appel de la fonction _check_equal pour vérifier si les mots de passe, correspondent
      ;----------------------------------------
      ; Si mot_de_passe == entree_buffer alors
      ;   afficher "Mot de passe valide"
      ; sinon
      ;   _read_string(entree_buffer)
      ;----------------------------------------
      cmp eax, 0 ; _check_equal renvoie 0 si les mdp correspondent
      je right_pwd ; si il correspondent on sort de la fonction 
      pop eax ; on récupere eax sur la pile
      ; eax ayant été modifié par _check_equal, il fallait le sauvegarder sur la pile
      ; Si les mots de passes ne correspondent pas alors on re demande une saisie
      push eax ; on repasse eax sur la pile comme argument de _read_string 
      call _read_string
      pop eax ; on récupere la valeur de eax 
      ; _invert_string prend en argument eax, qui contient la chaîne à inverser
      call _invert_string
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
      
  ; Nom de la fonction : _check_equal
  ; Argument(s) : le mot de passe saisie et le mot de passe stocké dans eax et edx 
  ; Rôles : La fonction _check_equal utilise une boucle pour vérifier caractere par caractere si les deux
  ; chaînes sont égales. 
  ; Retour : eax --> 1 ou 0. 1 si les deux chaînes ne sont pas égales, 0 si elles sont les mêmes.
  _check_equal:
    push ebp
    mov ebp, esp

    lea esi, [eax]
    lea edi, [edx]

    loop:
      mov dl, [esi] ; on stocke les premiers caracteres de chacunes des chaînes
      mov bl, [edi]

      inc esi ; on les registres pour passer aux caracteres suivant de chaques chaînes
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
  
  ; Nom de la fonction : _invert_string
  ; Argument(s) : eax --> contenant l'adresse de la chaîne à inverser.
  ; Rôles : La fonction _invert_string est utilisée pour inverser une chaîne de caracteres.
  ; Retour : N/A
  _invert_string:
    push ebp
    mov ebp, esp

    call _size_of_string ; _size_of_string prend en argument la chaîne de caracteres 
    ; pour qui il faut compter le nombre de caracteres.
    ; Ici eax est passé implicitement car on passe deja eax à la fonction _invert_string
    
    dec ecx ; ecx est la valeur retourné par _size_of_string, elle contient la taille de la chaîne moins le caractere de fin
    mov edi, 0 ; on initialise un compteur à zéro
    mov dl, BYTE [eax + ecx] ; on stocke dans le registre dl le dernier caractere de la chaîne
    mov bl, BYTE [eax + edi] ; on stocke dans le registre bl le premier caractere de la chaîne
    mov BYTE [eax + edi], dl ; ici on inverse les caracteres dans la chaînes
    mov BYTE [eax + ecx], bl

    ; la boucle réalise les même operations qu'au dessus, jusqu'a que ecx et edi soit egaux
    ; ou que edi > ecx pour la chaînes à nombre de caracteres impaires.
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

  ; Nom de la fonction : _size_of_string
  ; Argument(s) : eax --> adresse de la chaîne de caractere.
  ; Rôles : La fonction _size_of_string compte le nombre de caracteres dans la chaîne passé en argument.
  ; Retour : ecx --> nombre de caracteres - le caractere de fin de chaîne.
  _size_of_string:
    push ebp
    mov ebp, esp
    
    lea esi, [eax]
    mov ecx, 0

    ; La boucle compte la nombre de caracteres dans la chaîne 
    ; on sort dans la boucle quand on rencontre le caractere de fin de chaîne
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


  ; Nom de la fonction : _read_file
  ; Rôles : La fonction _read_file lit le contenue d'un fichier et le stocke dans le buffer mot_de_passe.
  ; Retour : eax --> 0 en cas de lecture et 1 en cas d'erreur.
  _read_file:
    push ebp
    mov ebp, esp

    mov ebx, filename ; nom du fichier à lire
    mov eax, OPEN_CALL
    mov ecx, 0 ; Mode read only
    int SYS_CALL

    cmp ecx, 0 ; si l'appel système renvoie un numéro inférieur à 1 
    ; alors la lecture à échoué
    jl error_read_file

    push eax ; eax contient le file descriptor du fichier 
    ; on le sauvegarde sur la pile car il va être ecrase par l'appel système READ
    ; et nous en aurons besoin pour fermer le fichier

    mov ebx, eax ; l'appel système read ici va lire sur le flux du fichier
    mov eax, READ_CALL 
    mov ecx, mot_de_passe ; on stocke le contenue du fichier dans le buffer mot_de_passe
    mov edx, taille_max_chaine
    int SYS_CALL

    ; On remplace le retour à la ligne par un caractere de fin de chaîne
    dec eax
    mov BYTE [mot_de_passe + eax], 0

    ; on vérifie s'il n'y a pas eu d'erreur lors de la lecture du fichier
    cmp ecx, 0
    jl error_read_file

    pop eax ; on récupere le file descriptor précedemment sauvegardé 

    ; on ferme le flux du fichier
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
