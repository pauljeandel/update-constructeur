# Usage : bash update-constructeur.sh [acf-project-path] [branch-to-check]

if [ -z "$1" ]
  then
    echo "FATAL : Pas de chemin de projet ACF spécifié"
    exit 1
else
    cd $1
    if [ $? -ne 0 ]
    then
        echo "FATAL : Chemin de projet ACF invalide"
        exit 1
    fi
    if [ -z "$2" ]
    then
        echo "FATAL : Pas de branche spécifiée"
        exit 1
    else
        if [[ `git status --porcelain` ]]; then
            echo 'git status FAIL'
            echo "Une erreur est survenue. Vérifiez que vous n'avez pas de modification en cours."
            exit 1
        else
            echo
            echo 'git status OK'
            if [[ `git branch | grep $2` ]]; then
                echo
                firstcommit=$(git log main..$2 --oneline | tail -1 | cut -c1-7)
                echo 'Premier commit de la branche' $2 ':' $firstcommit
                commitbefore=$(git log main $2 --oneline | tail -1 | cut -c1-7)
                echo 'Commit précedent sur la branche principale :' $commitbefore
                echo
                echo 'Verification des mises à jour disponibles sur la branche' $2' :'
                echo
                git cherry -v $2 main $commitbefore | grep '^\+' --color
            else
                echo 'FATAL : Branche non trouvée :' $2
                exit 1
            fi
        fi
    fi
fi




# git log --oneline --all | sed -n '/f9712cc/{n;p;}' | cut -c1-8
# git cherry -v inondation-protection master 9c855e3 | grep '^\+'