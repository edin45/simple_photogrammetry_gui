{
  lib,
  stdenv,
  libjpeg,
  libpng,
  zlib,
  poissonReconSource,
}:

# PoissonRecon is not available in nixpkgs, so this builds the two executables
# used by the application directly from the source input pinned by the flake.
stdenv.mkDerivation {
  pname = "poisson-recon";
  version = "18.76-unstable-2026-04-29";

  src = poissonReconSource;

  buildInputs = [
    libjpeg
    libpng
    zlib
  ];

  # These C++ sources can compile in parallel. Letting Make use the available
  # CPU cores shortens the build without changing its output.
  enableParallelBuilding = true;

  # The upstream repository contains more programs than this application uses.
  # Building only these targets saves time and avoids packaging unused tools.
  buildFlags = [
    "poissonrecon"
    "surfacetrimmer"
  ];

  # Install only the two programs referenced by nix/package.nix. Nix packages
  # write their final files below $out rather than into the host system.
  installPhase = ''
    runHook preInstall
    install -Dm755 Bin/Linux/PoissonRecon "$out/bin/PoissonRecon"
    install -Dm755 Bin/Linux/SurfaceTrimmer "$out/bin/SurfaceTrimmer"
    runHook postInstall
  '';

  meta = {
    description = "Poisson surface reconstruction tools";
    homepage = "https://github.com/mkazhdan/PoissonRecon";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
