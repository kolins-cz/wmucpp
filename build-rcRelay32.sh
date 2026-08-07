#!/bin/bash
# Build script for rcRelay32 using local ARM GCC toolchain
# This script sets up the local toolchain path without affecting system-wide configuration
#
# Usage: ./build-rcRelay32.sh [TARGET] [clean] [BOARD]
#   TARGET: G031, G0B1, or G431 (default: G031)
#   clean:  optional, cleans before building
#   BOARD:  WEACT, WMG0B1, or NUCLEO_431 (default: matches target)

set -e  # Exit on error

# Set up local ARM GCC toolchain path
export ARM_TOOLCHAIN_PATH="/home/kolin/wimalopaan/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi"
export PATH="${ARM_TOOLCHAIN_PATH}/bin:${PATH}"

# Verify toolchain is available
echo "Using ARM GCC toolchain:"
arm-none-eabi-g++ --version | head -1

# Navigate to rcRelay32 directory
cd "$(dirname "$0")/boards/rcRelay32"

# Parse arguments
TARGET="${1:-G031}"
CLEAN_ARG="$2"
BOARD_OVERRIDE="$3"

# Set default board based on target if not specified
if [ -z "$BOARD_OVERRIDE" ]; then
    case "$TARGET" in
        "G031") BOARD="WEACT" ;;
        "G0B1") BOARD="WMG0B1" ;;
        "G431") BOARD="NUCLEO_431" ;;
        *) BOARD="WEACT" ;;
    esac
else
    BOARD="$BOARD_OVERRIDE"
fi

# Prepare compiler flags to override board configuration
# Create a temporary config header that will be force-included
CONFIG_HEADER="build_config_${BOARD}.h"
cat > "$CONFIG_HEADER" <<EOF
// Auto-generated build configuration
// Board: ${BOARD}

#undef USE_WEACT
#undef USE_WMG0B1  
#undef USE_NUCLEO_431
#undef SERIAL_DEBUG
#undef ALTERNATE_PINS
#undef USE_IRDA
#undef USE_IRDA_TX_INVERT

#define USE_${BOARD}
EOF

# Force include this header before any source file
export CPPFLAGS="-include $CONFIG_HEADER"

MAKEFILE="Makefile.${TARGET}"

if [ ! -f "$MAKEFILE" ]; then
    echo "Error: Makefile for target ${TARGET} not found!"
    echo "Available targets: G031, G0B1, G431"
    exit 1
fi

echo ""
echo "Building rcRelay32 for ${TARGET} (Board: ${BOARD})..."
echo "=========================================="

# Clean previous build if requested
if [ "$CLEAN_ARG" == "clean" ]; then
    echo "Cleaning previous build..."
    make -f "$MAKEFILE" clean
    echo ""
fi

# Build the project
case "$TARGET" in
    "G031")
        make -f "$MAKEFILE" g031
        ;;
    "G0B1")
        make -f "$MAKEFILE" g0b1
        ;;
    "G431")
        make -f "$MAKEFILE" g431
        ;;
    *)
        make -f "$MAKEFILE"
        ;;
esac

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo ""

# Show the binary file info
if [ -f "relay_01.elf" ]; then
    echo "Binary size:"
    arm-none-eabi-size relay_01.elf
fi

if [ -f "relay_01.bin" ]; then
    echo ""
    ls -lh relay_01.bin
fi

# Clean up temporary config header
rm -f "$CONFIG_HEADER"
