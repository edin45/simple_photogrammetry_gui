{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  eigen,
  libjpeg,
  libpng,
  libtiff,
  tbb,
}:

# mvs-texturing is not available in nixpkgs. Its normal CMake build downloads
# four projects while compiling, but Nix builds have no network access. Fetch
# each source ahead of time, then replace the download file with four empty
# CMake targets. Every `rev` selects an exact source revision; its `hash` lets
# Nix verify that the downloaded contents have not changed.
let
  mapmap = fetchFromGitHub {
    owner = "dthuerck";
    repo = "mapmap_cpu";
    rev = "fa526e0963ca3e431a02aa7b9e87b85ba8a8e304";
    hash = "sha256-CFMLjs7yorJ2a9/LNCzq9M98zna4KPX7EoP4sTZQ+Vo=";
  };
  rayint = fetchFromGitHub {
    owner = "nmoehrle";
    repo = "rayint";
    rev = "b62c8905f6dd11a179128517e814e0e00f9bb809";
    hash = "sha256-rXzvXdBGwq/411uqXBoVrImTmdIgWlmGYlRn+/iXg2c=";
  };
  mve = fetchFromGitHub {
    owner = "nmoehrle";
    repo = "mve";
    rev = "91c0f3fde0781399b2fe872d8e52e4899274a84a";
    hash = "sha256-9JuMuoXQwuot5VO0j2TA76r7viwWFGiD/MaZaoycYf0=";
  };
in
stdenv.mkDerivation {
  pname = "mvs-texturing";
  version = "8.0-unstable-2026-03-11";

  src = fetchFromGitHub {
    owner = "nmoehrle";
    repo = "mvs-texturing";
    rev = "f3374298ac959cb5afe47a14e4d35d2ac7fbdbb1";
    hash = "sha256-qo9rcMC0oym6kDjY7ceLrWQDha5759k3TyaREVEO2gg=";
  };

  postPatch = ''
    # This upstream file only defines network download targets. Keep the target
    # names, which other CMake files expect, without trying to download again.
    cp ${./mvs-texturing-dependencies.cmake} elibs/CMakeLists.txt

    # Put the fetched sources where the upstream build expects its downloads.
    # Files fetched through the Nix store are read-only. Make these private
    # build-directory copies writable because the upstream build edits them.
    cp -r ${mapmap} elibs/mapmap
    cp -r ${rayint} elibs/rayint
    cp -r ${mve} elibs/mve
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
