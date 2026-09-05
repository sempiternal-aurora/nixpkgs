{
  lib,
  buildDunePackage,
  fetchFromGitHub,
  ocplib_stuff,
  menhir,
  menhirLib,
  ez_file,
  ez_cmdliner,
  iso8601,
  ezjsonm,
  toml,
}:

buildDunePackage (finalAttrs: {
  pname = "ez_toml";
  version = "0-unstable-2024-03-04";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "OCamlPro";
    repo = "ez_toml";
    rev = "e1bbb026613b68e72a837add06fe852d8876eb22";
    hash = "sha256-aehnE12Ahqu2dM1EMaot78bUqzZaPu3kFnovWgcbVw8=";
  };

  dunePackages = [
    "ez_toml"
    "toml-check"
  ];

  nativeBuildInputs = [
    menhir
  ];

  propagatedBuildInputs = [
    ocplib_stuff
    menhirLib
    ez_file
    iso8601
  ];

  buildInputs = [
    ez_cmdliner
    ezjsonm
    toml
  ];

  doCheck = true;

  meta = {
    description = "Easily build clients and servers on top of a common REST API, automatically derived from OCaml types";
    homepage = "https://github.com/OCamlPro/ez_api";
    license = lib.licenses.WITH lib.licenses.lgpl21Only lib.licenses.ocamlLgplLinkingException;
    maintainers = with lib.maintainers; [ sempiternal-aurora ];
    mainProgram = "toml-check";
  };
})
