# simple_photogrammetry_gui

## Usage:

Windows Users: You will be prompted to download missing dependencies, click **Install (Cuda)** if you have an Nvidia GPU, and if not, click **Install (No Cuda)**.

Linux Users: All dependencies are packaged in the .AppImage - so this step does not apply

Then click "Select Image Folder" to select the folder containing the images.

Aftewards click **Select Output Folder** to select the folder where the result should be stored (There should be plenty of disk space in the location of the output folder).

![alt text](https://raw.githubusercontent.com/edin45/simple_photogrammetry_gui/master/readme_imgs/scanning_screen_v1.1.2.png)

Lastly, click start. The finished result will be in the output folder with the name: **textured.obj**

## Building:

### Nix

The Nix build supports x86-64 Linux with an NVIDIA GPU. It includes CUDA builds
of COLMAP and OpenMVS, matching the existing Linux build, together with the
other command-line programs used by the reconstruction pipeline. Install a
current version of [Nix](https://nixos.org/download/) and an NVIDIA driver that
supports CUDA 12.9 before using these commands. Nix supplies the CUDA runtime,
but the operating system must supply the graphics driver.

Build and run the application with:

```sh
nix build
./result/bin/simple_photogrammetry_gui
```

`nix build` creates the `result` link and packages the command-line programs in
the locations the application expects. To work on the Flutter source, enter a
temporary shell containing Flutter and the build libraries:

```sh
nix develop
flutter run -d linux
```

To load the development shell automatically, install
[direnv](https://direnv.net/docs/installation.html), add its hook to your shell,
review `.envrc`, and approve it once:

```sh
direnv allow
```

`.envrc` contains only `use flake`, so it loads the same pinned tools as
`nix develop`. Direnv requires approval because `.envrc` is shell code from the
checkout.

### Windows:
    ```
    git clone https://github.com/edin45/simple_photogrammetry_gui.git
    cd simple_photogrammetry_gui
    flutter clean
    flutter pub get
    flutter build windows --release
    ```

   then alongside the simple_photogrammetry_gui.exe (in the build/windows/runner/Release folder) put your desired (compiled!) version of openmvs as a zip file called openmvs.zip (zip the contents of the folder not the folder itself, or it will not work).
   
   Along with zip files of:
  
   - decimateMesh.exe (compiled from python/decimateMesh.py using command: pyinstaller --onefile decimateMesh.py --collect-all pymeshlab)
   - resizeImages.exe (compiled from python/resizeImages.py using command: pyinstaller --onefile resizeImages.py)
   - texrecon.exe (is in the folder mvs-texturing)

### Linux:

This is experimental - so it could have issues,
but if it works it should compile all dependencies, collect them and set them up, and finally package everything into a nice .AppImage
    
    ```
    git clone https://github.com/edin45/simple_photogrammetry_gui.git
    cd simple_photogrammetry_gui/linux_compilation_scripts_wip
    docker build -t simple_photogrammetry_gui_box .
    docker run -it -v $(pwd)/..:/workspace/simple_photogrammetry_gui simple_photogrammetry_gui_box /bin/bash
    cd /workspace
    cp simple_photogrammetry_gui/linux_compilation_scripts_wip/compile_dependecies.sh .
    cp simple_photogrammetry_gui/linux_compilation_scripts_wip/build_appimage.sh .
    ./compile_dependecies.sh
    ./build_appimage.sh
    cp *.AppImage simple_photogrammetry_gui/
    ```
 
## Based on:

 OpenMVS: https://github.com/cdcseacave/openMVS
 
 Colmap: https://colmap.github.io/
 
 mvs-texturing: https://github.com/nmoehrle/mvs-texturing

 PoissonRecon: https://github.com/mkazhdan/PoissonRecon
 
 Brush: https://github.com/ArthurBrussee/brush
