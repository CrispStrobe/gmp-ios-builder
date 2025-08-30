#!/bin/bash
############################################################################
#
# build_symengine.sh
# Build script for SymEngine (Fast Symbolic Manipulation Library) 
# for iOS devices and simulators, creating an XCFramework.
#
# Requirements:
# - GMP, MPFR, MPC, and FLINT must be built first
# - SymEngine source (clone from GitHub or download release)
# - Xcode and Command Line Tools installed  
# - CMake installed (brew install cmake)
#
############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd )
BUILDDIR=$SCRIPTDIR/build-symengine
LIBDIR=$BUILDDIR/lib
LIBNAME=symengine
SYMENGINE_VERSION=0.11.2
SYMENGINE_SOURCE="$SCRIPTDIR/symengine-$SYMENGINE_VERSION"

# Dependency paths (must exist from previous builds)
GMP_BUILDDIR="$SCRIPTDIR/build"
GMP_LIBDIR="$GMP_BUILDDIR/lib"
GMP_HEADERS_DIR="$GMP_BUILDDIR/include"

MPFR_BUILDDIR="$SCRIPTDIR/build-mpfr"
MPFR_LIBDIR="$MPFR_BUILDDIR/lib"
MPFR_HEADERS_DIR="$MPFR_BUILDDIR/include"

MPC_BUILDDIR="$SCRIPTDIR/build-mpc"
MPC_LIBDIR="$MPC_BUILDDIR/lib"
MPC_HEADERS_DIR="$MPC_BUILDDIR/include"

FLINT_BUILDDIR="$SCRIPTDIR/build-flint"
FLINT_LIBDIR="$FLINT_BUILDDIR/lib"
FLINT_HEADERS_DIR="$FLINT_BUILDDIR/include"

# Architectures for running on a physical device.
DEVARCHS="arm64"

# Architectures for running on a simulator.
SIMARCHS="x86_64 arm64"

# Minimum iOS version
IOSVERSIONMIN=13.0

# --- Functions ---
cleanup() {
    echo "[CLEANUP] SymEngine build script finished."
}
trap cleanup EXIT

logMsg() {
    printf "[SYMENGINE BUILD] %s\n" "$1"
}

errorExit() {
    logMsg "ERROR: $1"
    logMsg "Build failed."
    exit 1
}

checkCMake() {
    if ! command -v cmake &> /dev/null; then
        errorExit "CMake is required but not installed. Please run: brew install cmake"
    fi
    logMsg "CMake found: $(cmake --version | head -1)"
}

setupIncludeDirectories() {
    logMsg "Setting up include directories for dependencies..."
    
    # Create include directories for all dependencies
    mkdir -p "$GMP_HEADERS_DIR"
    mkdir -p "$MPFR_HEADERS_DIR" 
    mkdir -p "$MPC_HEADERS_DIR"
    mkdir -p "$FLINT_HEADERS_DIR"
    
    # Copy public headers
    if [ -f "$SCRIPTDIR/build/source/gmp.h" ]; then
        cp "$SCRIPTDIR/build/source/gmp.h" "$GMP_HEADERS_DIR/"
    fi
    
    if [ -f "$SCRIPTDIR/build-mpfr/source/src/mpfr.h" ]; then
        cp "$SCRIPTDIR/build-mpfr/source/src/mpfr.h" "$MPFR_HEADERS_DIR/"
    fi

    if [ -f "$SCRIPTDIR/build-mpc/source/src/mpc.h" ]; then
        cp "$SCRIPTDIR/build-mpc/source/src/mpc.h" "$MPC_HEADERS_DIR/"
    fi

    # FLINT headers are more complex - copy main header and src directory
    if [ -f "$SCRIPTDIR/build-flint/source/flint.h" ]; then
        cp "$SCRIPTDIR/build-flint/source/flint.h" "$FLINT_HEADERS_DIR/"
        mkdir -p "$FLINT_HEADERS_DIR/src"
        cp -r "$SCRIPTDIR/build-flint/source/src/"*.h "$FLINT_HEADERS_DIR/src/" 2>/dev/null || true
    fi
}

checkDependencies() {
    logMsg "Checking GMP, MPFR, MPC, and FLINT dependencies..."
    
    # Check all required builds exist
    local required_builds=("build" "build-mpfr" "build-mpc" "build-flint")
    for build_dir in "${required_builds[@]}"; do
        if [ ! -d "$SCRIPTDIR/$build_dir" ]; then
            errorExit "$build_dir not found. Please build all dependencies first."
        fi
    done

    # Check all required libraries exist for each architecture
    local platforms=("iphoneos-arm64" "iphonesimulator-arm64" "iphonesimulator-x86_64")
    local libs=("gmp" "mpfr" "mpc" "flint")
    local lib_dirs=("$GMP_LIBDIR" "$MPFR_LIBDIR" "$MPC_LIBDIR" "$FLINT_LIBDIR")
    
    for platform in "${platforms[@]}"; do
        for i in "${!libs[@]}"; do
            local lib="${libs[$i]}"
            local lib_dir="${lib_dirs[$i]}"
            local lib_path="$lib_dir/lib$lib-$platform.a"
            
            if [ ! -f "$lib_path" ]; then
                errorExit "Required $lib library not found: $lib_path"
            fi
        done
    done
    
    logMsg "All dependency checks passed."
}

downloadSymEngine() {
    if [ -d "$SYMENGINE_SOURCE" ]; then
        logMsg "SymEngine source already exists at $SYMENGINE_SOURCE"
        return
    fi

    logMsg "Downloading SymEngine $SYMENGINE_VERSION..."
    curl -L -o "symengine-$SYMENGINE_VERSION.tar.gz" \
        "https://github.com/symengine/symengine/archive/v$SYMENGINE_VERSION.tar.gz"
    
    tar -xf "symengine-$SYMENGINE_VERSION.tar.gz"
    
    if [ ! -d "$SYMENGINE_SOURCE" ]; then
        errorExit "Failed to extract SymEngine source"
    fi
}

configureAndMake() {
    local platform=$1
    local arch=$2
    local build_dir="$BUILDDIR/$platform-$arch"
    
    logMsg "================================================================="
    logMsg "Configuring SymEngine for PLATFORM: $platform ARCH: $arch"
    logMsg "================================================================="
    
    local sdkpath=$(xcrun --sdk $platform --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then
        errorExit "SDK path not found for platform $platform. Is Xcode installed?"
    fi
    
    # Create build directory
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"
    
    # Set up library paths for this architecture
    local temp_lib_dir="$build_dir/temp-deps"
    mkdir -p "$temp_lib_dir"
    
    ln -sf "$GMP_LIBDIR/libgmp-$platform-$arch.a" "$temp_lib_dir/libgmp.a"
    ln -sf "$MPFR_LIBDIR/libmpfr-$platform-$arch.a" "$temp_lib_dir/libmpfr.a"
    ln -sf "$MPC_LIBDIR/libmpc-$platform-$arch.a" "$temp_lib_dir/libmpc.a"
    ln -sf "$FLINT_LIBDIR/libflint-$platform-$arch.a" "$temp_lib_dir/libflint.a"
    
    # Set compiler and flags
    export CC=$(xcrun --sdk $platform -f clang)
    export CXX=$(xcrun --sdk $platform -f clang++)
    
    # Set host architecture for cross-compilation
    local host_arch=$arch
    if [[ "$arch" == "arm64" ]]; then
        host_arch="aarch64"
    fi
    
    # Platform-specific deployment targets and sysroot
    local cmake_args=""
    if [[ "$platform" == "iphonesimulator" ]]; then
        cmake_args="-DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=$sdkpath -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOSVERSIONMIN -DCMAKE_OSX_ARCHITECTURES=$arch -DCMAKE_IOS_INSTALL_COMBINED=NO"
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN"
        export CXXFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN -std=c++11"
    else
        cmake_args="-DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=$sdkpath -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOSVERSIONMIN -DCMAKE_OSX_ARCHITECTURES=$arch -DCMAKE_IOS_INSTALL_COMBINED=NO"
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN"
        export CXXFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN -std=c++11"
    fi
    
    export LDFLAGS="-L$temp_lib_dir"
    
    # Configure SymEngine with CMake
    logMsg "Running CMake configure..."
    cmake "$SYMENGINE_SOURCE" \
        $cmake_args \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DWITH_GMP=ON \
        -DWITH_MPFR=ON \
        -DWITH_MPC=ON \
        -DWITH_FLINT=ON \
        -DINTEGER_CLASS=flint \
        -DWITH_SYMENGINE_THREAD_SAFE=OFF \
        -DWITH_LLVM=OFF \
        -DWITH_TCMALLOC=OFF \
        -DBUILD_TESTS=OFF \
        -DBUILD_BENCHMARKS=OFF \
        -DGMP_INCLUDE_DIR="$GMP_HEADERS_DIR" \
        -DGMP_LIBRARY="$temp_lib_dir/libgmp.a" \
        -DMPFR_INCLUDE_DIR="$MPFR_HEADERS_DIR" \
        -DMPFR_LIBRARY="$temp_lib_dir/libmpfr.a" \
        -DMPC_INCLUDE_DIR="$MPC_HEADERS_DIR" \
        -DMPC_LIBRARY="$temp_lib_dir/libmpc.a" \
        -DFLINT_INCLUDE_DIR="$FLINT_HEADERS_DIR" \
        -DFLINT_LIBRARY="$temp_lib_dir/libflint.a"
    
    logMsg "Building SymEngine for $platform $arch..."
    make -j$(sysctl -n hw.ncpu)
    
    # Copy the built library
    logMsg "Copying built SymEngine library..."
    [ -d "$LIBDIR" ] || mkdir -p "$LIBDIR"
    cp "lib/lib$LIBNAME.a" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
}

createFramework() {
    local FRAMEWORK_NAME="SymEngine"
    local FRAMEWORK_DIR="$SCRIPTDIR/$FRAMEWORK_NAME.xcframework"
    local HEADERS_DIR="$SYMENGINE_SOURCE"

    logMsg "================================================================="
    logMsg "Creating SymEngine XCFramework"
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
    # Copy SymEngine headers
    mkdir -p "$FRAMEWORK_DIR/ios-arm64/symengine"
    cp -r "$HEADERS_DIR/symengine/"*.h "$FRAMEWORK_DIR/ios-arm64/symengine/" 2>/dev/null || true

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a" "$FRAMEWORK_DIR/ios-arm64-simulator/lib$LIBNAME.a"
    mkdir -p "$FRAMEWORK_DIR/ios-arm64-simulator/symengine"
    cp -r "$HEADERS_DIR/symengine/"*.h "$FRAMEWORK_DIR/ios-arm64-simulator/symengine/" 2>/dev/null || true

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" "$FRAMEWORK_DIR/ios-x86_64-simulator/lib$LIBNAME.a"
    mkdir -p "$FRAMEWORK_DIR/ios-x86_64-simulator/symengine"
    cp -r "$HEADERS_DIR/symengine/"*.h "$FRAMEWORK_DIR/ios-x86_64-simulator/symengine/" 2>/dev/null || true

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
    logMsg "SymEngine XCFramework ready for use in iOS projects."
}

# --- Main Build Logic ---

logMsg "Starting SymEngine build for iOS..."

# Check prerequisites
checkCMake
checkDependencies

# Set up include directories
setupIncludeDirectories

# Download SymEngine source if needed
downloadSymEngine

# Clean old build directory
if [ -d "$BUILDDIR" ]; then
    logMsg "Cleaning old SymEngine build directory..."
    rm -rf "$BUILDDIR"
fi

logMsg "--- Building SymEngine for iOS Device ---"
for ARCH in $DEVARCHS; do
    configureAndMake "iphoneos" $ARCH
done

logMsg "--- Building SymEngine for iOS Simulator ---"
for ARCH in $SIMARCHS; do
    configureAndMake "iphonesimulator" $ARCH
done

createFramework

logMsg "SymEngine build process completed successfully!"
logMsg ""
logMsg "🎉 Complete iOS Mathematical Computing Stack Built!"
logMsg "✅ GMP: Arbitrary precision integers"
logMsg "✅ MPFR: Arbitrary precision floating-point"  
logMsg "✅ MPC: Arbitrary precision complex numbers"
logMsg "✅ FLINT: Fast number theory algorithms"
logMsg "✅ SymEngine: Symbolic mathematics engine"
logMsg ""
logMsg "Next steps:"
logMsg "1. Add all XCFrameworks to your iOS project"
logMsg "2. Link in Build Phases → Link Binary With Libraries"
logMsg "3. Import as needed: #import <gmp.h>, #import <mpfr.h>, #import <mpc.h>"
logMsg "4. Import FLINT: #import <flint.h> and specific modules"
logMsg "5. Import SymEngine: #import <symengine/symengine.h>"
logMsg "6. You now have a complete symbolic + numeric math stack for iOS!"
exit 0