		.data
		
NB_LIG_MODEL : 	.word 12
NB_COL_MODEL :	.word 13
NB_LIG_VUE :	.word 6
NB_COL_VUE :	.word 7
NB_MAX_COUP :	.word 42
DECALLAGE :	.word 3
VIDE :		.word 0
ROUGE :		.word -1
JAUNE :		.word 1
nb_jetons :	.word 0 : 7
grille :	.word 0 : 156

nbCoupJoue : 	.word 0

symb_jaune :	.asciiz "[+]"
symb_rouge :	.asciiz "[*]"
symb_vide :	.asciiz "[ ]"

retour :	.asciiz "\n"

phrase_tour :	.asciiz " à vous de jouer\n"

demande_col :	.asciiz "Entrer une colonne (entre 1 et 7)\n"

nom_jaune :	.space 20
nom_rouge :	.space 20
demande_jaune : .asciiz "Joueur JAUNE rentrez votre prénom :"
demande_rouge : .asciiz "Joueur ROUGE rentrez votre prénom :"

msg_nul :	.asciiz "La partie est terminée, égalité la grille est pleine !"
msg_gagnant1 :	.asciiz "Le joueur "
msg_gagnant2 :	.asciiz " a gagné, félicitations !"
msgNewGame :	.asciiz "Voulez vous rejouer une partie"

resultat :	.space 300

		.text
		
main :		
		jal demandePrenom
		
debPartie :	jal initPartie
		jal resetResultat
		

		la $a0, retour 			# Saute deux lignes
		ori $v0, $0, 4
		
		syscall
		syscall
		
		jal jouerPartie
		
		ori $v0, $0, 10
		syscall



			###################### Affichage Grille ####################
			


afficherCase : 					# NECESSITE UNE COULEUR PASSEE EN PARAMETRE DANS $a0 / ne retourne rien

		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		move $t3, $a0
		
		la $t0, VIDE
		lw $t0, 0($t0) 			# Contient la valeur VIDE
		la $t1, ROUGE
		lw $t1, 0($t1) 			# Contient la valeur JAUNE
		la $t2, JAUNE
		lw $t2, 0($t2) 			# Contient la valeur ROUGE
		
		ori $v0, $0, 4 			#Code service afficher chaine de caractères
		
if_vide :	bne $t3, $t0, elsif_rouge
		la $a0, symb_vide
		syscall
		
elsif_rouge :	bne $t3, $t1, elsif_jaune
		la $a0, symb_rouge
		syscall
		
elsif_jaune :	bne $t3, $t2, end_if
		la $a0, symb_jaune
		syscall
		
end_if :	lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
		
		
afficherGrille:					# NE PREND PAS DE PARAMETRES / ne retourne rien

		subu $sp, $sp, 40
		sw $fp, 36($sp)
		addu $fp, $sp, 40
		
		la $t1, NB_LIG_VUE
		lw $t1, 0($t1) 			# Contient le nombre de ligne à afficher
		la $t2, NB_COL_VUE
		lw $t2, 0($t2) 			# Contient le nombre de colonne à afficher 
		la $t3, DECALLAGE
		lw $t3, 0($t3)			# Contient le décallage
		
		la $t4, grille 			#Contient l'adresse de la GRILLE
		addi $t4, $t4, 168 		#Contient l'adresse de la première case a afficher
		
		ori $t5, $0, 0 			# Compteur de colonne
		ori $t6, $0, 0 			# Compteur de ligne
		
		sw $ra, 0($sp)			# Enregistrement sur la pile
		sw $t1, 4($sp)			# 
		sw $t2, 8($sp) 			#
		sw $t3, 12($sp)			#
		
		
for_lignes :	beq $t6, $t1, fin_lignes
		
for_colonnes :	beq $t5, $t2, fin_colonnes
		lw $t0, 0($t4) 			# Charge la valeur de la case actuelle
		move $a0, $t0 			# Paramètre pour la fonction AfficheCase
		
		sw $t0, 28($sp) 		# Enregistrement sur la pile
		sw $t4, 16($sp)			#
		sw $t5, 20($sp)			#
		sw $t6, 24($sp)			#
	
		jal afficherCase
		
		lw $t1, 4($sp)			# Récupération des variables sur la pile
		lw $t2, 8($sp) 			#
		lw $t3, 12($sp)			#
		lw $t4, 16($sp)			#
		lw $t5, 20($sp)			#
		lw $t6, 24($sp) 		#
		lw $t0, 28($sp)			#
		
		addi $t5, $t5 1 		# On incrémente le compteur de colonne
		addi $t4, $t4 4 		# On incrémente l'adresse de la grille à la case suivante
		j for_colonnes
		
fin_colonnes :	ori $t5, $0, 0
		la $a0, retour
		ori $v0, $0, 4
		syscall
		addi $t6, $t6, 1
		addi $t4, $t4, 24 		# On passe à la prochaine case à afficher (on saute les trois cases restantes sur la ligne présente et les 3 prmière de la ligne suivante)
		j for_lignes

fin_lignes :	
		lw $ra, 0($sp)
		lw $fp, 36($sp)
		addu $sp, $sp, 40
		jr $ra
		
		
			###################### Manipulation Grille ####################
			
			
			
ajouterJeton :					# NECESSITE UN NUMERO DE COLONNE (0 - 6) PASSE EN PARAMETRE DANS $a0 / ne retourne rien
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		la $t0, nbCoupJoue
		lw $t0, 0($t0)
		la $t3, grille
		addi $t3, $t3, 428		# Correspond au numéro de la case la plus basse de la colonne 0
		
		ori $t1, $0, 2
		
		div $t0, $t1
		mfhi $t1			# Récupération de nbCoupJoué modulo 2 pour choisir la couleur
		
rouge :		bnez $t1, jaune			# $t2 contiendra la couleur du jeton à ajouter
		ori $t2, $0, -1			#
jaune :		beqz $t1, suite			#
		ori $t2, $0, 1			#
		
suite :		ori $t4, $0, 4
		mul $t4, $t4, $a0		# Décallage en fonction de la colonne entrée
		add $t3, $t3, $t4
		lw $t1, 0($t3)			# Couleur de la case la plus basse de la colonne entrée ($t1)
		
while_plein : 	beqz $t1, fin_While		# On sort du While si la case est vide
		subi $t3, $t3, 52		# On passe à la ligne du dessus
		lw $t1, 0($t3)
		j while_plein
		
fin_While :	sw $t2, 0($t3)			# Nouvelle couleur dans la case vide trouvée

		la $t0, nb_jetons		# Mise à jour du tableau qui contient le nombre de jetons par colonne
		mul $t3, $a0, 4			#
		add $t0, $t0, $t3		#
		lw $t4, 0($t0)			#
		addi $t4, $t4, 1		#
		sw $t4, 0($t0)			#

		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
						# NECESSITE des coordonnées x ($a0)(colonne) et y ($a1)(ligne) / retourne la couleur de la case dans ($v0)
						# Les coordonnées seront prisent à partir d'un repère où la case (0,0) sera la ligne 0 
						# et colonne 0 de la grille affichée.
demanderCouleur:	
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		move $t1, $a0			# Récupération des paramètres
		move $t2, $a1			#
		
		la $t0, grille
		addi $t0, $t0, 428		# Correspond à la case de coordonnée (0,0)
		mul $t1, $t1, 4			# Décalage sur les colonnes
		mul $t2, $t2, 52		# Décalage sur les lignes
		
		add $t0, $t0, $t1		# Application des décalages sur l'adresse de la case
		sub $t0, $t0, $t2		#
		
		lw $v0, 0($t0)			# Chargement de la couleur dans la variable de retour
		
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
				
					
						
initPartie :					# NE NECESSITE RIEN / ne retourne rien (réinitialise la grille pour nouvelle partie)
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		la $t0, grille			# adresse de la grille dans $t0
		ori $t1, $0, 0			# $t1 : compteur pour for
		
forInitGrille :	beq $t1, 156, finInitGrille

		sw $0, 0($t0)
		addi $t0, $t0, 4		# Incrémentation de l'adresse
		addi $t1, $t1, 1		# Incrémentation du compteur
		j forInitGrille
		
finInitGrille :	la $t0, nb_jetons
		ori $t1, $0, 0
		
forInitJeton:	beq $t1, 7, finInit		# Initialise le tableau nb_jetons

		sw $0, 0($t0)
		addi $t0, $t0, 4
		addi $t1, $t1, 1
		j forInitJeton		
		
finInit :	la $t0, nbCoupJoue		# Réinitialise le nombre de coup à 0
		sw $0, 0($t0)			#
		
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
resetResultat :					# NE NECESSITE RIEN / ne retourne rien (réinitialise la chaine resultat)
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		la $t0, resultat
		ori $t1, $0, 0
		
forInitRes :	beq $t1, 300, finReset
		sb $0, 0($t0)
		addi $t0, $t0, 1
		addi $t1, $t1, 1
		j forInitRes
		
finReset :	lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
	
			
			###################### Jeu Puissance 4 ####################
			
estCoupValide :					# NECESSITE un numéro de colonne (0 - 6) en parametre ($a0) / retourne 1 si coup valide 0 sinon ($v0)
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		la $t0, nb_jetons
		mul $a0, $a0, 4
		add $t0, $t0, $a0		# On se place dans la case qui compte les jetons de la colonne demandée
		
		lw $t1, 0($t0)			# Nombre de jetons dans cette colonne
		ori $t2, $0, 6			# Nombre max de jetons

if_non_valide :	bne $t1, $t2, elsif_valide	# Compare le compteur de cases occupées avec le nombre de cases dans une colonne
		ori $v0, $0, 0			# Retourne "le coup n'est pas valide"
elsif_valide :	beq $t1, $t2, fin_estValide
		ori $v0, $0, 1			# Retourne "le coup est valide"
		
fin_estValide :	lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
		
jouerCoup :					# NE NECESSITE RIEN / retourne la colonne entrée par l'utilisateur ($v0)
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		sw $ra, 0($sp)			# Enregistrement sur la pile de l'adresse de retour 
		
				
		la $a0, retour			# Afficher un retour a la ligne
		ori $v0, $0, 4			#
		syscall				#
		syscall				#
		
		
		jal afficherGrille
		
		la $t0, nbCoupJoue
		lw $t0, 0($t0)
		ori $t1, $0, 2
		div $t0, $t1
		mfhi $t1
		
		sw $t1, 4($sp)
		jal resetResultat		# réinitialise la chaine resultat 
		lw $t1, 4($sp)

		
tour_rouge :	bnez $t1, tour_jaune		# Affichage de la couleur du joueur dont c'est le tour de jouer
		la $a0, nom_rouge		# charge le nom du joueur jaune
		la $a1, phrase_tour		# charge la phrase tour
		jal concatenation		# concatene les deux 
		move $a0, $v0
		ori $v0, $0, 4
		syscall
		lw $t1, 4($sp)
					
tour_jaune :	beqz $t1, suite_coup
		la $a0, nom_jaune		
		la $a1, phrase_tour		
		jal concatenation		
		move $a0, $v0
		ori $v0, $0, 4
		syscall		
		
suite_coup :	la $a0, demande_col		# Affichage de la demande de colonne
		ori $v0, $0, 51
		syscall
		
		bnez $a1, suite_coup		# Mauvaise entrée
		bge $a0, 8, suite_coup		#
		ble $a0, 0, suite_coup		#
		
		addi $a0, $a0, -1		# Colonne entre 1 et 7 en entrée : more user friendly
		sw $a0, 4($sp)			# Stockage de la valeur de la colonne sur la pile
		
		jal estCoupValide
		move $t1, $v0			# Récupération de la valeur retournée par la fonction
		
		beqz $t1, suite_coup		# Demander la colonne tant que le coup n'est pas valide
		
		lw $a0, 4($sp)			# Récupération du numéro de colonne pour passage en paramètre 
		jal ajouterJeton
		
		lw $v0, 4($sp)			# Numéro de la colonne à retourner
		lw $ra, 0($sp)		
		
		la $t1, nbCoupJoue		# Incrémentation du nombre de coup joués 
		lw $t2, 0($t1)			#
		addi $t2, $t2, 1		#
		sw $t2, 0($t1)			#
		
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
		

estCoupGagnant :				# NECESSITE un numéro de colonne (0 - 6) en parametre ($a0) / retourne 1 si coup gagnant 0 sinon ($v0)
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		move $t4, $a0
		la $t0, nb_jetons		# On récupère l'ordonnée du dernier jeton joué dans $t0
		sll $t4, $t4, 2			#
		add $t0, $t0, $t4		#
		lw $t0, 0($t0)			#
		addi $t0, $t0, -1		# On enlève 1 car la première ligne est la logne 0
		
		sw $ra, 0($sp)
		sw $a0, 4($sp)			# Dernière colonne jouée
		sw $t0, 8($sp)			# Dernière ligne jouée
		
		move $a1, $t0
		jal demanderCouleur
		move $t5, $v0			# $t5 contient la couleur du dernier jeton joué
		
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		ori $t3, $0, 0
		
		
whileVertical :	jal demanderCouleur		# Test vertical
		bne $v0, $t5, finVertical
		addi $t3, $t3, 1
		subu $a1, $a1, 1
		j whileVertical
		
finVertical :	slti $t3, $t3, 4		# Retourne vrai si 4 jetons alignés verticalement
		bnez $t3, suite_1
		ori $v0, $0, 1
		lw $ra, 0($sp)
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
suite_1 :	lw $a0, 4($sp)
		lw $a1, 8($sp)
		ori $t3, $0, 0
		
whileHorizon_D:	jal demanderCouleur		# Test horizontal a droite
		bne $v0, $t5, suite_2
		addi $t3, $t3, 1
		addi $a0, $a0, 1
		j whileHorizon_D
		
suite_2 :	lw $a0, 4($sp)
		addi $a0, $a0, -1
		lw $a1, 8($sp)
		
whileHorizon_G:	jal demanderCouleur		# Test horizontal a gauche
		bne $v0, $t5, finHorizon
		addi $t3, $t3, 1
		addi $a0, $a0, -1
		j whileHorizon_G
		
finHorizon :	slti $t3, $t3, 4		# Retourne vrai si 4 jetons alignés horizontalement
		bnez $t3, suite_3
		ori $v0, $0, 1
		lw $ra, 0($sp)
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
suite_3 :	lw $a0, 4($sp)
		lw $a1, 8($sp)
		ori $t3, $0, 0
		
whileDiagoDH:	jal demanderCouleur		#Test diagonale droite haute
		bne $v0, $t5, suite_4
		addi $t3, $t3, 1
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j whileDiagoDH
		
suite_4 :	lw $a0, 4($sp)
		addi $a0, $a0, -1
		lw $a1, 8($sp)
		addi $a1, $a1, -1
					
whileDiagoGB:	jal demanderCouleur		#Test diagonale gauche basse
		bne $v0, $t5, finDiago_1
		addi $t3, $t3, 1
		addi $a0, $a0, -1
		addi $a1, $a1, -1
		j whileDiagoGB		
		
finDiago_1 :	slti $t3, $t3, 4		# Retourne vrai si 4 jetons alignés dans la diagonale croissante de gauche a droite
		bnez $t3, suite_5
		ori $v0, $0, 1
		lw $ra, 0($sp)
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
suite_5 :	lw $a0, 4($sp)
		lw $a1, 8($sp)
		ori $t3, $0, 0
		
whileDiagoDB:	jal demanderCouleur		#Test diagonale droite basse
		bne $v0, $t5, suite_6
		addi $t3, $t3, 1
		addi $a0, $a0, 1
		addi $a1, $a1, -1
		j whileDiagoDB
		
suite_6 :	lw $a0, 4($sp)
		addi $a0, $a0, -1
		lw $a1, 8($sp)
		addi $a1, $a1, 1
		
whileDiagoGH:	jal demanderCouleur		#Test diagonale gauche haute
		bne $v0, $t5, finDiago_2
		addi $t3, $t3, 1
		addi $a0, $a0, -1
		addi $a1, $a1, 1
		j whileDiagoGH
		
finDiago_2 : 	slti $t3, $t3, 4		# Retourne vrai si 4 jetons alignés dans la diagonale décroissante de gauche a droite
		bnez $t3, fin_fonction
		ori $v0, $0, 1
		lw $ra, 0($sp)
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
fin_fonction :	ori $v0, $0, 0
		lw $ra, 0($sp)
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
		
		
jouerPartie :					# NE NECESSITE RIEN / ne retourne rien
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		sw $ra, 0($sp)
		
		la $t0, nbCoupJoue
		lw $t0, 0($t0)
		
boucle_partie :	beq $t0, 42, fin_partie		# Permet de jouer un coup tant que le nombre maximum de coup n'est pas atteint
		jal jouerCoup			# ou que le coup n'est pas un coup gagnant
		sw $v0, 4($fp)
		move $a0, $v0
		jal estCoupGagnant
		la $t0, nbCoupJoue
		lw $t0, 0($t0)
		beqz $v0, boucle_partie

fin_partie :	lw $a0, 4($fp)			# Récupère la dernière colonne entrée par un joueur
		jal analyserFinPartie
		
		la $a0, msgNewGame		# Demande aux joueurs si ils veulent rejouer
		ori $v0, $0, 50
		syscall
		beqz $a0, debPartie
		
		lw $ra, 0($sp)
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		




analyserFinPartie :				# NECESSITE la colonne du dernier coup joué dans $a0 / ne retourne rien

		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
		sw $ra, 0($sp)
		
		move $t2, $a0			# Récupération abscisse et ordonnée du dernier coup joué
		sll $t2, $t2, 2			#
		la $t1, nb_jetons		#
		add $t1, $t1, $t2		#
		lw $t1, 0($t1)			#
		addi $t1, $t1, -1		#
		
		move $a1, $t1
		
		jal demanderCouleur
		
		move $t1, $v0			# Contient la couleur du dernier jeton
		sw $t1, 4($sp)
		
				
		la $a0, retour			# Afficher deux retour a la ligne
		ori $v0, $0, 4			#
		syscall				#
		syscall				#
		
		jal afficherGrille
		
		la $t0, nbCoupJoue
		lw $t0, 0($t0)
		lw $t1, 4($sp)
		ori $v0, $0, 55
		ori $a1, $0, 4
		
if_nul :	bne $t0, 42, if_rouge
		la $a0, msg_nul
		syscall
		j fin_analyse

if_rouge :	jal resetResultat
		lw $t1, 4($sp)			# couleur du dernier jeton ajotué
		ori $t0, $0, -1			# met "couleur rouge" dans t0
		bne $t0, $t1, else_jaune	# on compare "couleur rouge" avec la couleur du dernier jeton joué
		la $a0, msg_gagnant1
		la $a1, nom_rouge
		jal concatenation		# concantène le message de fin avec le nom du gagnant
		move $a0, $v0
		la $a1, msg_gagnant2
		jal concatenation
		la $a0, resultat
		ori $v0, $0, 55
		syscall
		j fin_analyse

else_jaune :	la $a0, msg_gagnant1
		la $a1, nom_jaune
		jal concatenation
		move $a0, $v0
		la $a1, msg_gagnant2
		jal concatenation
		la $a0, resultat
		ori $v0, $0, 55
		syscall

fin_analyse :	
		lw $ra, 0($sp)
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
demandePrenom :					# NE NECESSITE RIEN / ne retourne rien
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
		
prenomRouge :	la $a0, demande_rouge
 		la $a1, nom_rouge
 		ori $a2, $0, 20
 		ori $v0, $0, 54
 		syscall
 		bnez $a1, prenomRouge
 		
prenomJaune :	la $a0, demande_jaune
 		la $a1, nom_jaune
 		ori $a2, $0, 20
 		ori $v0, $0, 54
 		syscall
 		bnez $a1, prenomJaune
		
		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
		
		
			###################### Manipulation chaine ####################
		
		
		
		
concatenation :				# NECESSITE une chaine dans $a0, une autre dans $a1 / renvoie les deux chaine concaténées dans $v0	
		subu $sp, $sp, 32
		sw $fp, 28($sp)
		addu $fp, $sp, 32
			
		la $t0, resultat
			
copieChaine1 :	lb $t1, 0($a0)
		beqz $t1, suiteCpyCh1
		beq $t1, 10, suiteCpyCh1
		sb $t1, 0($t0)
		addi $t0, $t0, 1
		addi $a0, $a0, 1
		j copieChaine1
			
suiteCpyCh1 :	lb $t1, 0($a1)
		beqz $t1, suiteCpyCh2
		beq $t1, 10, suiteCpyCh2
		sb $t1, 0($t0)
		addi $t0, $t0, 1
		addi $a1, $a1, 1
		j suiteCpyCh1
			
suiteCpyCh2 :	la $v0, resultat

		lw $fp, 28($sp)
		addu $sp, $sp, 32
		jr $ra
		
