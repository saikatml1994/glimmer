#!/bin/bash

# Build script for Glimmer static library (Linux only)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo -e "${RED}Error: This build script is for Linux only${NC}"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Build directory
BUILD_DIR="${SCRIPT_DIR}/build"

# Parse command line arguments
BUILD_TYPE="Release"
CLEAN_BUILD=false
ENABLE_SVG=true
ENABLE_IMAGES=true
ENABLE_RICHTEXT=true
ENABLE_PLOTS=true
ENABLE_NFDEXT=false
ENABLE_BLEND2D=false

print_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -d, --debug             Build in Debug mode (default: Release)"
    echo "  -c, --clean             Clean build directory before building"
    echo "  --no-svg                Disable SVG support"
    echo "  --no-images             Disable image support"
    echo "  --no-richtext           Disable rich text support"
    echo "  --no-plots              Disable plots support"
    echo "  --enable-nfdext         Enable nfd-extended library"
    echo "  --enable-blend2d        Enable Blend2D renderer (requires libblend2d.a)"
    echo ""
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            exit 0
            ;;
        -d|--debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        --no-svg)
            ENABLE_SVG=false
            shift
            ;;
        --no-images)
            ENABLE_IMAGES=false
            shift
            ;;
        --no-richtext)
            ENABLE_RICHTEXT=false
            shift
            ;;
        --no-plots)
            ENABLE_PLOTS=false
            shift
            ;;
        --enable-nfdext)
            ENABLE_NFDEXT=true
            shift
            ;;
        --enable-blend2d)
            ENABLE_BLEND2D=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Cleaning build directory...${NC}"
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Prepare CMake options
CMAKE_OPTIONS="-DCMAKE_BUILD_TYPE=$BUILD_TYPE"

if [ "$ENABLE_SVG" = false ]; then
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DGLIMMER_DISABLE_SVG=ON"
fi

if [ "$ENABLE_IMAGES" = false ]; then
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DGLIMMER_DISABLE_IMAGES=ON"
fi

if [ "$ENABLE_RICHTEXT" = false ]; then
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DGLIMMER_DISABLE_RICHTEXT=ON"
fi

if [ "$ENABLE_PLOTS" = false ]; then
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DGLIMMER_DISABLE_PLOTS=ON"
fi

if [ "$ENABLE_NFDEXT" = true ]; then
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DGLIMMER_ENABLE_NFDEXT=ON"
fi

if [ "$ENABLE_BLEND2D" = true ]; then
    CMAKE_OPTIONS="$CMAKE_OPTIONS -DGLIMMER_ENABLE_BLEND2D=ON"
fi

# Run CMake
echo -e "${GREEN}Running CMake...${NC}"
echo -e "${YELLOW}Build Type: $BUILD_TYPE${NC}"
cmake $CMAKE_OPTIONS ..

# Build
echo -e "${GREEN}Building Glimmer static library...${NC}"
make -j$(nproc)

# Check if build was successful
if [ -f "${SCRIPT_DIR}/staticlib/libglimmer.a" ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Build successful!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "Static library created at: ${GREEN}${SCRIPT_DIR}/staticlib/libglimmer.a${NC}"
    
    # Show library size
    LIB_SIZE=$(du -h "${SCRIPT_DIR}/staticlib/libglimmer.a" | cut -f1)
    echo -e "Library size: ${YELLOW}${LIB_SIZE}${NC}"
    echo ""
else
    echo -e "${RED}Build failed - library not found${NC}"
    exit 1
fi



