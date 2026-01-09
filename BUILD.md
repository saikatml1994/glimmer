# Building Glimmer Static Library for Linux

This document provides instructions for building the Glimmer library as a static library on Linux systems.

## Prerequisites

### Required Tools

- **CMake** (version 3.15 or higher)
- **GCC or Clang** compiler with C++20 support
- **Make** or **Ninja** build system

Install on Ubuntu/Debian:
```bash
sudo apt update
sudo apt install cmake build-essential
```

Install on Fedora/RHEL:
```bash
sudo dnf install cmake gcc-c++ make
```

Install on Arch Linux:
```bash
sudo pacman -S cmake base-devel
```

### Optional Dependencies

For full functionality, you may need:
- **FreeType** - Font rendering library
- **OpenGL** - Graphics rendering
- **GLFW3** - Window management (if using GLFW backend)

Install optional dependencies on Ubuntu/Debian:
```bash
sudo apt install libfreetype6-dev libglfw3-dev libgl1-mesa-dev
```

## Quick Build

### Using the Build Script (Recommended)

The easiest way to build is using the provided build script:

```bash
cd /home/saikat/glimmer
./build.sh
```

This will build the library in **Release** mode and create `libglimmer.a` in the `staticlib/` directory.

### Build Script Options

```bash
./build.sh [options]

Options:
  -h, --help              Show help message
  -d, --debug             Build in Debug mode (default: Release)
  -c, --clean             Clean build directory before building
  --no-svg                Disable SVG support
  --no-images             Disable image support
  --no-richtext           Disable rich text support
  --no-plots              Disable plots support
  --enable-nfdext         Enable nfd-extended library for file dialogs
```

### Examples

Build in debug mode:
```bash
./build.sh --debug
```

Clean build with SVG and images disabled:
```bash
./build.sh --clean --no-svg --no-images
```

Build with file dialog support enabled:
```bash
./build.sh --enable-nfdext
```

## Manual Build with CMake

If you prefer to use CMake directly:

### 1. Create Build Directory

```bash
cd /home/saikat/glimmer
mkdir -p build
cd build
```

### 2. Configure with CMake

**Release build:**
```bash
cmake -DCMAKE_BUILD_TYPE=Release ..
```

**Debug build:**
```bash
cmake -DCMAKE_BUILD_TYPE=Debug ..
```

**With custom options:**
```bash
cmake -DCMAKE_BUILD_TYPE=Release \
      -DGLIMMER_DISABLE_SVG=OFF \
      -DGLIMMER_DISABLE_IMAGES=OFF \
      -DGLIMMER_DISABLE_RICHTEXT=OFF \
      -DGLIMMER_DISABLE_PLOTS=OFF \
      -DGLIMMER_ENABLE_NFDEXT=ON \
      ..
```

### 3. Build

```bash
make -j$(nproc)
```

Or use Ninja for faster builds:
```bash
cmake -GNinja ..
ninja
```

### 4. Install (Optional)

```bash
sudo make install
```

This will install:
- Library: `/usr/local/lib/libglimmer.a`
- Headers: `/usr/local/include/glimmer/`

## CMake Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `GLIMMER_DISABLE_SVG` | OFF | Disable SVG rendering support (excludes lunasvg) |
| `GLIMMER_DISABLE_IMAGES` | OFF | Disable image loading support (excludes stb_image) |
| `GLIMMER_DISABLE_RICHTEXT` | OFF | Disable rich text rendering |
| `GLIMMER_DISABLE_PLOTS` | OFF | Disable plotting/graph library integration |
| `GLIMMER_ENABLE_NFDEXT` | OFF | Enable nfd-extended for native file dialogs |

## Output

After successful build, you will find:

```
staticlib/
└── libglimmer.a    # Static library
```

## Using the Library

### 1. Link Against the Static Library

In your project's CMakeLists.txt:

```cmake
# Add Glimmer include directories
include_directories(/home/saikat/glimmer)
include_directories(/home/saikat/glimmer/src)
include_directories(/home/saikat/glimmer/src/libs/inc)

# Link against the static library
add_executable(myapp main.cpp)
target_link_libraries(myapp 
    /home/saikat/glimmer/staticlib/libglimmer.a
    pthread
    dl
    m
)

# If using OpenGL/GLFW
find_package(OpenGL REQUIRED)
find_package(glfw3 REQUIRED)
target_link_libraries(myapp OpenGL::GL glfw)
```

### 2. Using with GCC/Clang Directly

```bash
g++ -std=c++20 main.cpp \
    -I/home/saikat/glimmer \
    -I/home/saikat/glimmer/src \
    -I/home/saikat/glimmer/src/libs/inc \
    -L/home/saikat/glimmer/staticlib \
    -lglimmer -lpthread -ldl -lm \
    -o myapp
```

### 3. Include in Your Code

```cpp
#include <glimmer.h>

int main() {
    auto& config = glimmer::GetUIConfig(true);
    // ... your code
    return 0;
}
```

## Troubleshooting

### Missing C++20 Support

If you get compiler errors about C++20 features:
```bash
# Update GCC (requires GCC 10+)
sudo apt install gcc-10 g++-10
export CC=gcc-10
export CXX=g++-10
```

### CMake Version Too Old

```bash
# Install newer CMake from snap
sudo snap install cmake --classic
```

### Missing FreeType Headers

```bash
sudo apt install libfreetype6-dev
```

### Build Errors

Clean and rebuild:
```bash
./build.sh --clean
```

Or manually:
```bash
rm -rf build staticlib/libglimmer.a
mkdir build && cd build
cmake ..
make clean
make -j$(nproc)
```

## Verify Build

Check that the library was created:

```bash
ls -lh /home/saikat/glimmer/staticlib/libglimmer.a
```

Check symbols in the library:

```bash
nm /home/saikat/glimmer/staticlib/libglimmer.a | grep glimmer
```

Check library information:

```bash
file /home/saikat/glimmer/staticlib/libglimmer.a
ar -t /home/saikat/glimmer/staticlib/libglimmer.a
```

## Platform Notes

### Linux Only

This CMake configuration is specifically designed for Linux. Building on other platforms (Windows, macOS) is not supported by this build script and will produce an error.

### Thread Safety

The library is built with position-independent code (`-fPIC`) and links against pthreads for thread safety.

## Additional Information

- See `README.md` for library usage and API documentation
- See `GlimmerTest/test.cpp` for example code
- Library source: `/home/saikat/glimmer/src/`
- Dependencies: `/home/saikat/glimmer/src/libs/`



