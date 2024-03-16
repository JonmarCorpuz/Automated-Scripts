#!/bin/bash

echo '''
   dMMMMMP .aMMMb  .aMMMb  dMMMMb  dMMMMb  dMP dMP dMMMMMP 
      dMP dMP"VMP dMP"dMP dMP.dMP dMP.dMP dMP dMP   .dMP"  
     dMP dMP     dMP dMP dMMMMK" dMMMMP" dMP dMP  .dMP"    
dK .dMP dMP.aMP dMP.aMP dMP"AMF dMP     dMP.aMP .dMP"      
VMMMP"  VMMMP"  VMMMP" dMP dMP dMP      VMMMP" dMMMMMP     
                                                           
   .dMMMb  .aMMMb  dMMMMb  dMP dMMMMb dMMMMMMP .dMMMb      
  dMP" VP dMP"VMP dMP.dMP amr dMP.dMP   dMP   dMP" VP      
  VMMMb  dMP     dMMMMK" dMP dMMMMP"   dMP    VMMMb        
dP .dMP dMP.aMP dMP"AMF dMP dMP       dMP   dP .dMP        
VMMMP"  VMMMP" dMP dMP dMP dMP       dMP    VMMMP"                                                                                                          
'''

echo "Ce script fait parti de l'ensemble des JCORPUZ SCRIPTS et sert à créer des nouveaux utilisateurs à partir d'un FICHIER TEXT fourni par l'utilisateur."
echo ""

# ---------------------------------------------------------------------------------------------------- #
# ÉTAPE 1: ASSURER QUE LE SCRIPT A ÉTÉ EXÉCUTÉ CORRECTEMENT ET QU'IL N'Y AURA AUCUN CONFLIT	       #
# ---------------------------------------------------------------------------------------------------- #

# Attribuer la date et l'heure exacte dans un variable qu'on va utiliser pour la documentation dans notre fichier log
CurrentDate=$(date '+%Y-%m-%d %H:%M:%S')

# Assurer que l'utilisateur éxécute le script correctement
if [ "$#" -eq 1 ]; then

	# Attribuer le nom du fichier texte, qui contient les nom des personnes pour qui on veut créer un compte, dans un variable
	FichierTXT="$1"
	
	# Continuer le script si le fichier spécifié par l'utilisateur existe
	if [ -e "$FichierTXT" ]; then
	
		# Initier les variables qu'on va utiliser dans ce script
		UsernamePT1="" 
		UsernamePT2="" 
		UsernamePT3="" 
		Username=""
		Compteur=1
		
		# Assurer que le script a été éxécuter en tant que root
		if [ "$EUID" -eq 0 ]; then
	
			# Assurer que le fichier qui a été dans ce script est bien un fichier text
			FichierType=$(file -b --mime-type "$FichierTXT")
			if [ "$FichierType" == "text/plain" ]; then
	
				# Assurer que le fichier qui a été spécifié par l'utilisateur n'égale pas le nom d'un des fichiers que ce script va créer
				Fichier1=$(echo "$FichierTXT" | tr '[:upper:]' '[:lower:]')
				FICHIER2="users.txt"
				if [ "$Fichier1" != "$FICHIER2" ]; then
	
					# Créer les fichiers qu'on va utiliser dans ce script
					rm Users.txt &> /dev/null
					touch Users.txt 
					touch CreateUsers.log
	
				# Afficher un message d'erreur pour demander à l'utilisateur de changer le nom de son fichier texte et quitter le script
				else

					echo "ERREUR 100: SVP changer le nom de votre fichier text."
					echo "$CurrentDate - [ERREUR 100] SVP changer le nom de votre fichier text" >> TP1.log
					echo "========================================================================" >> TP1.log
					exit
	
				fi
			
			# Afficher un message d'erreur pour aviser l'utilisateur que le fichier qu'il a donné n'est pas un fichier text et quitter le script
			else
		
				echo "ERREUR 110: $FichierTXT n'est pas un fichier text."
				echo "$CurrentDate - [ERREUR 110] $FichierTXT n'est pas un fichier text" >> TP1.log
				echo "========================================================================" >> TP1.log
				exit
		
			fi
	
		# Afficher un message d'erreur pour aviser l'utilisateur que le script n'a pas été éxécuter en tant que root et quitter le script
		else

			echo "Usage: sudo ./CreateUsers.sh <FICHIER TEXT>"
			echo "$CurrentDate - [ERREUR 120] Le script n'a pas été éxécuté correctement." >> TP1.log
			echo "========================================================================" >> TP1.log
			exit
	
		fi

	else
	
		echo "ERREUR 130: Le fichier $FichierTXT n'existe pas."
		echo "$CurrentDate - [ERREUR 130] Le fichier $FichierTXT n'existe pas." >> TP1.log
		echo "========================================================================" >> TP1.log
		exit	
		
	fi

# Afficher un message d'erreur pour aviser l'utilisateur que le script n'a pas été éxécuter correctement
else

	echo "Usage: sudo ./TP1.sh <FICHIER TEXT>"
	echo "$CurrentDate - [ERREUR 140] Le script n'a pas été éxécuté correctement." >> TP1.log
	echo "========================================================================" >> TP1.log
	exit
	
fi

# ---------------------------------------------------------------------------------------------------- #
# ÉTAPE 2: CRÉER UN FICHIER TEXT QUI CONTIENT DES USERNAMES UNIQUES POUR LES NOUVEAUX UTILISATEURS     #
# ---------------------------------------------------------------------------------------------------- #

# Créer un username unique pour chaque personne dans le fichier texte
while true; do
	
	# Vérifier que ce script peut trouver le fichier texte
	if [ -e "$FichierTXT" ]; then
		
		# Lire une ligne à la fois du fichier texte 
		while read LINE; do
			
			# Pour chaque ligne, créer un username unique avec le nom de la personne 
			while true; do
			
				# Attribuer une partie du prénom de la personne dans un variable à partir de la valeur du compteur
				UsernamePT1=$(echo $LINE | awk -v Compteur="$Compteur" '{print substr($1, 1, Compteur)}')
				
				# Attribuer le nom de la personne dans un variable
				UsernamePT2=$(echo $LINE | awk '{print $2}')
				
				# Combiner la partie du prénom qu'on a pris et le nom de la personne ensemble pour former un username
				UsernamePT3="$UsernamePT1$UsernamePT2"
				Username=$(echo "$UsernamePT3" | tr '[:upper:]' '[:lower:]')
				
				# Créer un nouveau username pour la personne si le username exsite déjà dans la liste des usernames qu'on va créer vers la fin de ce script
				if grep "$Username" "Users.txt" &> /dev/null; then
					
					# Afficher un message d'erreur si le username existe déjà dans le système dans lequel on éxécute ce script
					if id "$Username" &> /dev/null; then
					 
						echo "$CurrentDate - [ERREUR 200] Utilisateur $Username existe déja."
						echo "ERREUR 200: Utilisateur $Username existe déja." >> TP1.log

					fi
						
						# Incrémenter le compteur par un
						Compteur=$((Compteur+1))
				
				# Ajouter le username unique qu'on va créer pour cette personne dans le fichier texte qui contient tout les usernames des personnes qu'on va créer vers la fin de ce script, reinitialiser les variables et quitte ce boucle pour passer à la prochaine personne
				else
				
					echo "$Username" >> Users.txt
					echo "$CurrentDate - [SUCCÈS 100] L'utilisateur $Username a été crée avec succès." >> TP1.log

					Username=""
					Compteur=1
					break
					
				fi
				
			done
				
		done < "$FichierTXT"
		
		# Quitter la boucle pour aller créer les nouveaux utilisateurs 
		break
	
	# Afficher un message d'erreur pour aviser l'utilisateur que le fichier texte n'a pas été retrouvé
	else
	
		echo "ERREUR 300: Le fichier $FichierTXT n'existe pas." 
		echo "$CurrentDate - [ERREUR 300] Le fichier $FichierTXT n'existe pas." >> TP1.log
		break
		
	fi
	
done

# ---------------------------------------------------------------------------------------------------- #
# ÉTAPE 3: CRÉER DES UTILISATEURS À PARTIR DU FICHIER TEXTE QUI CONTIENT LES USERNAMES UNIQUE          #
# ---------------------------------------------------------------------------------------------------- #

# Vérifier que ce script peut trouver le fichier texte
if [ -e "Users.txt" ]; then

	# Lire une ligne à la fois du fichier texte 	
	while read USER; do

		# Assurer qu'il y a seulement des lettres dans le username 
		USER=$(echo "$USER" | tr -cd '[:alpha:]')

		# Assurer une deuxième fois qu'il y a seulement des lettres dans le username avant de créer l'utilisateur
		if [[ "$USER" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
		
			useradd $USER
	
		# Afficher un message d'erreur pour aviser l'utilisateur que le username contient des caractères speciaux 
		else
	
			echo "ERREUR 400: Le nom d'utilisateur contient des caractères speciaux."
			echo "$CurrentDate - [ERREUR 400] Le nom d'utilisateur contient des caractères speciaux." >> TP1.log
			
		fi
				
	done < "Users.txt"
	
# Afficher un message d'erreur pour aviser l'utilisateur que le fichier texte n'a pas été retrouvé
else

	echo "ERREUR 500: Le fichier Users.txt est introuvable."
	echo "$CurrentDate - [ERREUR 500] Le fichier Users.txt est introuvable." >> TP1.log
	
fi

# ---------------------------------------------------------------------------------------------------- #
# BLOCK OPTIONNEL: SUPPRIMER LES UTILISATEURS 							       #
# ---------------------------------------------------------------------------------------------------- #
#if [ -e "Users.txt" ]; then		
#	while read USER; do
#		USER=$(echo "$USER" | tr -cd '[:alpha:]')
#		if [[ "$USER" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then	
#			userdel $USER
#		else
#			echo "ERREUR 450: L'utilisateur $USER n'existe pas dans le système."		
#		fi			
#	done < "Users.txt"
#	echo ""
#fi

# ---------------------------------------------------------------------------------------------------- #
# ÉTAPE 4: CLEANUP ET AVISER L'UTILISATEUR QUE LE SCRIPT A FINI DE S'ÉXÉCUTER                          #
# ---------------------------------------------------------------------------------------------------- #

# Supprimer le fichier texte qui contient les usernames des utilisateurs qu'on a crée
rm Users.txt

echo "$CurrentDate - [SUCCÈS 200] Le fichier Users.txt a été supprimé avec succès." >> TP1.log
echo "========================================================================" >> TP1.log

# Afficher un message qui avise l'utilisateur que le script a été éxécuté avec succès
echo "Ce script a fini d'éxécuter. (Pour plus d'information, veuillez consulter les logs dans le fichier TP1.log de ce dossier.)"
echo ""
echo "Exiting..."

# ==================================================================================================== #
# SOCIALS:
# 	
# 	- LinkedIn: 	www.linkedin.com/jonmarcorpuz
#	- Github: 	www.github.com/jonmarcorpuz
#	- TryHackMe:	www.tryhackme.com/p/JonmarCorpuz	
# 
# ==================================================================================================== #
