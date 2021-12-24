#get the first commit ever of the branch $1
git log main..$1 --oneline | tail -1