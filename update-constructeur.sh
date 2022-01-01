#!/bin/bash
# Usage : bash update-constructeur.sh [acf-project-path] [branch-to-check]
currentversion=1.0

if [ "$1" == "-h" ] || [ "$1" == "help" ]
then
    echo
    echo "Usage : bash update-constructeur.sh [arg1] [arg2] [arg3]" 
    echo
    echo "- [path_to_acf_project] list                        : Lister les projets disponibles localement"
    echo "- [path_to_acf_project] listall                     : Lister les projets disponibles localement et sur le dépot"
    echo "- [path_to_acf_project] [branch-to-check]           : Lister les mises à jour disponibles sur un projet"
    echo "- [path_to_acf_project] [branch-to-check] update    : Générer une commande de mise à jour "
    echo 
    echo "Exemple :"
    echo "bash update-constructeur.sh ../acf-constructor list"
    echo "bash update-constructeur.sh ../acf-constructor projet"
    echo "bash update-constructeur.sh ../acf-constructor projet update"
    echo
    exit 0
fi

#| grep -oP '(?<=tag\/)[^"]*'
content=$(wget https://github.com/pauljeandel/update-constructeur/releases -q -O -)
lastRelease=$(echo "$content" | tr ' ' '\n' | grep -n '/pauljeandel/update-constructeur/releases/tag/' | head -n 1)
#echo -n ${lastRelease: -4} | cut -c1-3
lastReleaseVersion=$(echo ${lastRelease: -4} | cut -c1-3)
if [ $lastReleaseVersion == $currentversion ]
then
    if [ "$2" == "update" ]
    then
        echo
        echo "Script déja à jour. ( $currentversion )"
        echo "URL : https://github.com/pauljeandel/update-constructeur/releases/$currentversion"
        echo
        exit 0 
    else
        echo
        echo -n "Script à jour ( $currentversion )"
    fi

else
    if [ "$2" == "update" ]
    then
        echo
    else
        echo "--------------------------------------------------------------------------------"
        echo
        echo "Mise à jour disponible ( $currentversion > $lastReleaseVersion )"
        echo "URL : https://github.com/pauljeandel/update-constructeur/releases/$lastReleaseVersion"
        echo
        echo -n "Voulez-vous mettre à jour le script ? (Y/n) : "
        read answer
        if [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "" ]
        then
            bash ~/web/www/update-constructeur/update-constructeur.sh ~/web/www/update-constructeur update
            exit 0
            echo
        else
            echo
            echo "PLEASE RUN : bash update-constructeur.sh [path-to-script-folder] update"
            echo "--------------------------------------------------------------------------------"
            echo
        fi
    fi
fi


if [ -z "$1" ]
  then
    echo "FATAL : Pas de chemin de projet ACF spécifié"
    exit 1
else
    cd $1
    if [ $? -ne 0 ]
    then
        echo "FATAL : Chemin du projet ACF invalide"
        exit 1
    fi
    if [ -z "$2" ]
    then
        echo "FATAL : Pas de branche spécifiée"
        exit 1
    else
        if [ "$2" == "update" ]
        then
            echo
            echo "Mise à jour du script... > $lastReleaseVersion"
            cd $1 && git pull -f
            git checkout -f main
            echo "Mise à jour terminée ( $lastReleaseVersion )"
            bash update-constructeur.sh help
            exit 0 
        fi
        if [ "$2" == "master" ]
        then
            echo
            echo "FATAL : Impossible de comparer master avec master"
            exit 1
        fi
        if [ "$2" == "list" ]
        then
            echo
            echo "Projets détectées localement :"
            git branch
            echo
            exit 0
        fi
        if [ "$2" == "listall" ]
        then
            echo
            echo "Projets détectées sur le dépot distant :"
            git branch -a
            echo
            exit 0
        fi
        if [[ `git status --porcelain` ]]; then
            echo
            echo 'FATAL : git status FAIL'
            echo "Une erreur est survenue. Vérifiez que vous n'avez pas de modification en cours."
            exit 1
        else
            echo
            echo 'git status OK'
            if [[ `git branch | grep $2` ]]; then
                #if $3 exist
                if [ -z "$3" ];then
                    echo
                    firstcommit=$(git log master..$2 --oneline | tail -1 | cut -c1-7)
                    echo 'Premier commit de la branche' $2 ':' $firstcommit
                    #git log master $2 --oneline | sed -n '/'$2'/{n;p;}' | cut -c1-7
                    #git log master $2 --oneline | sed -n "/$firstcommit/{n;p;}"
                    commitbefore=$(git log master $2 --oneline | sed -n "/$firstcommit/{n;p;}" | cut -c1-7)
                    echo 'Commit précedent sur la branche principale :' $commitbefore
                    echo
                    echo 'Mises à jour disponibles sur la branche' $2' :'
                    echo
                    git cherry -v $2 master $commitbefore | grep '^\+' --color
                    echo
                    echo 'Mises à jour déjà appliquées sur la branche' $2' :'
                    echo
                    git cherry -v $2 master $commitbefore | grep '^\-' --color
                    echo
                    exit 0
                else 
                    if [ "$3" == "update" ]
                    then
                        firstcommit=$(git log master..$2 --oneline | tail -1 | cut -c1-7)
                        commitbefore=$(git log master $2 --oneline | sed -n "/$firstcommit/{n;p;}" | cut -c1-7)
                        fullcommand=''
                        while read line ; 
                        do 
                            line=${line:2}
                            hash=${line%% *} 
                            truehash=$(echo $hash  )

                            line=${line#* }
                            line=${line// /_}
                            fullcommand=$(echo "$fullcommand $truehash $line off")
                            
                        done <<<$(git cherry -v $2 master $commitbefore | grep '^\+')
                        result=$(whiptail --checklist "Sélectionner les mises à jour à appliquer sur la branche $2 :" 20 100 13 $fullcommand 3>&1 1>&2 2>&3 )
                        exitstatus=$?
                        if [ $exitstatus = 0 ]; then
                            result=${result//\"/}
                            echo
                            echo "Commande de mise à jour ( A faire dans VsCode pour pouvoir gérer les conflits ):" 
                            echo "--------------------------------------------------------------------------------"
                            echo
                            echo "cd $1 && git checkout $2 && git cherry-pick $result"
                            echo
                            echo "--------------------------------------------------------------------------------"
                            echo
                            exit 0
                        else
                            echo "Commande annulée ou aucun patch disponible"
                            exit 0
                        fi
                    fi
                fi
            else
                echo 'ERREUR : Branche non existante ou non trouvée localement :' $2
                echo -n 'Rechercher et ajouter la branche localement depuis le dépot ? (Y/n) : '
                read answer
                if [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "" ]
                then
                    echo "Recherhe de la branche $2 sur le dépot distant..."
                else
                    echo
                    echo "Stoping..."
                    exit 0
                fi
                remote_branch=$(git branch -a | grep $2)
                if [ $remote_branch ]
                then
                    echo 'Found : ' $remote_branch
                    echo "pulling..."
                    echo
                    current_branch_name=$(git rev-parse --abbrev-ref HEAD)
                    cd $1
                    git checkout $2 && git checkout $current_branch_name
                    if [ $? -ne 0 ]
                    then
                        echo "FATAL : Impossible d'auto-discover, git checkout failed : $2"
                        exit 1
                    else
                        echo
                        echo "SUCCESS : La branche $2 est maintenant détectée localement sur le projet."
                        echo "Re-Running : bash update-constructeur.sh $1 $2.."
                        echo
                        bash ~/web/www/update-constructeur/update-constructeur.sh $1 $2
                    fi
                else
                    echo "FATAL : Branche non trouvée : $2"
                    exit 1
                fi
            fi
        fi
    fi
fi
