{
  description = "Simple GUI for photogrammetry and Gaussian splatting";

  # flake.lock records the exact nixpkgs revision used here. Builds therefore
  # keep using the same dependencies until someone deliberately updates the lock.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      # This package has only been defined and tested for 64-bit Linux. Naming
      # the platform here prevents Nix from advertising untested builds.
      system = "x86_64-linux";

      # These are the NVIDIA GPU generations supported by the existing Linux
      # build, plus compute capability 12.0 for current Blackwell GPUs. Limiting
      # the list keeps the CUDA build smaller than compiling for every GPU that
      # CUDA 12.9 supports.
      cudaCapabilities = [
        "7.5"
        "8.6"
        "8.9"
        "12.0"
      ];

      # Select the package collection for that platform. NVIDIA distributes the
      # CUDA toolkit under its own license, which nixpkgs classifies as unfree.
      # The opt-in below lets this flake build CUDA-enabled COLMAP and OpenMVS;
      # it does not install or configure the NVIDIA driver.
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          inherit cudaCapabilities;
        };
      };

      # callPackage reads nix/package.nix's argument list and supplies matching
      # packages from the locked nixpkgs revision. The explicit capability list
      # is also passed to the local OpenMVS CUDA override.
      simple-photogrammetry-gui = pkgs.callPackage ./nix/package.nix {
        inherit cudaCapabilities;
      };
    in
    {
      # `nix build` selects this default package.
      packages.${system}.default = simple-photogrammetry-gui;

      # `nix flake check` builds everything listed under `checks`. Pointing the
      # check at the real package gives developers and CI the same single test.
      checks.${system}.default = simple-photogrammetry-gui;

      # Copy the package's Flutter tools and Linux libraries into the development
      # shell instead of maintaining a second dependency list. act is added only
      # for running the GitHub Actions workflow in a local Docker container.
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ simple-photogrammetry-gui ];
        packages = [ pkgs.act ];
      };

      # `nix fmt` uses nixpkgs' Nix formatter. Pinning it through flake.lock
      # gives contributors the same formatting rules.
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
