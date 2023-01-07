bats_load_library bats-require
load helpers

@test "single file, single signal" {
  require <({
    status 0
    line -3 equals "singlechild1"
    line -2 equals "singlefile"
    line -1 equals "singlechild2"
  })
} <<CASES
bash --norc --noprofile -i single_file_single_signal.bash
bash --norc --noprofile -i single_file_single_signal.bash $PWD/comity.bash
bash --norc --noprofile -i single_file_single_signal_doubledash.bash
bash --norc --noprofile -i single_file_single_signal_doubledash.bash $PWD/comity.bash
CASES

# just one case because stock traps don't support this case
# supporting it is the reason comity exists
@test "multiple files, overlap signal" {
  require <({
    status 0
    line -9 equals "singlechild1"
    line -8 equals "singlefile"
    line -7 equals "singlechild2"
    line -6 equals "singlefile"
    line -5 equals "multichild1"
    line -4 equals "singlefile"
    line -3 equals "multifile"
    line -2 equals "multichild2"
    line -1 equals "singlefile"
  })
} <<CASES
bash --norc --noprofile -i multi_file_overlap_signal.bash $PWD/comity.bash
CASES

@test "single file, duplicate signal" {
  require <({
    status 0
    line -3 equals "singlechild1"
    line -2 equals "duplicate"
    line -1 equals "singlechild2"
  })
} <<CASES
bash --norc --noprofile -i single_file_duplicate_signal.bash
bash --norc --noprofile -i single_file_duplicate_signal.bash $PWD/comity.bash
CASES

@test "bare invocation" {
  require <({
    status 0
    line -1 begins "trap -- '"
    line -1 ends "' SIGCHLD"
  })
} <<CASES
bash --norc --noprofile -i bare_invocation.bash
bash --norc --noprofile -i bare_invocation.bash $PWD/comity.bash
CASES

@test "upgrade existing traps" {
  require <({
    status 0
    line -4 equals "singlechild1"
    line -3 equals "singlechild2"
    line -2 equals "trap -- 'event emit __comity_trapped_0' EXIT"
    line -1 equals "singlefile"
  })
} <<CASES
bash --norc --noprofile -i upgrade_existing.bash $PWD/comity.bash
CASES
