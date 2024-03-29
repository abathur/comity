#!/usr/bin/env bash

# an older, slower draft of comity had a signal normalization function
# that lazily used iterative `kill -l` invocations. Basically:
# if not numeric: kill -l CHLD|SIGCHILD|chld|sigchld -> 20
# 	if numeric: kill -l 20 -> CHLD

# This proved to be a big source of slow performance at scale for code
# that is frequently adding and removing signals, so I've compiled it
# down to a less-lazy version that builds up a mapping on load.

# I've clawed back the easiest slice of performance so I'll rest on my
# laurels for a bit, but some additional ideas might be:
# - if you can guarantee that the signal list is constant for a single
#   nix build, you could do this work once on package install, dump the
#   serialization of the mapping to disk, and see if it's faster to
#   source it than recompute it.
#   (a preliminary test suggested this was no faster, but my test suite
#   is very anemic at the moment).
# - code gen is slowish, but it might be tractable at install to do the
#   same basic task as above, but build a big select statement that does
#   the mapping?

__comity_enumerate_signals(){
	declare -Ag __comity_signal_map
	local noomber

	# explicit bash signal
	__comity_signal_map[0]=0
	__comity_signal_map[EXIT]=0
	__comity_signal_map[exit]=0

	while read -r noomber signame _junk; do
		__comity_signal_map[$noomber]=$noomber
		__comity_signal_map[$signame]=$noomber
		__comity_signal_map[SIG$signame]=$noomber
		__comity_signal_map[${signame,,*}]=$noomber
		__comity_signal_map[sig${signame,,*}]=$noomber
	done < <(
		enable -n kill
		kill --table # expect coreutils kill, fmt: 20 CHLD   Child exited: 20
		# TODO: this isn't strictly necessary, but I'm not sure how to easily
		# parse the format of the bash kill builtin; low ROI fiddling it atm.
	)
	# explicit bash signals
	((noomber++))
	__comity_signal_map[$noomber]=$noomber
	__comity_signal_map[DEBUG]=$noomber
	__comity_signal_map[debug]=$noomber
	((noomber++))
	__comity_signal_map[$noomber]=$noomber
	__comity_signal_map[ERR]=$noomber
	__comity_signal_map[err]=$noomber
	((noomber++))
	__comity_signal_map[$noomber]=$noomber
	__comity_signal_map[RETURN]=$noomber
	__comity_signal_map[return]=$noomber
}

__comity_enumerate_signals

echo "# generated by executing enumerate_signals.bash"
declare -p __comity_signal_map

# upgrade existing signals (run them through our trap)
# not strictly related to enumerating signals, but it'll
# break if the associative array isn't declared first
echo 'eval "$(builtin trap)"'
