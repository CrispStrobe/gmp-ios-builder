#!/bin/bash
############################################################################
#
# build-mpfr.sh
# Build script for MPFR (Multiple Precision Floating-Point Reliable) library
# for iOS devices and simulators, creating an XCFramework.
#
# Requirements:
# - GMP must be built first (this script looks for GMP libraries and headers)
# - MPFR 4.2.2 source archive (mpfr-4.2.2.tar.xz) in the same directory
# - Xcode and Command Line Tools installed
#
############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd )
BUILDDIR=$SCRIPTDIR/build-mpfr
LIBDIR=$BUILDDIR/lib
LIBNAME=mpfr
VERSION=4.2.2
SOFTWARETAR="$SCRIPTDIR/$LIBNAME-$VERSION.tar.xz"

# GMP dependency paths (must exist from previous GMP build)
GMP_BUILDDIR="$SCRIPTDIR/build"
GMP_LIBDIR="$GMP_BUILDDIR/lib"
GMP_HEADERS_DIR="$GMP_BUILDDIR/source"

# Architectures for running on a physical device.
DEVARCHS="arm64"

# Architectures for running on a simulator.
SIMARCHS="x86_64 arm64"

# Minimum iOS version
IOSVERSIONMIN=13.0

# --- Functions ---
cleanup() {
    echo "[CLEANUP] MPFR build script finished."
}
trap cleanup EXIT

logMsg() {
    printf "[MPFR BUILD] %s\n" "$1"
}

errorExit() {
    logMsg "ERROR: $1"
    logMsg "Build failed."
    exit 1
}

checkGmpDependency() {
    logMsg "Checking GMP dependency..."
    
    if [ ! -d "$GMP_BUILDDIR" ] || [ ! -f "$GMP_HEADERS_DIR/gmp.h" ]; then
        errorExit "GMP build not found. Please run ./build_gmp.sh first to build GMP."
    fi

    # Check that required GMP libraries exist
    local required_gmp_libs=(
        "$GMP_LIBDIR/libgmp-iphoneos-arm64.a"
        "$GMP_LIBDIR/libgmp-iphonesimulator-arm64.a" 
        "$GMP_LIBDIR/libgmp-iphonesimulator-x86_64.a"
    )
    
    for lib in "${required_gmp_libs[@]}"; do
        if [ ! -f "$lib" ]; then
            errorExit "Required GMP library not found: $lib. Please run ./build_gmp.sh first."
        fi
    done
    
    logMsg "GMP dependency check passed."
}

extractSoftware() {
    local extractdir="$BUILDDIR/source"
    logMsg "Creating build directory and extracting MPFR source..."
    mkdir -p "$extractdir"
    cd "$extractdir"

    if [ ! -f "$SOFTWARETAR" ]; then
        errorExit "MPFR archive not found at $SOFTWARETAR. Please download mpfr-4.2.2.tar.xz"
    fi

    tar -xf "$SOFTWARETAR" --strip-components 1 || errorExit "Failed to extract MPFR tarball."
}

configureAndMake() {
    local platform=$1
    local arch=$2
    local extractdir="$BUILDDIR/source"

    logMsg "================================================================="
    logMsg "Configuring MPFR for PLATFORM: $platform ARCH: $arch"
    logMsg "================================================================="

    local sdkpath=$(xcrun --sdk $platform --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then
        errorExit "SDK path not found for platform $platform. Is Xcode installed?"
    fi

    # Set up paths for GMP dependency
    local gmp_lib_path="$GMP_LIBDIR/libgmp-$platform-$arch.a"
    if [ ! -f "$gmp_lib_path" ]; then
        errorExit "GMP library not found: $gmp_lib_path"
    fi

    # Create a temporary directory with expected library name for configure
    local temp_lib_dir="$BUILDDIR/temp-gmp-$platform-$arch"
    mkdir -p "$temp_lib_dir"
    ln -sf "$gmp_lib_path" "$temp_lib_dir/libgmp.a"

    # Set compiler and flags
    export CC=$(xcrun --sdk $platform -f clang)
    export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN -I$GMP_HEADERS_DIR"
    export LDFLAGS="-arch $arch -isysroot $sdkpath -L$temp_lib_dir"
    export LIBS="-lgmp"

    cd "$extractdir"

    # Important: Run make distclean to ensure a fresh build for each architecture
    make distclean &> /dev/null || true

    # FIXED: Detect build machine architecture and set proper cross-compilation
    local build_machine=$(uname -m)
    local build_arch="x86_64"
    if [[ "$build_machine" == "arm64" ]]; then
        build_arch="aarch64"
    fi

    # Set host architecture (GMP convention: aarch64 for arm64)
    local host_arch=$arch
    if [[ "$arch" == "arm64" ]]; then
        host_arch="aarch64"
    fi

    # CRITICAL FIX: Force cross-compilation mode by making build != host
    # Even for same-arch builds, iOS is always cross-compilation
    local build_target="$build_arch-apple-darwin"
    local host_target="$host_arch-apple-ios"  # Use ios instead of darwin to force cross-compilation

    logMsg "Build: $build_target, Host: $host_target"

    # Configure MPFR with forced cross-compilation
    ./configure \
        --build="$build_target" \
        --host="$host_target" \
        --disable-shared \
        --enable-static \
        --with-gmp-include="$GMP_HEADERS_DIR" \
        --with-gmp-lib="$temp_lib_dir" \
        --disable-thread-safe

    logMsg "Building MPFR for $platform $arch..."
    make -j$(sysctl -n hw.ncpu)

    logMsg "Copying built MPFR library..."
    [ -d "$LIBDIR" ] || mkdir -p "$LIBDIR"
    cp "src/.libs/lib$LIBNAME.a" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
}

createFramework() {
    local FRAMEWORK_NAME="MPFR"
    local FRAMEWORK_DIR="$SCRIPTDIR/$FRAMEWORK_NAME.xcframework"
    local HEADERS_DIR="$BUILDDIR/source/src/"

    logMsg "================================================================="
    logMsg "Creating MPFR XCFramework"
    logMsg "================================================================="

    rm -rf "$FRAMEWORK_DIR" # Clean old framework

    # Create the directory structure for the XCFramework manually
    logMsg "Creating XCFramework directory structure..."
    mkdir -p "$FRAMEWORK_DIR/ios-arm64"
    mkdir -p "$FRAMEWORK_DIR/ios-arm64-simulator"
    mkdir -p "$FRAMEWORK_DIR/ios-x86_64-simulator"

    # Copy the libraries and headers into their correct locations
    logMsg "Copying libraries and headers..."
    cp "$LIBDIR/lib$LIBNAME-iphoneos-arm64.a" "$FRAMEWORK_DIR/ios-arm64/lib$LIBNAME.a"
    cp "$HEADERS_DIR/mpfr.h" "$FRAMEWORK_DIR/ios-arm64/mpfr.h"

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a" "$FRAMEWORK_DIR/ios-arm64-simulator/lib$LIBNAME.a"
    cp "$HEADERS_DIR/mpfr.h" "$FRAMEWORK_DIR/ios-arm64-simulator/mpfr.h"

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" "$FRAMEWORK_DIR/ios-x86_64-simulator/lib$LIBNAME.a"
    cp "$HEADERS_DIR/mpfr.h" "$FRAMEWORK_DIR/ios-x86_64-simulator/mpfr.h"

    # Create the Info.plist manifest file
    logMsg "Generating Info.plist..."
    cat > "$FRAMEWORK_DIR/Info.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AvailableLibraries</key>
    <array>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64</string>
            <key>LibraryPath</key>
            <string>lib$LIBNAME.a</string>
            <key>HeadersPath</key>
            <string>.</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
        </dict>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64-simulator</string>
            <key>LibraryPath</key>
            <string>lib$LIBNAME.a</string>
            <key>HeadersPath</key>
            <string>.</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
            <key>SupportedPlatformVariant</key>
            <string>simulator</string>
        </dict>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-x86_64-simulator</string>
            <key>LibraryPath</key>
            <string>lib$LIBNAME.a</string>
            <key>HeadersPath</key>
            <string>.</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>x86_64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
            <key>SupportedPlatformVariant</key>
            <string>simulator</string>
        </dict>
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOL

    logMsg "Successfully created $FRAMEWORK_DIR"
    logMsg "MPFR XCFramework ready for use in iOS projects."
}

# --- Main Build Logic ---

logMsg "Starting MPFR build for iOS..."

# Check GMP dependency first
checkGmpDependency

# Clean old build directory if it exists
if [ -d "$BUILDDIR" ]; then
    logMsg "Cleaning old MPFR build directory..."
    rm -rf "$BUILDDIR"
fi

extractSoftware

logMsg "--- Building MPFR for iOS Device ---"
for ARCH in $DEVARCHS; do
    configureAndMake "iphoneos" $ARCH
done

logMsg "--- Building MPFR for iOS Simulator ---"
for ARCH in $SIMARCHS; do
    configureAndMake "iphonesimulator" $ARCH
done

createFramework

logMsg "MPFR build process completed successfully!"
logMsg "Next steps:"
logMsg "1. Use both GMP.xcframework and MPFR.xcframework in your iOS project"
logMsg "2. Import both: #import <gmp.h> and #import <mpfr.h>"
logMsg "3. Link both frameworks in your Xcode project"
exit 0