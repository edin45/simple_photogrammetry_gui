# simple_photogrammetry_gui

## Usage:

When first opening, open the application as administrator since it needs administrator rights to install all dependencies.

![alt text](https://raw.githubusercontent.com/edin45/simple_photogrammetry_gui/master/readme_imgs/run_as_adminstrator.jpg)

Click on the Install option you'd like to use, click "Install (Cuda)" if you have an Nvidia GPU, and if not, click "Install (No Cuda)."

![alt text](https://raw.githubusercontent.com/edin45/simple_photogrammetry_gui/master/readme_imgs/install_dependencies.jpg)

Once the dependencies finish installing, click "Select Image Folder" to select the folder containing the images.

Then click "Select Output Folder" to select the folder where the result should be stored (There should be plenty of disk space in the location of the output folder).

![alt text](https://raw.githubusercontent.com/edin45/simple_photogrammetry_gui/master/readme_imgs/scanning_screen.jpg)

Lastly, click start. The finished result will be in the output folder with the name: "textured.obj"

## Building:

### Windows:
    ```
    git clone https://github.com/edin45/simple_photogrammetry_gui.git
    cd simple_photogrammetry_gui
    flutter clean
    flutter pub get
    flutter build windows --release
    ```

    then in the build/windows/runner/Release put your desired version of openmvs as a zip file called openmvs.zip
