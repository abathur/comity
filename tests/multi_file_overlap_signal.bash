
if [[ -n "$1" ]]; then
	source $1
	shift
fi

source single_file_single_signal.bash "" sourced

trap 'echo multifile' CHLD
echo "$(echo "multichild1")"
trap CHLD
# only single_file_single_signal's trap should be left
echo "$(echo "multichild2")"
