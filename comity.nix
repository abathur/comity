{ stdenv, lib, resholvePackage, fetchFromGitHub, bashup-events44, doCheck ? true, bats, shellcheck}:

resholvePackage rec {
  pname = "comity";
  version = "0.1.0";

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

  inherit doCheck;
  checkInputs = [ shellcheck bats bashup-events44 ];

  meta = with lib; {
    description = "Bash library for neighborly signal sharing";
    homepage = https://github.com/abathur/comity;
    license = licenses.mit;
    maintainers = with maintainers; [ abathur ];
    platforms = platforms.all;
  };
}
