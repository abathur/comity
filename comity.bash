#!/usr/bin/env bash

# note that this depends on having __comity_signal_map generated
# by executing enumerate_signals.bash and appending its output
if [[ -v __comity_signal_map ]]; then
	# already imported
	return
else
	[[ -v "bashup_ev[@]" ]] || source bashup.events
fi

trap(){
	# echo "trap called with args $*"
	# printf "bash_source=%s\n" "${BASH_SOURCE[@]}"
	# gen safe name from the source path of our immediate caller
	local safe_map_name="__comity${BASH_SOURCE[1]//[^0-9a-zA-Z_]/_}"
	declare -Ag "$safe_map_name"
	local -n safe_map="$safe_map_name"
	case $1 in
		"''" | -l* | -p*)
		  # l/p flags; just run
		  # l > p; p w/o specs == bare
		  # shellcheck disable=SC2064
		  builtin trap "$@";;
		-)
			shift
			if [[ $# -gt 0 ]]; then
				for signal in "$@"; do
					normalizedA="${__comity_signal_map[$signal]}"
					event off __comity_trapped_$normalizedA ${safe_map["$normalizedA"]}
					unset safe_map["$normalizedA"]
				done
			else
				for signal in "${safe_map[@]}"; do
					event off __comity_trapped_$signal ${safe_map["$signal"]}
					unset safe_map["$signal"]
				done
			fi
			;;
		*)
			local code="$1"
			shift
			if [[ -v "__comity_signal_map[$code]" ]]; then
				# code seems to be a valid signal spec
				# like trap RETURN
				# so try rming *THIS* caller's
				normalizedB="${__comity_signal_map[$code]}"
				event off __comity_trapped_$normalizedB ${safe_map["$normalizedB"]}
				unset safe_map["$normalizedB"]
				return
			fi
			for signal in "$@"; do
				normalizedC="${__comity_signal_map[$signal]}"

				if [[ -v "safe_map[$normalizedC]" ]]; then
					event off __comity_trapped_$normalizedC ${safe_map["$normalizedC"]}
					unset safe_map["$normalizedC"]
				else
					# shellcheck disable=SC2064
					builtin trap "event emit __comity_trapped_$normalizedC" "$normalizedC"
				fi

				event on __comity_trapped_$normalizedC $code
				safe_map[$normalizedC]="$code"
			done
			;;
	esac
}
