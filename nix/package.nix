# flake.nix loads this file with callPackage. It matches each name below to a
# package in the locked nixpkgs collection. Listing every input keeps the build
# independent of tools that happen to be installed on the host machine.
{
  lib,
  flutter344,
  makeWrapper,
  brush-splat,
  procps,
  python3,
  callPackage,
  gpuType,
  packageVariant,
  colmapPackage,
  openmvsPackage,
  mvsTexturingSource,
  mapmapSource,
  rayintSource,
  mveSource,
  poissonReconSource,
  fastDownscaler,
}:

let
  # nixpkgs supplies the other programs used below. These two use local build
  # definitions and source inputs declared by the flake.
  mvs-texturing = callPackage ./mvs-texturing.nix {
    inherit
      mvsTexturingSource
      mapmapSource
      rayintSource
      mveSource
      ;
  };
  poisson-recon = callPackage ./poisson-recon.nix { inherit poissonReconSource; };

  # decimateMesh.py imports PyMeshLab. Wrapping Python with this environment
  # makes that import available without changing the script.
  pythonEnv = python3.withPackages (pythonPackages: [ pythonPackages.pymeshlab ]);
in
# This nixpkgs helper fetches the Dart packages from pubspec.lock, builds the
# Flutter Linux application, and installs a launcher. Using it avoids keeping a
# separate hand-written Flutter build script in the Nix setup.
flutter344.buildFlutterApplication (finalAttrs: {
  pname = "simple-photogrammetry-gui-${packageVariant}";
  # Keep this value in sync with pubspec.yaml. Nix uses it in the package name.
  version = "1.1.0+1";

  # Copy the repository into Nix's isolated build directory without Git's
  # administrative files. pubspec.lock pins the Dart dependencies inside the
  # wider Nix build, just as flake.lock pins nixpkgs.
  src = lib.cleanSource ../.;
  autoPubspecLock = finalAttrs.src + "/pubspec.lock";

  # makeWrapper creates launch scripts with the environment variables and PATH
  # entries below. It also creates the decimateMesh Python launcher.
  nativeBuildInputs = [ makeWrapper ];

  # APPDIR tells the application where the helper programs live. The GPU type
  # matches the selected COLMAP and OpenMVS packages. procps supplies `killall`,
  # which the Cancel button uses to stop helper processes.
  extraWrapProgramArgs = ''
    --set APPDIR "$out" \
    --set SIMPLE_PHOTOGRAMMETRY_GPU_TYPE "${gpuType}" \
    --prefix PATH : ${lib.makeBinPath [ procps ]}
  '';

  postInstall = ''
    install -Dm644 simple_photogrammetry_gui.desktop \
      "$out/share/applications/simple_photogrammetry_gui.desktop"
    install -Dm644 app_icon.png \
      "$out/share/icons/hicolor/256x256/apps/app_icon.png"

    # The application was written for an AppImage and looks for its helper
    # programs below APPDIR/usr/bin. Recreate that layout with links to the Nix
    # packages instead of changing the existing Windows and AppImage paths.
    mkdir -p "$out/usr/bin/OpenMVS" "$out/usr/bin/brush"
    ln -s ${lib.getExe colmapPackage} "$out/usr/bin/colmap"
    ln -s ${lib.getExe brush-splat} "$out/usr/bin/brush/brush_app"
    ln -s ${lib.getExe mvs-texturing} "$out/usr/bin/texrecon"
    ln -s ${poisson-recon}/bin/PoissonRecon "$out/usr/bin/PoissonRecon"
    ln -s ${poisson-recon}/bin/SurfaceTrimmer "$out/usr/bin/SurfaceTrimmer"

    ln -s ${lib.getExe fastDownscaler} "$out/usr/bin/fast_downscaler"

    for program in InterfaceCOLMAP DensifyPointCloud ReconstructMesh; do
      ln -s "${openmvsPackage}/bin/$program" "$out/usr/bin/OpenMVS/$program"
    done

    install -Dm644 python/decimateMesh.py \
      "$out/share/simple-photogrammetry-gui/decimateMesh.py"
    makeWrapper ${lib.getExe pythonEnv} "$out/usr/bin/decimateMesh" \
      --add-flags "$out/share/simple-photogrammetry-gui/decimateMesh.py"
  '';

  meta = {
    description = "${packageVariant} build of the GUI for photogrammetry and Gaussian splatting";
    homepage = "https://github.com/edin45/simple_photogrammetry_gui";
    license = lib.licenses.gpl3Only;
    mainProgram = "simple_photogrammetry_gui";
    platforms = [ "x86_64-linux" ];
  };
})
