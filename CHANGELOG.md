# Changelog

## v0.3.0 (Jan 21 2023)
- keep some implementation-detail variables from leaking into global scope
- nix: add (and document) a devShell for testing comity

## v0.2.0 (Jan 7 2023)
- nix: refactor some bits
  - start pulling bats helpers from bats-require
  - convert to flake
  - pull tests out into flake checks (removes direct checkInput dependency on shellcheck and bats)

- fix some gaps between how our trap function and bash's trap behave:
  - handle bare invocations of `trap` (these errantly emitted nothing, but should behave like `trap -p`)
  - handle invocations with `--` as the first arg (this isn't in the synopsis, but it is what `trap -p` and bare `trap` kick out)

- upgrade traps that were already set when comity was sourced to fold them in under comity's control

  These traps weren't overwritten at source time, but a pre-set trap for a given signal would get discarded the first time you set a trap for that signal after sourcing comity.

## v0.1.4 (May 27 2022)
- Track change to resholve's Nix API

## v0.1.3 (Jan 3 2022)
- Minor cleanup

## v0.1.2 (Dec 10 2021)
- Fix shellcheck SC2184

## v0.1.1 (Dec 6 2021)
- Improve nounset compatibility

## v0.1.0 (Dec 6 2021)
First working draft.


