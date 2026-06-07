#!/bin/bash
set -e

# 1. Compile COLMAP 4.0.4
git clone --depth 1 --branch 4.0.4 https://github.com/colmap/colmap.git
cd colmap
mkdir build && cd build
cmake .. -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/workspace/install \
    -DCUDA_ENABLED=ON \
    -DCMAKE_CUDA_ARCHITECTURES="75;86;89"
ninja -j8
ninja install
cd /workspace

# 2. Setup vcpkg
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh -disableMetrics
export VCPKG_ROOT=$(pwd)
cd /workspace

# 3. Compile OpenMVS via vcpkg
git clone --recurse-submodules https://github.com/cdcseacave/openMVS.git
cd openMVS
mkdir make && cd make
cmake .. -GNinja \
    -DCMAKE_TOOLCHAIN_FILE=/workspace/vcpkg/scripts/buildsystems/vcpkg.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/workspace/install \
    -DOpenMVS_USE_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES="75;86;89"
ninja
ninja install
cd /workspace

# 4. Stage Binaries and Shared Libraries into AppDir
mkdir -p /workspace/AppDir/usr/bin
mkdir -p /workspace/AppDir/usr/lib

# Copy everything (OpenMVS executables will land inside AppDir/usr/bin/OpenMVS)
cp -r /workspace/install/bin/* /workspace/AppDir/usr/bin/

# The "Funky" Library Fix: Stage .so files
cp /workspace/install/lib/libonnxruntime.so.1 /workspace/AppDir/usr/lib/
cp /workspace/install/lib/OpenMVS/*.so /workspace/AppDir/usr/lib/
cp -r /workspace/install/lib/OpenMVS /workspace/AppDir/usr/lib/

# --- THE CRITICAL SYMLINK FIX ---
# 1. Move the OpenMVS executables OUT of the subfolder into the main /usr/bin/ folder
mv /workspace/AppDir/usr/bin/OpenMVS/* /workspace/AppDir/usr/bin/

# 2. Re-enter the now-empty OpenMVS folder and create symlinks pointing back to the parent folder
cd /workspace/AppDir/usr/bin/OpenMVS
ln -s ../CreateStructure CreateStructure
ln -s ../DensifyPointCloud DensifyPointCloud
ln -s ../ExtractKeyframes ExtractKeyframes
ln -s ../InterfaceCOLMAP InterfaceCOLMAP
ln -s ../InterfaceMVSNet InterfaceMVSNet
ln -s ../InterfaceMetashape InterfaceMetashape
ln -s ../InterfacePolycam InterfacePolycam
ln -s ../ReconstructMesh ReconstructMesh
ln -s ../RefineMesh RefineMesh
ln -s ../TextureMesh TextureMesh
ln -s ../TransformScene TransformScene
cd /workspace
# ---------------------------------

echo "=== C++ Engines Compiled and Staged successfully! ==="