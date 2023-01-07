if [[ -n "$1" ]]; then
	source $1
fi

trap 'echo singlefile' CHLD
trap
