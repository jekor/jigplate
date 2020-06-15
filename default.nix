{ mkDerivation, aeson, base, bytestring, parsec, stdenv, text
, unordered-containers, vector
}:
mkDerivation {
  pname = "jigplate";
  version = "0.2.2";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    aeson base bytestring parsec text unordered-containers vector
  ];
  homepage = "https://github.com/jekor/jigplate";
  description = "logicless, language-agnostic, pattern-matching templates";
  license = "MIT";
}
