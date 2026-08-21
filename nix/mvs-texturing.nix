{
  lib,
  stdenv,
  cmake,
  eigen,
  libjpeg,
  libpng,
  libtiff,
  tbb,
  mvsTexturingSource,
  mapmapSource,
  rayintSource,
  mveSource,
}:

# mvs-texturing is not available in nixpkgs. Its normal CMake build downloads
# four projects while compiling, but Nix builds have no network access. The
# flake supplies every source before compilation; this recipe replaces the
# download file with four empty CMake targets.
stdenv.mkDerivation {
  pname = "mvs-texturing";
  version = "8.0-unstable-2026-03-11";

  src = mvsTexturingSource;

  postPatch = ''
    # This upstream file only defines network download targets. Keep the target
    # names, which other CMake files expect, without trying to download again.
    cp ${./mvs-texturing-dependencies.cmake} elibs/CMakeLists.txt

    # Put the fetched sources where the upstream build expects its downloads.
    # Files fetched through the Nix store are read-only. Make these private
    # build-directory copies writable because the upstream build edits them.
    cp -r ${mapmapSource} elibs/mapmap
    cp -r ${rayintSource} elibs/rayint
    cp -r ${mveSource} elibs/mve
    cp -r ${eigen}/include/eigen3 elibs/eigen
    chmod -R u+w elibs

    # Nix builds target a generic x86-64 CPU. Keeping -march=native would make
    # texrecon depend on whichever CPU executes the build.
    substituteInPlace CMakeLists.txt --replace-fail " -march=native" ""

    # CMake 4 removed compatibility with versions older than 3.5. The project
    # does not depend on the pre-3.5 policy behavior, so raise its declared floor.
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1)" \
      "cmake_minimum_required(VERSION 3.5)"
  '';

  # CMake is a tool used to produce the package. The libraries below become
  # part of the compiled program, which is why Nix records them separately.
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    libjpeg
    libpng
    libtiff
    tbb
  ];

  preBuild = ''
    # The replacement dependency file keeps upstream's target names, but its
    # empty targets no longer compile these two MVE libraries. Build them here
    # before texrecon tries to link against them.
    make -C ../elibs/mve/libs/util
    make -C ../elibs/mve/libs/mve
  '';

  meta = {
    description = "Texture large 3D reconstructions from registered images";
    homepage = "https://github.com/nmoehrle/mvs-texturing";
    license = lib.licenses.bsd3;
    mainProgram = "texrecon";
    platforms = lib.platforms.linux;
  };
}
