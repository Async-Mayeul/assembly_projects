;------------------------------------------------------------
;Fichier de chargement des symboles externes
;Fichier à inclure dans vos codes
;
;------------------------------------------------------------

;------------------------------
;Fonction imprimant un espace sur la sortie standard
extern print_espace

;------------------------------
;Fonction imprimant un saut de ligne sur la sortie standard
extern print_nl

;------------------------------
;Fonction de lecture d'un entier sur l'entrée standard
;et le mettant de la registre eax.
;Permet de sauter les caractères blancs.
;Elle renvoie 0 si l'entrée n'est pas un entier.
extern read_int

;------------------------------
;Fonction imprimant le nombre contenu dans eax sur l'entrée standard
extern print_int

;------------------------------
;Affiche une chaine de caractères dont l'adresse est dans eax
extern print_string
