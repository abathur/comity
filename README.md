# Comity
comity enables modular bash scripts to trap signals
without stepping on each other's toes.

## What problem(s) does this solve?
comity helps most when you have a script that
clobbers traps others have set (which they can do
by setting their own, or by clearing all traps).

It might spare you messier fixes like:
- maintaining a patch against one of the scripts
- having to re-set the correct traps in an outer
  script/profile (leaking implementation details
  of one module outside its abstraction boundary!)

## How does it work?
comity wraps the `trap` builtin in order to provide 
a distinct namespace for each shell script that is 
executing. It injects its own trap handler, and 
passes on calls to scripts in the order registered.

Likewise, if a script clears traps, it'll only clear 
_its own_ traps.

## How do I use it?
I package comity and its dependencies with Nix and 
resholve for my own use, so that's the easiest way 
to incorporate it into a project. 

You can find a real-world example of how I do this 
in https://github.com/abathur/shellswain, but the 
basic steps are:

1. Include it in your Bash source. I use a guard 
against double-sourcing to save a little time:

    ```bash
    # save time if it's already loaded
    [[ -v __comity_signal_map ]] || source comity.bash
    ```

2. Package your script/module with Nix+resholve and 
supply comity as a dependency. Here's a basic skeleton:

    ```nix
    { lib
    , resholve
    , shellswain
    }:

    resholve.mkDerivation rec {
      pname = "your_project";
      version = "unreleased";

      src = lib.cleanSource ./.;
      # src = fetchFromGitHub {
      #   owner = "you";
      #   repo = "${pname}";
      #   rev = "v${version}";
      #   sha256 = "...";
      # };

      solutions = {
        profile = {
          scripts = [ "bin/your_module.bash" ];
          interpreter = "none";
          inputs = [ comity ];
        };
      };

      makeFlags = [ "prefix=${placeholder "out"}" ];

      doCheck = false;

      # ...
    }

    ```

    For a complete real-world example, see shellswain's 
    [shellswain.nix](https://github.com/abathur/shellswain/blob/master/shellswain.nix).


> **Note:** If you want to use shellswain without Nix, 
> you'll need to provide its dependencies: 
> - bash (uncertain on versions; I've only tested 5.1);
>   may be able to support more shells at some point
> - https://github.com/bashup/events
> 
> `comity.bash` also needs to be augmented by a signal 
>  list generated at build time. See the `build` rule 
>  in the [Makefile](Makefile).

Once you have comity included, you shouldn't need to 
do anything special--just use `trap` as normal.

## Limitations
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

2. comity uses a per-file namespace. It's not suitable 
   if you have multiple modules that are _intentionally_ 
   overwriting traps set by each other.
