#get the first commit of the branch $1
git log main..$1 --oneline | tail -1
echo "Everything is up to date"