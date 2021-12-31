#!/bin/bash
# Usage : bash update-constructeur.sh [acf-project-path] [branch-to-check]
currentversion=1.0

if [ "$1" == "-h" ] || [ "$1" == "help" ]
then
    echo
    echo "Usage : bash update-constructeur.sh [acf-project-path] [branch-to-check]"
    echo "	[acf-project-path] : chemin du projet ACF"
    echo "	[branch-to-check] : branche à vérifier"
    echo "	[acf-project-path -> help] : affiche cette aide"
    echo "	[acf-project-path -> [path_to_script_folder] [update]] : met à jour le script"
    echo "	[branch-to-check -> list] : affiche la liste des branches détectées localement"
    echo
    echo "Exemple : bash update-constructeur.sh ../acf-constructor list"
    echo "Exemple : bash update-constructeur.sh ../acf-constructor inondation-protection"
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
    echo
    echo -n "Script à jour ( $currentversion )"
    if [ "$2" == "update" ]
        then
            exit 0 
        fi
else
    echo "--------------------------------------------------------------------------------"
    echo
    echo "Mise à jour disponible ( $currentversion > $lastReleaseVersion )"
    echo "URL : https://github.com/pauljeandel/update-constructeur/releases/$lastReleaseVersion"
    echo
    echo "PLEASE RUN : cd ~/web/www/update-constructeur && git pull && cd - && !!"
    echo
    echo "--------------------------------------------------------------------------------"
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
            echo "Branches détectées localement sur le projet :"
            git branch
            echo
            echo "Pour détecter une nouvelle branche : cd acf-constructor && git checkout [branch-name] && cd -"
            exit 0
        fi
        if [[ `git status --porcelain` ]]; then
            echo 'git status FAIL'
            echo "Une erreur est survenue. Vérifiez que vous n'avez pas de modification en cours."
            exit 1
        else
            echo
            echo 'git status OK'
            if [[ `git branch | grep $2` ]]; then
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
                echo 'FATAL : Branche non existante ou non trouvée localement :' $2
                exit 1
            fi
        fi
    fi
fi




# git log --oneline --all | sed -n '/f9712cc/{n;p;}' | cut -c1-8
# git cherry -v inondation-protection master 9c855e3 | grep '^\+'
