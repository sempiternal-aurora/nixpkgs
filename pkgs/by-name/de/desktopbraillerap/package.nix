{
  stdenv,
  fetchFromGitHub,
  python3Packages,
  nodejs_22,
  fetchNpmDeps,
  npmHooks,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "DesktopBrailleRAP";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "braillerap";
    repo = "DesktopBrailleRAP";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qScVFioDZ062kyvmQNnSlv+NjrEQDUDTAqFuVmT8828=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    npmHooks.npmBuildHook
  ];

  build-system = [
    python3Packages.setuptools
    # python3Packages.pyinstaller
    # python3Packages.pyinstaller-hooks-contrib
  ];
  pyproject = false;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src postPatch;
    hash = "sha256-1vj+gyCU8tR/xX+2CkEaDVxiuFvHtUtPkjgpEATstcU=";
  };

  npmBuildScript = "build";

  # buildPhase = ''
  #   runHook preBuild
  #
  #   # pyinstaller --clean --noconfirm DebianDesktopBrailleRAP.spec
  #
  #
  #   runHook postBuild
  # '';

  dependencies = (
    with python3Packages;
    [
      altgraph
      bottle
      levenshtein
      packaging
      proxy-tools
      pyserial
      pyside6
      pywebview
      qtpy
      shiboken6
    ]
  );

})
