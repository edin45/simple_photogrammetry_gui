# simple_photogrammetry_gui

## Usage:

When first opening, open the application as adminstrator, since it needs the adminstrator rights to install all dependencies.

Click on the Install option you'd like to use, click "Install (Cuda)" if you have a nvidia gpu and if not click "Install (No Cuda)"

Once the dependencies finished installing click "Select Image Folder" to select the folder containing the images

then click "Select Output Folder" to select the folder where the result should be stored (There should be plenty of disk space in the loaction of the output folder).

lastly click start, the finished result will be in the output folder with the name: "textured.obj"

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
