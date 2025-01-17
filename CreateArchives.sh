#!/bin/bash

# --------------------------------------------------------------------------------------------------------- #
# OBJECTIFS:												   	#
# - Faire une archive du dossier personnel de l'utilisateur demandé					   	#
# - Copier l'archive dans le dossier /mnt/backup/<NOM DE L'UTILISATEUR> 				   	#
# - Confirmer l'intégrité de la copie 								   	#
# - Conserver uniquement les 3 plus récentes archives   						   	#
# --------------------------------------------------------------------------------------------------------- #

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

# Assurer que l'utilisateur éxécute le script correctement
if [ "$#" -eq 1 ] && [ "$EUID" -eq 0 ]; then

	# Créer les variables principales qu'on va utiliser dans ce script
	CurrentDate=$(date '+%Y-%m-%d_%H:%M:%S')
	ArchiveName="${CurrentDate}_$1.tar.gz"
	ArchiveLocation=$(pwd)

	# Créer un répertoire de backup pour l'utilisateur demandé
	sudo mkdir -p /mnt/backup/$1 &>/dev/null || { echo "ERREUR 1: Le script n'a pas put créer /mnt/backup/$1."; echo ""; echo "Exiting..."; exit 1; }
	
	# Créer un archive .tar.gz du dossier personnel de l'utilisateur demandé
	sudo tar -czf ./$ArchiveName /home/$1 &>/dev/null || { echo "ERREUR 2: Le script n'a pas pu créer l'archive du dossier personnel de l'utilisateur demandé."; echo ""; echo "Exiting..."; sudo rm ./$ArchiveName; exit 1; }
	
	# Copier l'archive .tar.gz qu'on vient de créer dans le répertoire de backup qu'on a créer pour l'utilisateur demandé
	cp $ArchiveLocation/$ArchiveName /mnt/backup/$1 || { echo "ERREUR 3: Le script n'a pas pu copier $ArchiveLocation/$ArchiveName vers /mnt/backup/$1."; echo ""; echo "Exiting..."; exit 1; }
	
	# S'il y a plus que trois archives dans le dossier, supprime celle qui est la plus vieille
	cd /mnt/backup/$1 
	Archives=($(ls -t *.tar.gz)) 
	
	if [ "${#Archives[@]}" -gt 3 ]; then
	
    		#echo "Removing ${Archives[-1]}"
    		rm "${Archives[-1]}" || { echo "ERREUR 4: Le script n'a pas pu supprimer l'archive .tar.gz la plus vieille."; echo ""; echo "Exiting..."; exit 1; }
    		
	fi
	
	# Vérifier l'intégrité du copie de l'archive qu'on a copié dans le répertoir de backup de l'utilisateur demandé
	OriginalArchivePath=$ArchiveLocation/$ArchiveName
	ArchiveCopyPath=/mnt/backup/$1/$ArchiveName
	
	OriginalArchiveHash=$(sha256sum $OriginalArchivePath)
 	ArchiveCopyHash=$(sha256sum $ArchiveCopyPath)
 	
 	if [ ${OriginalArchiveHash[1]} = ${ArchiveCopyHash[1]} ]; then
 		
		echo "" && echo "$OriginalArchivePath et $ArchiveCopyPath sont les mêmes." && echo ""
	    
		# Supprimer l'archive original
		sudo rm $ArchiveLocation/$ArchiveName || { echo "ERREUR 5: Le script n'a pas pu supprimer l'archive original."; echo ""; echo "Exiting..."; exit 1; }
	    
	else

		echo "" && echo "$OriginalArchivePath et $ArchiveCopyPath ne sont pas les mêmes." && echo ""
		echo "Exiting ..."
		exit 1

	fi

else

	# Afficher un message d'erreur si le script n'a été bien éxécuté
	echo "Usage: sudo ./TP2.sh <NOM DE L'UTILISATEUR>"

fi

# Afficher un message indiquant que le script a été éxecuté avec success
echo && echo "Le script a été exécuté avec succes." && echo "" && echo "Exiting ..."
exit 0
