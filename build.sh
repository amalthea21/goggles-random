#!/bin/bash

set -e

SRC_DIR="src"
INC_DIR="include"
OBJ_DIR="obj"
BIN_DIR="bin"
TARGET="goggles-random"

mkdir -p "$OBJ_DIR" "$BIN_DIR" 2>/dev/null

case "$1" in
    clean)
        rm -rf "$OBJ_DIR" "$BIN_DIR" 2>/dev/null
        echo "Cleaned"
        ;;
    build)
        echo "Building..."
        for f in "$SRC_DIR"/*.asm; do
            [ -f "$f" ] || continue
            name=$(basename "$f" .asm)
            nasm -f elf64 -I"$INC_DIR/" -o "$OBJ_DIR/$name.o" "$f"
        done
        ld -o "$BIN_DIR/$TARGET" "$OBJ_DIR"/*.o
        echo "Build complete"
        ;;
    run|"")
        for f in "$SRC_DIR"/*.asm; do
            [ -f "$f" ] || continue
            name=$(basename "$f" .asm)
            nasm -f elf64 -I"$INC_DIR/" -w-number-overflow -o "$OBJ_DIR/$name.o" "$f" 2>/dev/null
        done
        ld -o "$BIN_DIR/$TARGET" "$OBJ_DIR"/*.o 2>/dev/null
        shift
        exec "$BIN_DIR/$TARGET" "$@"
        ;;
    *)
        echo "Usage: $0 {build|clean|run}"
        echo "  run   : Build silently and execute (default)"
        echo "  build : Build with output"
        echo "  clean : Remove build artifacts"
        exit 1
        ;;
esac