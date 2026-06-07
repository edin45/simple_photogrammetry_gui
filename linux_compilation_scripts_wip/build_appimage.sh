#!/bin/bash
set -e

# 1. Compile the Flutter GUI
cd /workspace/simple_photogrammetry_gui
flutter clean 
flutter pub get 
flutter build linux --release 

# 2. Stage the Flutter bundle into the AppDir
cp -r build/linux/x64/release/bundle/* /workspace/AppDir/usr/bin/

# 3. Stage the Desktop and Icon metadata
mkdir -p /workspace/AppDir/usr/share/applications
mkdir -p /workspace/AppDir/usr/share/icons/hicolor/256x256/apps
mkdir -p /workspace/AppDir/usr/share/pixmaps

cp app_icon.png /workspace/AppDir/usr/share/icons/hicolor/256x256/apps/
cp app_icon.png /workspace/AppDir/usr/share/pixmaps/
cp simple_photogrammetry_gui.desktop /workspace/AppDir/usr/share/applications/

# 4. Package the AppImage using the extracted LinuxDeploy AppRun
cd /workspace
LD_LIBRARY_PATH=/workspace/AppDir/usr/lib:$LD_LIBRARY_PATH \
./squashfs-root/AppRun \
    --appdir /workspace/AppDir \
    -d /workspace/AppDir/usr/share/applications/simple_photogrammetry_gui.desktop \
    --output appimage

echo "=== Packaging Complete! Your AppImage is ready. ==="