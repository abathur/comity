# Comity

comity enables modular bash scripts to trap signals
without stepping on each other's toes.

## Example

```bash
bash-5.1$ source comity.bash

bash-5.1$ trap 'echo saving shell history!' EXIT

bash-5.1$ cat git-prompt-plugin.sh
trap 'echo shutting down gitstatusd!' EXIT

bash-5.1$ source git-prompt-plugin.sh

bash-5.1$ exit
exit
saving shell history!
shutting down gitstatusd!
```

## What problem(s) does this solve?

comity helps most when you have a script that
clobbers traps others have set (which they can do
by setting their own, or by clearing all traps).

From different angles, this variously spares you
from:
- maintaining a patch against one of the scripts
- having to re-set the correct traps in an outer
  script/profile (leaking implementation details
  of one module outside its abstraction boundary!)

## Misc.

I haven't had much time to think about how to
present this, yet, so this will just be a hodgepodge
for now.

1. comity wraps the trap builtin to manage separate
   callbacks for distinct scripts. This means:

   - It won't help if your scripts superstitiously
     use `builtin trap`
   - It doesn't change how signal handling works.
     A RETURN or CHLD trap triggered by a call in
     one script will still be published to all.

2. It's an implementation detail (it _could_ change),
   but comity builds on [`bashup.events`](https://github.com/bashup/events),
   an event/callback library, which is also very
   useful for building modular scripts.
