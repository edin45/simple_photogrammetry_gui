{
  lib,
  stdenv,
  fetchFromGitHub,
  libjpeg,
  libpng,
  zlib,
}:

# PoissonRecon is not available in nixpkgs, so this builds the two executables
# used by the application directly from the pinned upstream source. `rev`
# selects an exact source revision and `hash` lets Nix verify that its contents
# have not changed.
stdenv.mkDerivation {
  pname = "poisson-recon";
  version = "18.76-unstable-2026-04-29";

  src = fetchFromGitHub {
    owner = "mkazhdan";
    repo = "PoissonRecon";
    rev = "262b0f539d404057d1f36e1adc07fc9388678899";
    hash = "sha256-hHEUMI3puhriVc3/5g9wq/CWQEJ7xtzvskov+oiuZcg=";
  };

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
