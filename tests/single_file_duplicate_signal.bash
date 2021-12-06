if [[ -n "$1" ]]; then
	source $1
fi

trap 'echo singlefile' CHLD
trap 'echo duplicate' CHLD
echo "$(echo "singlechild1")"
if [[ "$2" != "sourced" ]]; then
	trap CHLD
fi
echo "$(echo "singlechild2")"

# exit 2
