# nixpkgs' OpenMVS package does not expose its CUDA build option. Start with
# that maintained package and add only the CUDA compiler, libraries, and CMake
# settings. This keeps its source version and non-CUDA dependencies in nixpkgs.
{
  lib,
  openmvs,
  cudaPackages,
  autoAddDriverRunpath,
  cudaCapabilities,
}:

let
  # NVIDIA restricts which host compilers nvcc accepts. backendStdenv selects a
  # compatible compiler from the pinned nixpkgs revision instead of whichever
  # compiler happens to be installed on the host.
  openmvsWithCudaCompiler = openmvs.override {
    stdenv = cudaPackages.backendStdenv;
  };

  # Nix records compute capabilities with dots, such as "8.6". CMake expects
  # the same value without the dot, such as "86".
  cmakeCudaArchitectures = lib.concatStringsSep ";" (
    map cudaPackages.flags.dropDots cudaCapabilities
  );
in
openmvsWithCudaCompiler.overrideAttrs (oldAttrs: {
  pname = "openmvs-cuda";

  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
    autoAddDriverRunpath
    cudaPackages.cuda_nvcc
  ];

  buildInputs = oldAttrs.buildInputs ++ [
    cudaPackages.cuda_cudart
    cudaPackages.libcurand
  ];

  cmakeFlags = oldAttrs.cmakeFlags ++ [
    (lib.cmakeBool "OpenMVS_USE_CUDA" true)
    (lib.cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cmakeCudaArchitectures)
  ];

  # PipelineTest starts CUDA code, but Nix builds run in a sandbox without GPU
  # devices. Keep the CPU-only unit test here; exercise DensifyPointCloud with
  # real reconstruction input on an NVIDIA host after the package is built.
  checkPhase = ''
    runHook preCheck
    ctest --output-on-failure -E PipelineTest
    runHook postCheck
  '';
})
