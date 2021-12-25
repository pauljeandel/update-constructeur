current=$(git branch --show-current)
git checkout $1
if [ $? -eq 0 ]; then
    echo
    #get the first commit ever of the branch $1
    firstcommit=$(git log main..$1 --oneline | tail -1 | cut -c1-8)
    echo "Le hash du premier commit de la branche est : " $firstcommit
    echo
    echo "Commits disponibles pour la branche" $1 ":"
    git cherry -v $1 main 
    echo
    git checkout $current
else
    echo "Une erreur est survenue. Impossible de checkout sur la branche" $1 "."
    exit 1
fi

