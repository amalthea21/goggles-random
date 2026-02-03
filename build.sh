#!/bin/bash

set -e

SRC_DIR="src"
INC_DIR="include"
OBJ_DIR="obj"
BIN_DIR="bin"
TARGET="goggles-random"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

mkdir -p "$OBJ_DIR" "$BIN_DIR" 2>/dev/null

clean() {
    rm -rf "$OBJ_DIR" "$BIN_DIR" 2>/dev/null
}

build() {
    if [ ! -f "$SRC_DIR/main.asm" ]; then
        echo -e "${RED}Error: $SRC_DIR/main.asm not found${NC}"
        exit 1
    fi

    for asm_file in "$SRC_DIR"/*.asm; do
        if [ -f "$asm_file" ]; then
            filename=$(basename "$asm_file" .asm)
            if ! nasm -f elf64 -I"$INC_DIR/" -o "$OBJ_DIR/$filename.o" "$asm_file"; then
                echo -e "${RED}Assembly failed for $filename.asm${NC}"
                exit 1
            fi
        fi
    done

    if ! ld -o "$BIN_DIR/$TARGET" "$OBJ_DIR"/*.o; then
        echo -e "${RED}Linking failed${NC}"
        exit 1
    fi
}

run() {
    if [ ! -f "$BIN_DIR/$TARGET" ]; then
        build
    fi
    "$BIN_DIR/$TARGET" "$@"
}

case "${1:-build}" in
    clean)
        clean
        echo -e "${GREEN}Build cleaned${NC}"
        ;;
    run)
        build
        shift
        run "$@"
        ;;
    build)
        build
        echo -e "${GREEN}Build successful${NC}"
        ;;
    *)
        echo -e "${RED}Usage: $0 {build|clean|run}${NC}"
        exit 1
        ;;
esac