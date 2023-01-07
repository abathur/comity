trap 'echo singlefile' EXIT

if [[ -n "$1" ]]; then
	source $1
fi

echo "$(echo "singlechild1")"
echo "$(echo "singlechild2")"

trap
