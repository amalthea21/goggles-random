#!/bin/bash

# Build script for goggles-random assembly project
# Usage: ./build.sh [clean|run]

set -e  # Exit on error

# Configuration
SRC_DIR="src"
INC_DIR="include"
OBJ_DIR="obj"
BIN_DIR="bin"
TARGET="goggles-random"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

mkdir -p "$OBJ_DIR" "$BIN_DIR" 2>/dev/null

clean() {
    rm -rf "$OBJ_DIR" "$BIN_DIR" 2>/dev/null
    echo -e "${GREEN}✓ Clean complete${NC}"
}

build() {
    if [ ! -f "$SRC_DIR/main.asm" ]; then
        echo -e "${RED}Error: $SRC_DIR/main.asm not found${NC}"
        exit 1
    fi

    for asm_file in "$SRC_DIR"/*.asm; do
        if [ -f "$asm_file" ]; then
            filename=$(basename "$asm_file" .asm)
            nasm -f elf64 -I"$INC_DIR/" -o "$OBJ_DIR/$filename.o" "$asm_file" 2>&1 | grep -v "^$" || {
                echo -e "${RED}Error: Assembly failed for $filename.asm${NC}"
                exit 1
            }
        fi
    done

    ld -o "$BIN_DIR/$TARGET" "$OBJ_DIR"/*.o 2>&1 | grep -v "^$" || {
        echo -e "${RED}Error: Linking failed${NC}"
        exit 1
    }

    echo -e "${GREEN}✓ Build successful: $BIN_DIR/$TARGET${NC}"
}

run() {
    if [ ! -f "$BIN_DIR/$TARGET" ]; then
        build
    fi
    "$BIN_DIR/$TARGET"
}

case "${1:-build}" in
    clean)
        clean
        ;;
    run)
        run
        ;;
    build)
        build
        ;;
    *)
        echo "Usage: $0 {build|clean|run}"
        exit 1
        ;;
esac