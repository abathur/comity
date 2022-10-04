{ lib
, resholve
, callPackage
, bashup-events44
}:

resholve.mkDerivation rec {
  pname = "comity";
  version = "0.1.4";

  # src = fetchFromGitHub {
  #   owner = "abathur";
  #   repo = "comity";
  #   # rev = "b6753c6c17be8b021eedffd57a6918f80b914662";
  #   # rev = "v${version}";
  #   sha256 = "0jninx8aasa83g38qdpzy86m71xkpk7dzz8fvnab3lyk9fll4jk0";
  # };

  src = ./.;

  prePatch = ''
    patchShebangs .
  '';

  solutions = {
    profile = {
      scripts = [ "bin/comity.bash" ];
      interpreter = "none";
      inputs = [ bashup-events44 ];
    };
  };

  makeFlags = [ "prefix=${placeholder "out"}" ];

  doCheck = false;

  # TODO: below likely needs fixing
  passthru.tests = callPackage ./test.nix { };

  meta = with lib; {
    description = "Bash library for neighborly signal sharing";
    homepage = https://github.com/abathur/comity;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
