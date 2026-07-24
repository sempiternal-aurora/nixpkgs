{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  net-tools,
  rlwrap,
  procps,
  makeDesktopItem,
  copyDesktopItems,
  isabelleComponents,
  symlinkJoin,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "isabelle";
  version = "2025-2";

  dirname = "Isabelle${finalAttrs.version}";

  src =
    if stdenv.hostPlatform.isDarwin then
      fetchurl {
        url = "https://isabelle.in.tum.de/website-${finalAttrs.dirname}/dist/${finalAttrs.dirname}_macos.tar.gz";
        hash = "sha256-jxh0luKV8WmVLpRHRa+eSuAMnBzS7UytvPfYmOREkT4=";
      }
    else if stdenv.hostPlatform.isx86 then
      fetchurl {
        url = "https://isabelle.in.tum.de/website-${finalAttrs.dirname}/dist/${finalAttrs.dirname}_linux.tar.gz";
        hash = "sha256-ogpQe8fBJw2L6WqfP77AY0U4d4nS3CxNPfYmDUe/szw=";
      }
    else
      fetchurl {
        url = "https://isabelle.in.tum.de/website-${finalAttrs.dirname}/dist/${finalAttrs.dirname}_linux_arm.tar.gz";
        hash = "sha256-ZQqWabSgh2da+zQpTYLe0vBwTUfVgN2e1FzdyfF2S90=";
      };

  nativeBuildInputs = [
    isabelleComponents.java
    copyDesktopItems
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    net-tools
  ]
  ++ (with isabelleComponents; [
    bash_process
    csdp
    cvc5
    e
    flatlaf
    minisat
    mlton
    nunchaku
    polyml
    rsync
    scala
    setup
    sha1
    vampire
    verit
    z3
    zipperposition
    elm
  ]);

  patches = [
    # Make "isabelle build" work when generating documents
    # See: https://github.com/NixOS/nixpkgs/issues/289529
    ../fix-copied-permissions.patch
  ];

  propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ procps ];

  sourceRoot = "${finalAttrs.dirname}${lib.optionalString stdenv.hostPlatform.isDarwin ".app"}";

  doCheck = stdenv.hostPlatform.system != "aarch64-linux";
  checkPhase = "bin/isabelle build -v HOL-SMT_Examples";

  postUnpack = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mv $sourceRoot ${finalAttrs.dirname}
    sourceRoot=${finalAttrs.dirname}
  '';

  postPatch = ''
    patchShebangs lib/Tools/ bin/

    substituteInPlace src/Pure/ML/ml_settings.scala \
      --replace-fail 'polyml_home + Path.basic(ml_platform)' 'Path.explode("${isabelleComponents.polyml}/bin")'

    substituteInPlace etc/components \
      --replace-fail 'contrib/bash_process-20240326' '${isabelleComponents.bash_process.settings}' \
      --replace-fail 'contrib/bib2xhtml-20190409' '${isabelleComponents.bib2xhtml.settings}' \
      --replace-fail 'contrib/csdp-6.1.1-1' '${isabelleComponents.csdp.settings}' \
      --replace-fail 'contrib/cvc5-1.2.0-1' '${isabelleComponents.cvc5.settings}' \
      --replace-fail 'contrib/e-3.2' '${isabelleComponents.e.settings}' \
      --replace-fail 'contrib/easychair-3.5' '${isabelleComponents.easychair.settings}' \
      --replace-fail 'contrib/elm-0.19.1' '${isabelleComponents.elm.settings}' \
      --replace-fail 'contrib/eptcs-1.7.0' '${isabelleComponents.eptcs.settings}' \
      --replace-fail 'contrib/find_facts_web-${isabelleComponents.find_facts_web.version}' '${isabelleComponents.find_facts_web.settings}' \
      --replace-fail 'contrib/flatlaf-${isabelleComponents.flatlaf.version}' '${isabelleComponents.flatlaf.settings}' \
      --replace-fail 'contrib/foiltex-${isabelleComponents.foiltex.version}' '${isabelleComponents.foiltex.settings}' \
      --replace-fail 'contrib/gnu-utils-20211030' '${isabelleComponents.gnu-utils}' \
      --replace-fail 'contrib/isabelle_setup-20250613' '${isabelleComponents.setup.settings}' \
      --replace-fail 'contrib/isabelle_fonts-20241227' '${isabelleComponents.fonts.settings}' \
      --replace-fail 'contrib/javamail-${isabelleComponents.javamail.version}' '${isabelleComponents.javamail.settings}' \
      --replace-fail 'contrib/jdk-21.0.9' '${isabelleComponents.java.settings}' \
      --replace-fail 'contrib/jedit-${isabelleComponents.jedit.version}' '${isabelleComponents.jedit.settings}' \
      --replace-fail 'contrib/jfreechart-${isabelleComponents.jfreechart.version}' '${isabelleComponents.jfreechart.settings}' \
      --replace-fail 'contrib/jsoup-${isabelleComponents.jsoup.version}' '${isabelleComponents.jsoup.settings}' \
      --replace-fail 'contrib/jortho-1.0-2' '${isabelleComponents.jortho.settings}' \
      --replace-fail 'contrib/jsvg-2.0.0' '${isabelleComponents.jsvg.settings}' \
      --replace-fail 'contrib/kodkodi-${isabelleComponents.kodkodi.version}' '${isabelleComponents.kodkodi.settings}' \
      --replace-fail 'contrib/lipics-3.1.3-1' '${isabelleComponents.lipics.settings}' \
      --replace-fail 'contrib/llncs-2.25' '${isabelleComponents.llncs.settings}' \
      --replace-fail 'contrib/opam-2.0.7' '${isabelleComponents.opam.settings}' \
      --replace-fail 'contrib/minisat-2.2.1-2' '${isabelleComponents.minisat.settings}' \
      --replace-fail 'contrib/mlton-20241230-1' '${isabelleComponents.mlton.settings}' \
      --replace-fail 'contrib/nunchaku-0.5' '${isabelleComponents.nunchaku.settings}' \
      --replace-fail 'contrib/naproche-20251110' '${isabelleComponents.naproche.settings}' \
      --replace-fail 'contrib/pdfjs-5.4.394' '${isabelleComponents.pdfjs.settings}' \
      --replace-fail 'contrib/polyml-5.9.2-2' '${isabelleComponents.polyml.settings}' \
      --replace-fail 'contrib/prismjs-1.30.0' '${isabelleComponents.prismjs.settings}' \
      --replace-fail 'contrib/postgresql-42.7.8' '${isabelleComponents.postgresql_jdbc.settings}' \
      --replace-fail 'contrib/rsync-3.2.7-1' '${isabelleComponents.rsync.settings}' \
      --replace-fail 'contrib/scala-${isabelleComponents.scala.version}' '${isabelleComponents.scala.settings}' \
      --replace-fail 'contrib/smbc-0.4.1' '${isabelleComponents.smbc.settings}' \
      --replace-fail 'contrib/solr-${isabelleComponents.solr.version}' '${isabelleComponents.solr.settings}' \
      --replace-fail 'contrib/spass-3.8ds-2' '${isabelleComponents.spass.settings}' \
      --replace-fail 'contrib/sqlite-${isabelleComponents.sqlite.version}' '${isabelleComponents.sqlite.settings}' \
      --replace-fail 'contrib/stack-2.15.7' '${isabelleComponents.stack.settings}' \
      --replace-fail 'contrib/vampire-4.8' '${isabelleComponents.vampire.settings}' \
      --replace-fail 'contrib/verit-2021.06.2-rmx-3' '${isabelleComponents.verit.settings}' \
      --replace-fail 'contrib/vscode_extension-20251205' "# in vscodium settings" \
      --replace-fail 'contrib/vscodium-${isabelleComponents.vscodium.version}' '${isabelleComponents.vscodium.settings}' \
      --replace-fail 'contrib/xz-java-${isabelleComponents.xz-java.version}' '${isabelleComponents.xz-java.settings}' \
      --replace-fail 'contrib/z3-${isabelleComponents.z3.version}' '${isabelleComponents.z3.settings}' \
      --replace-fail 'contrib/zipperposition-2.1-1' '${isabelleComponents.zipperposition.settings}' \
      --replace-fail 'contrib/zstd-jni-${isabelleComponents.zstd-jni.version}' '${isabelleComponents.zstd-jni.settings}'

    rm -rf contrib

    echo ISABELLE_LINE_EDITOR=${rlwrap}/bin/rlwrap >>etc/settings

    rm -rf contrib/*/src

    substituteInPlace lib/Tools/env \
      --replace-fail /usr/bin/env ${coreutils}/bin/env

    substituteInPlace src/Tools/Setup/src/Environment.java \
      --replace-fail 'cmd.add("/usr/bin/env");' "" \
      --replace-fail 'cmd.add("bash");' "cmd.add(\"$SHELL\");"

    substituteInPlace src/Pure/General/sha1.ML \
      --replace-fail '"$ML_HOME/" ^ (if ML_System.platform_is_windows then "sha1.dll" else "libsha1.so")' '"${isabelleComponents.sha1}/lib/libsha1.so"'

    substituteInPlace src/Pure/General/bibtex.scala \
      --replace-fail '$BIB2XHTML_HOME/main/bib2xhtml.pl' '$ISABELLE_BIB2XHTML'

    rm -r heaps
  '';

  buildPhase = ''
    runHook preBuild

    # Stop Isabelle trying to use `/tmp`.
    user_home="$(bin/isabelle getenv -b ISABELLE_HOME_USER)"
    mkdir -p "$user_home/etc"
    echo 'ISABELLE_TMP_PREFIX="$TMPDIR/isabelle"' > "$user_home/etc/settings"

    echo "Building HOL heap"
    bin/isabelle build -j $NIX_BUILD_CORES -v -o system_heaps -b HOL

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    mv $TMP/$dirname $out/share
    cd $out/share/$dirname
    bin/isabelle install $out/bin

    # icon
    mkdir -p "$out/share/icons/hicolor/isabelle/apps"
    cp "$out/share/Isabelle${finalAttrs.version}/lib/icons/isabelle.xpm" "$out/share/icons/hicolor/isabelle/apps/"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "isabelle";
      exec = "isabelle jedit";
      icon = "isabelle";
      desktopName = "Isabelle";
      comment = finalAttrs.meta.description;
      categories = [
        "Education"
        "Science"
        "Math"
      ];
    })
  ];

  meta = {
    description = "Generic proof assistant";
    longDescription = ''
      Isabelle is a generic proof assistant.  It allows mathematical formulas
      to be expressed in a formal language and provides tools for proving those
      formulas in a logical calculus.
    '';
    homepage = "https://isabelle.in.tum.de/";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # source bundles binary dependencies
    ];
    license = lib.licenses.bsd3;
    maintainers = [
      lib.maintainers.jvanbruegge
      lib.maintainers.sempiternal-aurora
    ];
    # need to compile the heaps for host on build
    # which requires us to use the host polyml toolchain
    broken = !(stdenv.buildPlatform.canExecute stdenv.hostPlatform);
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };

  passthru = {
    withComponents =
      f:
      let
        isabelle = finalAttrs.finalPackage;
        base = "$out/${isabelle.dirname}";
        components = f isabelleComponents;
      in
      symlinkJoin {
        name = "isabelle-with-components-${isabelle.version}";
        paths = [ isabelle ] ++ (map (c: c.override { inherit isabelle; }) components);

        postBuild = ''
          rm $out/bin/*

          cd ${base}
          rm bin/*
          cp ${isabelle}/${isabelle.dirname}/bin/* bin/
          rm etc/components
          cat ${isabelle}/${isabelle.dirname}/etc/components > etc/components

          export HOME=$TMP
          bin/isabelle install $out/bin
          patchShebangs $out/bin
        ''
        + lib.concatMapStringsSep "\n" (c: ''
          echo contrib/${c.pname}-${c.version} >> ${base}/etc/components
        '') components;
      };
  };
})
