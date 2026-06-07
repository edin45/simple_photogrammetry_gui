FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Base Build Tools & CMake 3.28.3 Upgrade
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential git wget curl unzip nano pkg-config ninja-build && \
    wget https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.sh && \
    chmod +x cmake-3.28.3-linux-x86_64.sh && \
    ./cmake-3.28.3-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.28.3-linux-x86_64.sh

# 2. COLMAP Dependencies (Qt6 & MKL)
RUN apt-get install -y \
    libboost-program-options-dev libboost-graph-dev libboost-system-dev libeigen3-dev \
    libopenimageio-dev openimageio-tools libmetis-dev libgoogle-glog-dev libgtest-dev \
    libgmock-dev libsqlite3-dev libglew-dev qt6-base-dev libqt6opengl6-dev \
    libqt6openglwidgets6 libcgal-dev libceres-dev libsuitesparse-dev libcurl4-openssl-dev \
    libssl-dev libmkl-full-dev

# 3. OpenMVS Dependencies
RUN apt-get install -y \
    autoconf autoconf-archive automake libtool bison gfortran libxi-dev libx11-dev \
    libxft-dev libxtst-dev libxext-dev libxrandr-dev libxinerama-dev libxcursor-dev \
    xorg-dev libgl-dev libglu1-mesa-dev nasm libavcodec-dev libavformat-dev \
    libavutil-dev libswscale-dev libswresample-dev python3-venv

# 4. Flutter & AppImage Packaging Dependencies
RUN apt-get install -y clang libgtk-3-dev liblzma-dev fuse libfuse2

# 5. Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /workspace/flutter
ENV PATH="/workspace/flutter/bin:${PATH}"
RUN flutter config --enable-linux-desktop && \
    git config --global --add safe.directory /workspace/flutter

# 6. Install LinuxDeploy (Extracted to bypass Docker FUSE issues)
WORKDIR /workspace
RUN wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage && \
    chmod +x linuxdeploy-x86_64.AppImage && \
    ./linuxdeploy-x86_64.AppImage --appimage-extract