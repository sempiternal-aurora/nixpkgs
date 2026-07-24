{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  isabelleWithJars,
  writableTmpDirAsHomeHook,
}:

stdenvNoCC.mkDerivation {
  pname = "isabelle-linter";
  version = "2025-2-1.0.0";

  outputs = [
    "out"
    "settings"
  ];

  src = fetchFromGitHub {
    owner = "isabelle-prover";
    repo = "isabelle-linter";
    tag = "Isabelle2025-2-v1.0.0";
    hash = "sha256-V6Bnxyq/WI6U0sVBHA/vFOI0U3Vd5/GLCxbeWVitm8I=";
  };

  nativeBuildInputs = [
    isabelleWithJars
    writableTmpDirAsHomeHook
  ];

  buildPhase = ''
    runHook preBuild

    isabelle components -u $(pwd)
    isabelle scala_build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r linter_base jedit_linter $out/share

    mkdir -p $settings/etc
    touch $settings/etc/settings
    echo "$out/share/jedit_linter" > $settings/etc/settings
    echo "$out/share/linter_base" >> $settings/etc/settings

    runHook postInstall
  '';

  meta = {
    description = "Linter component for Isabelle";
    homepage = "https://github.com/isabelle-prover/isabelle-linter";
    maintainers = with lib.maintainers; [
      jvanbruegge
      sempiternal-aurora
    ];
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
