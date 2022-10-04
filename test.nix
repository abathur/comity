{ comity
, shellcheck
, bats
, bats-require
, bashup-events44
}:

{
  upstream = comity.unresholved.overrideAttrs (old: {
    name = "${comity.name}-tests";
    dontInstall = true; # just need the build directory
    installCheckInputs = [
      comity
      shellcheck
      (bats.withLibraries (p: [ bats-require ]))
      bashup-events44
    ];
    doInstallCheck = true;
    installCheckPhase = ''
      make check
      touch $out
    '';
  });
}
