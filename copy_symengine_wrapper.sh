ls#!/bin/bash
# Simple script to copy the working SymEngine wrapper to the plugin

set -e

readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
readonly BUILDDIR="$SCRIPTDIR/build-symengine"
readonly TARGET_DIR="/Users/christianstrobele/code/symbolic_math_bridge/ios"

logMsg() { printf "[COPY] %s\n" "$1"; }

# Check if build completed successfully
if [ ! -d "$BUILDDIR" ]; then
    echo "❌ Build directory not found. Run ./build_symengine.sh first."
    exit 1
fi

# Remove old XCFramework approach
rm -rf "$TARGET_DIR/SymEngine.xcframework"
rm -rf "$TARGET_DIR/SymEngineWrapper.xcframework"

# Create a simple static library approach instead
logMsg "Creating simple static library structure..."

# Copy the header
mkdir -p "$TARGET_DIR/Headers"
cp "$BUILDDIR/iphoneos-arm64/symengine_c_wrapper.h" "$TARGET_DIR/Headers/"

# Copy the static libraries with simplified names
mkdir -p "$TARGET_DIR/Libraries"
cp "$BUILDDIR/lib/libsymengine_wrapper-iphoneos-arm64.a" "$TARGET_DIR/Libraries/"
cp "$BUILDDIR/lib/libsymengine_wrapper-iphonesimulator-x86_64.a" "$TARGET_DIR/Libraries/"
cp "$BUILDDIR/lib/libsymengine_wrapper-iphonesimulator-arm64.a" "$TARGET_DIR/Libraries/"
cp "$BUILDDIR/lib/libsymengine_wrapper-macosx-x86_64.a" "$TARGET_DIR/Libraries/"
cp "$BUILDDIR/lib/libsymengine_wrapper-macosx-arm64.a" "$TARGET_DIR/Libraries/"

# Create universal libraries
lipo -create -output "$TARGET_DIR/Libraries/libsymengine_wrapper-iphonesimulator-universal.a" \
    "$TARGET_DIR/Libraries/libsymengine_wrapper-iphonesimulator-x86_64.a" \
    "$TARGET_DIR/Libraries/libsymengine_wrapper-iphonesimulator-arm64.a"

lipo -create -output "$TARGET_DIR/Libraries/libsymengine_wrapper-macosx-universal.a" \
    "$TARGET_DIR/Libraries/libsymengine_wrapper-macosx-x86_64.a" \
    "$TARGET_DIR/Libraries/libsymengine_wrapper-macosx-arm64.a"

logMsg "✅ Libraries copied successfully"
logMsg "📋 Files created:"
ls -la "$TARGET_DIR/Headers/"
ls -la "$TARGET_DIR/Libraries/"

echo "✅ Ready to use simplified static library approach"
