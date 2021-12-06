RUNS=$1

if [[ -n "$2" ]]; then
	source $2
fi

trap 'echo 1x' CHLD
while (( RUNS > 0 )); do
	echo "$(echo "heh")"
	((RUNS--))
done
trap CHLD
