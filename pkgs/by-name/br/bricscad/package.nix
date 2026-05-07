{
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  requireFile,
  copyDesktopItems,

  alsa-lib,
  glib,
  libGL,
  libGLU,
  gtk3,
  libsecret,
  libsm,
  libxcrypt-legacy,
  libxkbcommon,
  libxkbfile,
  libxml2_13,
  libxshmfence,
  nss,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-wm,
  libnsl,
  qt6,
  libjpeg8,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bricscad";
  version = "26.2.04-1";
  src = requireFile {
    name = "BricsCAD-V${finalAttrs.version}-en_US-amd64.tar.gz";
    message = "couldn't find it cheif";
    hash = "sha256-Tbr7W2K2JUnPBJCgcc6wp+EKqEH2kkUFy4SyIFGXYvI=";
  };
  sourceRoot = ".";

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    # qt6.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    glib
    libGL
    libGLU
    gtk3
    libsecret
    libsm
    libxcrypt-legacy
    libxkbcommon
    libxkbfile
    libxml2_13
    nss
    libxcb-cursor
    libxcb-keysyms
    libxcb-wm
    libnsl
    libjpeg8
    libxshmfence

    # qt6.qtbase
    # qt6.qt3d
    # qt6.qtwebchannel
    # qt6.qtsvg
    # qt6.qtdeclarative
    qt6.qtserialport
    # qt6.qtpositioning
    # qt6.qtwebengine
    # qt6.qtquicktimeline
    # qt6.qtwayland
    # qt6.qtscxml
  ];

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    # Remove all qt6 packages, use nix provided ones instead
    # rm libQt6*.so.6*
    # rm -rf Qt Qt3D Qt5Compat QtQml QtQuick QtTest QtWebChannel QtWebEngine

    mkdir -p $out/opt/bricscad
    cp -r . $out/opt/bricscad

    # wrapQtApp $out/opt/bricscad/bricscad

    # Wrap various programs
    mkdir -p $out/bin
    ln -s $out/opt/bricscad/bricscad.sh $out/bin/bricscad
    ln -s $out/opt/bricscad/pstyle_app.sh $out/bin/pstyle_app
    ln -s $out/opt/bricscad/profilemanager_app.sh $out/bin/profilemanager_app
    ln -s $out/opt/bricscad/standards_app.sh $out/bin/standards_app

    runHook postInstall
  '';

  # autoPatchelfHook settings
  appendRunpaths = [ "${placeholder "out"}/opt/bricscad" ];
  autoPatchelfIgnoreMissingDeps = [
    # Dependencies of python3.9 that we shouldn't be used
    "libnsl.so.2"

    # bricscad package some libraries as `.tx` elf libraries. auto-patchelf
    # doesn't automatically find them, so we get them by unconditionally adding
    # `$out/opt/bricscad` to the rpath of all elf files we find, and getting
    # them that way
    "*.tx"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "bricscad";
      comment = "Professional DWG CAD application";
      genericName = "BricsCAD";
      desktopName = "BricsCAD V26";
      exec = "bricscad %F";
      icon = "bricscad";
      terminal = false;
      startupNotify = true;
      categories = [ "Graphics" ];
      mimeTypes = [ "application/x-bricscad" ];
    })
  ];

  meta = {
    description = "Professional DWG CAD application";
    homepage = "https://bricscad.octave.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ sempiternal-aurora ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
