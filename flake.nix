{
  description = "Simple GUI for photogrammetry and Gaussian splatting";

  # flake.lock records the exact revision and content hash for every input.
  # Builds therefore keep using the same sources until someone deliberately
  # updates an input.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    mvsTexturingSource = {
      url = "github:nmoehrle/mvs-texturing/f3374298ac959cb5afe47a14e4d35d2ac7fbdbb1";
      flake = false;
    };
    mapmapSource = {
      url = "github:dthuerck/mapmap_cpu/fa526e0963ca3e431a02aa7b9e87b85ba8a8e304";
      flake = false;
    };
    rayintSource = {
      url = "github:nmoehrle/rayint/b62c8905f6dd11a179128517e814e0e00f9bb809";
      flake = false;
    };
    mveSource = {
      url = "github:nmoehrle/mve/91c0f3fde0781399b2fe872d8e52e4899274a84a";
      flake = false;
    };
    poissonReconSource = {
      url = "github:mkazhdan/PoissonRecon/262b0f539d404057d1f36e1adc07fc9388678899";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      mvsTexturingSource,
      mapmapSource,
      rayintSource,
      mveSource,
      poissonReconSource,
      ...
    }:
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

      openmvsCuda = pkgs.callPackage ./nix/openmvs-cuda.nix {
        inherit cudaCapabilities;
      };

      # Add fast_downscaler - a simple tool built in CPP that scales down the images,
      # before they are fed into the 3d scanning pipeline

      fastDownscaler = pkgs.stdenv.mkDerivation {
        pname = "fast_downscaler";
        version = "1.0.0";
        src = ./CPP/ImageDownscaler; 

        nativeBuildInputs = [ pkgs.cmake ];

        # Nix automatically runs cmake and make. We just need to tell it 
        # where to put the finished binary.
        installPhase = ''
          mkdir -p $out/bin
          cp fast_downscaler $out/bin/
        '';
      };

      # The package assembly is shared, while each adapter supplies matching
      # application policy and native dependencies at this seam.
      mkSimplePhotogrammetryGui =
        {
          gpuType,
          packageVariant,
          colmapPackage,
          openmvsPackage,
        }:
        pkgs.callPackage ./nix/package.nix {
          inherit
            gpuType
            packageVariant
            colmapPackage
            openmvsPackage
            mvsTexturingSource
            mapmapSource
            rayintSource
            mveSource
            poissonReconSource
            ;
        };

      cudaPackage = mkSimplePhotogrammetryGui {
        gpuType = "cuda";
        packageVariant = "cuda";
        colmapPackage = pkgs.colmapWithCuda;
        openmvsPackage = openmvsCuda;
      };

      cpuPackage = mkSimplePhotogrammetryGui {
        gpuType = "cpu";
        packageVariant = "cpu";
        colmapPackage = pkgs.colmap;
        openmvsPackage = pkgs.openmvs;
      };

      # Building both variants would not catch a launcher wired to the wrong
      # application mode. It would also miss a CPU OpenMVS package that gained
      # a driver dependency. Check both distribution boundaries explicitly.
      variantPolicyCheck =
        pkgs.runCommand "simple-photogrammetry-gui-variant-policy"
          {
            nativeBuildInputs = [ pkgs.binutils ];
          }
          ''
            grep -aF 'SIMPLE_PHOTOGRAMMETRY_GPU_TYPE=cpu' \
              ${cpuPackage}/bin/simple_photogrammetry_gui >/dev/null
            grep -aF 'SIMPLE_PHOTOGRAMMETRY_GPU_TYPE=cuda' \
              ${cudaPackage}/bin/simple_photogrammetry_gui >/dev/null

            if readelf -d ${cpuPackage}/usr/bin/OpenMVS/DensifyPointCloud \
              | grep -F 'Shared library: [libcuda.so.1]'; then
              echo 'The CPU OpenMVS package unexpectedly links libcuda.so.1.' >&2
              exit 1
            fi

            readelf -d ${cudaPackage}/usr/bin/OpenMVS/DensifyPointCloud \
              | grep -F 'Shared library: [libcuda.so.1]' >/dev/null

            touch "$out"
          '';
    in
    {
      packages.${system} = {
        # Keep the CUDA package as the default offered by this NVIDIA-focused
        # pull request. The named outputs make both distributions explicit.
        default = cudaPackage;
        cuda = cudaPackage;
        cpu = cpuPackage;
      };

      # `nix flake check` builds both distributions, including their distinct
      # COLMAP and OpenMVS dependency graphs.
      checks.${system} = {
        cuda = cudaPackage;
        cpu = cpuPackage;
        variant-policy = variantPolicyCheck;
      };

      # Copy the package's Flutter tools and Linux libraries into the development
      # shell instead of maintaining a second dependency list. act is added only
      # for running the GitHub Actions workflow in a local Docker container.
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ cudaPackage ];
        packages = [ pkgs.act ];
      };

      # `nix fmt` uses nixpkgs' Nix formatter. Pinning it through flake.lock
      # gives contributors the same formatting rules.
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
