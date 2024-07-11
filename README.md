## Préréquis
Vous avez besoin de NASM pour pouvoir compiler ces programmes.
Les programmes suivant sont écrits en langage d'assemblage NASM pour des CPU avec une architecture x86.

## Compilation
Pour compiler les programmes, il faut simplement lancer le script COMPILATION.sh [numero_version] en argument.

Exemple :

```bash
$chmod +x COMPILATION.sh  
$./COMPILATION.sh 1
```

Cela génère le binaire fargier_moerdijk_v1.bin

## Utilisation
Les programmes ce stop automatiquement lorsque la chaîne rentrée n'est pas de la bonne taille.
Une fois que la chaîne est de la bonne taille alors les étapes de vérification sont réalisées.
