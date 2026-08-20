# Maintaining the Nix build

This guide explains why the project has a Nix build, how the files fit
together, and what can break. It assumes no prior knowledge of Nix. Build and
usage commands remain in the [README](../README.md#nix).

## What Nix does for this project

Nix is a package manager and build tool. A Nix recipe lists the source code,
build tools, and libraries needed to produce a package. Nix performs the build
in an isolated directory instead of using whichever versions happen to be
installed on the developer's computer.

This project needs more than Flutter. The application starts COLMAP, OpenMVS,
Brush, mvs-texturing, PoissonRecon, and a Python mesh-decimation script while it
runs. The Nix package builds or downloads those programs and places them where
the application expects to find them. A developer and GitHub Actions can then
check the same package with the same command.

The term *flake* refers to the Nix entry point, `flake.nix`, together with its
dependency lock file, `flake.lock`. The lock file records the exact revision of
nixpkgs, Nix's main package collection. The recipes for mvs-texturing and
PoissonRecon also record exact source revisions and hashes because those two
programs are not supplied by nixpkgs. An unchanged checkout therefore keeps
using the same dependency versions.

## Files and responsibilities

- [`flake.nix`](../flake.nix) defines the public commands for building,
  developing, formatting, and checking. Keeping these entry points together
  gives local and CI builds the same recipe.
- [`flake.lock`](../flake.lock) records the exact nixpkgs revision. Update it
  only when dependency updates are intended, then run the checks below.
- [`nix/package.nix`](../nix/package.nix) builds the Flutter application and
  assembles its helper programs. The extra directory layout exists because the
  application was written to find those programs inside an AppImage-style
  directory.
- [`nix/openmvs-cuda.nix`](../nix/openmvs-cuda.nix) adds CUDA to nixpkgs'
  OpenMVS package. Nixpkgs already supplies a CUDA variant of COLMAP, but its
  OpenMVS package has no equivalent switch.
- [`nix/mvs-texturing.nix`](../nix/mvs-texturing.nix) and
  [`nix/poisson-recon.nix`](../nix/poisson-recon.nix) build the two programs
  missing from nixpkgs. Their sources must be fetched and verified before Nix
  enters the network-isolated compilation step.
- [`.github/workflows/nix.yml`](../.github/workflows/nix.yml) runs the package
  check on GitHub.
- [`.envrc`](../.envrc) optionally asks direnv to enter the same development
  shell as `nix develop`. The generated `.direnv` directory is ignored because
  it contains machine-local cache files and Nix store links.

## CUDA support

The existing Linux build compiles both COLMAP and OpenMVS with NVIDIA CUDA.
The Nix build does the same. CUDA lets those programs move suitable numerical
work from the CPU to an NVIDIA GPU.

NVIDIA assigns each GPU generation a *compute capability*. The list in
`flake.nix` tells the CUDA compiler which generations to include in the
programs. Capabilities 7.5, 8.6, and 8.9 match the existing Linux build; 12.0
supports current Blackwell GPUs. Adding a capability supports another GPU
generation but makes compilation take longer and produces larger binaries.

Nixpkgs marks the CUDA toolkit as unfree because NVIDIA distributes it under
the CUDA license rather than an open-source license. `flake.nix` opts into
those packages so `nix build` does not depend on a contributor's personal Nix
settings. The package contains the CUDA runtime but not the NVIDIA driver. The
driver belongs to the host operating system and must support the packaged CUDA
12.9 runtime.

GitHub's runners do not have NVIDIA GPUs. CI can compile the CUDA sources, link
the CUDA libraries, and run tests that do not need a GPU. The OpenMVS pipeline
test is excluded inside the Nix sandbox because it starts CUDA code without a
GPU device. Before merging a CUDA packaging change, run the CUDA check and a
reconstruction on an NVIDIA machine as described below.

## How the build can fail

Pinning prevents dependency versions from changing by accident, but it does not
make the build maintenance-free. Failures fall into three groups:

1. Application code can start needing a file, program, or build step that the
   Nix recipe does not provide.
2. A deliberate update to `flake.lock` or a pinned source revision can expose
   an upstream change in package names, dependencies, or build instructions.
3. Services outside the lock file can change. GitHub can update its
   `ubuntu-latest` runner image. A GitHub Action's major-version tag can move to
   a new release, and the Nix installer can install a newer Nix version. Nix can
   also lose access to a cached package or source file needed by the build.

Pull-request and `master` push checks catch the first two groups when repository
code changes. The scheduled check exercises the third group during weeks with
no commits.

## Why the workflow runs every week

The schedule in [`.github/workflows/nix.yml`](../.github/workflows/nix.yml) runs
at 05:17 UTC every Monday. The non-zero minute avoids GitHub's busiest
scheduling time at the start of an hour.

The scheduled run checks the locked package on a new GitHub runner. It can
reveal a changed runner image, Action update, Nix installer change, or a build
input that Nix can no longer obtain. Nix normally uses ready-built packages from
its caches, so the job does not download and test every original source file. It
also does not update `flake.lock` or try a newer nixpkgs revision.

GitHub reads the schedule only from the repository's default branch. In a public
repository, GitHub also disables scheduled workflows after 60 days without
repository activity. If the weekly run disappears, re-enable the workflow on
the **Actions** page and use its **Run workflow** button to check it immediately.

Failures appear on pull requests and in the repository's **Actions** page. For
pull requests, pushes, and manual runs, GitHub notifies the person who started
the run if that person has enabled Actions notifications. Scheduled runs have
no person starting them, so GitHub assigns their notifications to the person who
last changed the cron line. This makes that person the owner of the weekly check.

Each maintainer who starts workflow runs should open GitHub's
[notification settings](https://github.com/settings/notifications), find
**System > Actions**, choose email or web notifications, and select **Only
notify for failed workflows**. The workflow does not send messages through a
separate email or chat service.

## Local checks

Run the package check from the repository root:

```sh
nix flake check --print-build-logs
```

On a machine with an NVIDIA GPU, first confirm that the driver's management
tool can see it:

```sh
nvidia-smi
```

This is only a first check. `nvidia-smi` can still work when the part of the
driver used by CUDA programs needs recovery.

After `nix build`, check that both programs were compiled with CUDA support:

```sh
./result/usr/bin/colmap -h
./result/usr/bin/OpenMVS/DensifyPointCloud --help
```

COLMAP includes `with CUDA` in its version line. OpenMVS lists its
`--cuda-device` option. These messages describe features compiled into the
programs; they do not prove that either program can use the installed GPU.

The following small check makes COLMAP initialize CUDA. It does not need any
photographs because GPU initialization happens before COLMAP scans the image
directory:

```sh
cuda_test_dir="$(mktemp -d)"
mkdir "$cuda_test_dir/images"
./result/usr/bin/colmap feature_extractor \
  --database_path "$cuda_test_dir/database.db" \
  --image_path "$cuda_test_dir/images" \
  --FeatureExtraction.use_gpu 1 \
  --FeatureExtraction.gpu_index 0
```

The check must get past CUDA device creation without a `CheckCudaDevice` error.
The temporary directory can be deleted afterwards. If the command reports an
unknown CUDA error even though `nvidia-smi` works, inspect the operating
system's NVIDIA driver logs. A driver fault can require a reboot before any
CUDA program, including a correctly packaged one, can use the GPU.

OpenMVS starts its CUDA work while densifying a real scene, so its live test
needs reconstruction input. Run a small reconstruction through the application
and confirm that it completes the **Densifying Point Cloud** step. This also
tests the hand-off between COLMAP, OpenMVS, and the application, which isolated
command checks cannot cover.

To exercise the GitHub Actions workflow itself, start Docker and run `act` from
the Nix development shell. `act` creates a local container that imitates
GitHub's Linux runner. Its first run downloads a large container image and an
empty container must download the Nix build dependencies.

```sh
nix develop --command act pull_request --job package \
  --container-architecture linux/amd64 \
  -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

`--container-architecture linux/amd64` matches the x86-64 Linux system defined
in `flake.nix`, including when `act` runs on an ARM computer. `-P` tells `act`
which Docker image to use for the workflow's `ubuntu-latest` label; the selected
image contains the tools needed to install Nix. The container is still an
approximation of GitHub's runner, so the hosted workflow remains the final
check.

## Comments in the Nix and workflow files

When changing a non-obvious setting, update its nearby comment. The comment
should state why the setting exists and name the failure it prevents. A comment
that only restates the Nix or YAML syntax does not give the next maintainer the
context needed to judge a change.
