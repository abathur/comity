RUNS=$1

if [[ -n "$2" ]]; then
	source $2
fi

while (( RUNS > 0 )); do
	trap 'echo' QUIT
	trap QUIT
	((RUNS--))
done
