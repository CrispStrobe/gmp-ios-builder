#!/bin/bash
############################################################################
#
# build_mpc.sh
# Build script for MPC (Multiple Precision Complex) library
# for iOS devices and simulators, creating an XCFramework.
#
# Requirements:
# - GMP must be built first (this script looks for GMP libraries and headers)
# - MPFR must be built first (this script looks for MPFR libraries and headers)
# - MPC 1.3.1 source archive (mpc-1.3.1.tar.gz) in the same directory
# - Xcode and Command Line Tools installed
#
############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd )
BUILDDIR=$SCRIPTDIR/build-mpc
LIBDIR=$BUILDDIR/lib
LIBNAME=mpc
VERSION=1.3.1
SOFTWARETAR="$SCRIPTDIR/$LIBNAME-$VERSION.tar.gz"

# GMP dependency paths (must exist from previous GMP build)
GMP_BUILDDIR="$SCRIPTDIR/build"
GMP_LIBDIR="$GMP_BUILDDIR/lib"
GMP_HEADERS_DIR="$GMP_BUILDDIR/include"

# MPFR dependency paths (must exist from previous MPFR build)
MPFR_BUILDDIR="$SCRIPTDIR/build-mpfr"
MPFR_LIBDIR="$MPFR_BUILDDIR/lib"
MPFR_HEADERS_DIR="$MPFR_BUILDDIR/include"

# Architectures for running on a physical device.
DEVARCHS="arm64"

# Architectures for running on a simulator.
SIMARCHS="x86_64 arm64"

# Minimum iOS version
IOSVERSIONMIN=13.0

# --- Functions ---
cleanup() {
    echo "[CLEANUP] MPC build script finished."
}
trap cleanup EXIT

logMsg() {
    printf "[MPC BUILD] %s\n" "$1"
}

errorExit() {
    logMsg "ERROR: $1"
    logMsg "Build failed."
    exit 1
}

setupIncludeDirectories() {
    logMsg "Setting up include directories for dependencies..."
    
    # Create include directories for GMP and MPFR
    mkdir -p "$GMP_HEADERS_DIR"
    mkdir -p "$MPFR_HEADERS_DIR"
    
    # Copy only the public headers, not internal ones
    if [ -f "$SCRIPTDIR/build/source/gmp.h" ]; then
        cp "$SCRIPTDIR/build/source/gmp.h" "$GMP_HEADERS_DIR/"
    fi
    
    if [ -f "$SCRIPTDIR/build-mpfr/source/src/mpfr.h" ]; then
        cp "$SCRIPTDIR/build-mpfr/source/src/mpfr.h" "$MPFR_HEADERS_DIR/"
    fi
}

checkDependencies() {
    logMsg "Checking GMP and MPFR dependencies..."
    
    # Check GMP
    if [ ! -d "$SCRIPTDIR/build" ] || [ ! -f "$SCRIPTDIR/build/source/gmp.h" ]; then
        errorExit "GMP build not found. Please run ./build_gmp.sh first to build GMP."
    fi

    # Check MPFR
    if [ ! -d "$SCRIPTDIR/build-mpfr" ] || [ ! -f "$SCRIPTDIR/build-mpfr/source/src/mpfr.h" ]; then
        errorExit "MPFR build not found. Please run ./build_mpfr.sh first to build MPFR."
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

    # Check that required MPFR libraries exist
    local required_mpfr_libs=(
        "$MPFR_LIBDIR/libmpfr-iphoneos-arm64.a"
        "$MPFR_LIBDIR/libmpfr-iphonesimulator-arm64.a"
        "$MPFR_LIBDIR/libmpfr-iphonesimulator-x86_64.a"
    )
    
    for lib in "${required_mpfr_libs[@]}"; do
        if [ ! -f "$lib" ]; then
            errorExit "Required MPFR library not found: $lib. Please run ./build_mpfr.sh first."
        fi
    done
    
    logMsg "GMP and MPFR dependency checks passed."
}

extractSoftware() {
    local extractdir="$BUILDDIR/source"
    logMsg "Creating build directory and extracting MPC source..."
    mkdir -p "$extractdir"
    cd "$extractdir"

    if [ ! -f "$SOFTWARETAR" ]; then
        errorExit "MPC archive not found at $SOFTWARETAR. Please download mpc-1.3.1.tar.gz from https://www.multiprecision.org/mpc/download.html"
    fi

    tar -xf "$SOFTWARETAR" --strip-components 1 || errorExit "Failed to extract MPC tarball."
}

configureAndMake() {
    local platform=$1
    local arch=$2
    local extractdir="$BUILDDIR/source"
    
    logMsg "================================================================="
    logMsg "Configuring MPC for PLATFORM: $platform ARCH: $arch"
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

    # Set up paths for MPFR dependency
    local mpfr_lib_path="$MPFR_LIBDIR/libmpfr-$platform-$arch.a"
    if [ ! -f "$mpfr_lib_path" ]; then
        errorExit "MPFR library not found: $mpfr_lib_path"
    fi
    
    # Create a temporary directory with expected library names for configure
    local temp_lib_dir="$BUILDDIR/temp-deps-$platform-$arch"
    mkdir -p "$temp_lib_dir"
    ln -sf "$gmp_lib_path" "$temp_lib_dir/libgmp.a"
    ln -sf "$mpfr_lib_path" "$temp_lib_dir/libmpfr.a"
    
    # Set compiler and flags - CRITICAL: Platform-specific deployment targets
    export CC=$(xcrun --sdk $platform -f clang)
    
    if [[ "$platform" == "iphonesimulator" ]]; then
        # Simulator-specific flags
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN -I$GMP_HEADERS_DIR -I$MPFR_HEADERS_DIR"
        export LDFLAGS="-arch $arch -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN -L$temp_lib_dir"
    else
        # Device-specific flags
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN -I$GMP_HEADERS_DIR -I$MPFR_HEADERS_DIR"
        export LDFLAGS="-arch $arch -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN -L$temp_lib_dir"
    fi
    
    export LIBS="-lmpfr -lgmp"
    
    cd "$extractdir"
    
    # Important: Run make distclean to ensure a fresh build for each architecture
    make distclean &> /dev/null || true
    
    # PATCH: Correctly set host architecture. MPC's configure script
    # recognizes `aarch64` for 64-bit ARM, not `arm64`.
    local host_arch=$arch
    if [[ "$arch" == "arm64" ]]; then
        host_arch="aarch64"
    fi
    
    # Configure MPC with GMP and MPFR dependencies
    ./configure \
        --host="$host_arch-apple-darwin" \
        --disable-shared \
        --enable-static \
        --with-gmp-include="$GMP_HEADERS_DIR" \
        --with-gmp-lib="$temp_lib_dir" \
        --with-mpfr-include="$MPFR_HEADERS_DIR" \
        --with-mpfr-lib="$temp_lib_dir"
    
    logMsg "Building MPC for $platform $arch..."
    make -j$(sysctl -n hw.ncpu)
    
    logMsg "Copying built MPC library..."
    [ -d "$LIBDIR" ] || mkdir -p "$LIBDIR"
    cp "src/.libs/lib$LIBNAME.a" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
    
    # Clean up temp directory
    rm -rf "$temp_lib_dir"
}

createFramework() {
    local FRAMEWORK_NAME="MPC"
    local FRAMEWORK_DIR="$SCRIPTDIR/$FRAMEWORK_NAME.xcframework"
    local HEADERS_DIR="$BUILDDIR/source/src/"

    logMsg "================================================================="
    logMsg "Creating MPC XCFramework"
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
    cp "$HEADERS_DIR/mpc.h" "$FRAMEWORK_DIR/ios-arm64/mpc.h"

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a" "$FRAMEWORK_DIR/ios-arm64-simulator/lib$LIBNAME.a"
    cp "$HEADERS_DIR/mpc.h" "$FRAMEWORK_DIR/ios-arm64-simulator/mpc.h"

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" "$FRAMEWORK_DIR/ios-x86_64-simulator/lib$LIBNAME.a"
    cp "$HEADERS_DIR/mpc.h" "$FRAMEWORK_DIR/ios-x86_64-simulator/mpc.h"

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
    logMsg "MPC XCFramework ready for use in iOS projects."
}

# --- Main Build Logic ---

logMsg "Starting MPC build for iOS..."

# Check GMP and MPFR dependencies first
checkDependencies

# Set up proper include directories with public headers only
setupIncludeDirectories

# Clean old build directory if it exists
if [ -d "$BUILDDIR" ]; then
    logMsg "Cleaning old MPC build directory..."
    rm -rf "$BUILDDIR"
fi

extractSoftware

logMsg "--- Building MPC for iOS Device ---"
for ARCH in $DEVARCHS; do
    configureAndMake "iphoneos" $ARCH
done

logMsg "--- Building MPC for iOS Simulator ---"
for ARCH in $SIMARCHS; do
    configureAndMake "iphonesimulator" $ARCH
done

createFramework

logMsg "MPC build process completed successfully!"
logMsg "Next steps:"
logMsg "1. Use GMP.xcframework, MPFR.xcframework, and MPC.xcframework in your iOS project"
logMsg "2. Import: #import <gmp.h>, #import <mpfr.h>, and #import <mpc.h>"
logMsg "3. Link all frameworks in your Xcode project"
logMsg "4. Now ready to build SymEngine with full numeric support!"
exit 0