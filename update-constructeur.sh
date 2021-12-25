current=$(git branch --show-current)
if [[ `git status --porcelain` ]]; then
    echo 'git status FAIL'
    echo "Une erreur est survenue. Impossible de checkout sur la branche" $1 ". Vérifiez que vous n'avez pas de modification en cours."
    exit 1
else
    echo 'git status OK'
    echo 'Verification des mises à jour sur la branche' $1' :'
    echo
    firstcommit=$(git log main..$1 --oneline | tail -1 | cut -c1-8)
    echo 'Premier commit de la branche' $1 ':' $firstcommit
    commitbefore=$(git log main $1 --oneline | tail -1 | cut -c1-8)
    echo 'Commit précedent sur la branche principale :' $commitbefore
    git cherry -v $1 main $commitbefore | grep '^\+' --color
fi

# git log --oneline --all | sed -n '/f9712cc/{n;p;}' | cut -c1-8
# git cherry -v inondation-protection master 9c855e3 | grep '^\+'