cmake_minimum_required(VERSION 3.10)
project(FastDownscaler)

# Require C++17 for std::filesystem
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Force Release mode if not specified (this strips debug symbols and enables basic optimizations)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

add_executable(fast_downscaler main.cpp)

# Apply aggressive, compiler-specific speed optimizations
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    # -O3: Maximum speed optimizations
    # -march=native: Allows compiler to use your specific 16-core CPU's advanced vector instructions
    # -ffast-math: Speeds up floating point math (great for image resizing)
    target_compile_options(fast_downscaler PRIVATE -O3 -march=x86-64-v2 -ffast-math)
elseif(MSVC)
    # Windows/Visual Studio equivalent flags
    # /O2: Maximize speed
    # /arch:AVX2: Enable Advanced Vector Extensions
    # /fp:fast: Fast floating point math
    target_compile_options(fast_downscaler PRIVATE /O2 /arch:AVX2 /fp:fast)
endif()
