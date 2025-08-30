#!/bin/bash
############################################################################
#
# build_symengine.sh
# Build script for SymEngine (Fast Symbolic Manipulation Library) 
# for iOS devices and simulators, creating an XCFramework.
#
############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd )
BUILDDIR=$SCRIPTDIR/build-symengine
LIBDIR=$BUILDDIR/lib
LIBNAME=symengine
VERSION_SYMENGINE=0.11.2
SYMENGINE_SOURCE="$SCRIPTDIR/symengine-$VERSION_SYMENGINE"

# Dependency paths
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

# Architectures
DEVARCHS="arm64"
SIMARCHS="x86_64 arm64"
IOSVERSIONMIN=13.0

# --- Functions ---
cleanup() {
    echo "[CLEANUP] SymEngine build script finished."
}
trap cleanup EXIT

logMsg() { printf "[SYMENGINE BUILD] %s\n" "$1"; }
errorExit() { logMsg "ERROR: $1"; logMsg "Build failed."; exit 1; }

setupIncludeDirectories() {
    logMsg "Setting up include directories for dependencies..."
    mkdir -p "$GMP_HEADERS_DIR" "$MPFR_HEADERS_DIR" "$MPC_HEADERS_DIR" "$FLINT_HEADERS_DIR"
    
    cp -f "$SCRIPTDIR/build/source/gmp.h" "$GMP_HEADERS_DIR/" 2>/dev/null || true
    cp -f "$SCRIPTDIR/build-mpfr/source/src/mpfr.h" "$MPFR_HEADERS_DIR/" 2>/dev/null || true
    cp -f "$SCRIPTDIR/build-mpc/source/src/mpc.h" "$MPC_HEADERS_DIR/" 2>/dev/null || true

    local flint_source_dir="$SCRIPTDIR/build-flint/source/src"
    logMsg "Looking for FLINT headers in: $flint_source_dir"

    if [ ! -f "$flint_source_dir/flint.h" ]; then
        errorExit "FLINT header not found at '$flint_source_dir/flint.h'. Please ensure FLINT was built correctly."
    fi
    logMsg "Found FLINT headers."

    local flint_target_dir="$FLINT_HEADERS_DIR/flint"
    mkdir -p "$flint_target_dir"
    logMsg "Copying all FLINT headers from $flint_source_dir to $flint_target_dir"
    cp "$flint_source_dir/"*.h "$flint_target_dir/"
    logMsg "FLINT headers set up successfully."
}

checkCMake() {
    if ! command -v cmake &> /dev/null; then errorExit "CMake not found. Please run: brew install cmake"; fi
    logMsg "CMake found: $(cmake --version | head -1)"
}

checkDependencies() {
    logMsg "Checking dependencies..."
    for build_dir in "build" "build-mpfr" "build-mpc" "build-flint"; do
        if [ ! -d "$SCRIPTDIR/$build_dir" ]; then errorExit "$build_dir not found. Please build all dependencies first."; fi
    done
    logMsg "All dependency checks passed."
}

downloadSymEngine() {
    if [ -d "$SYMENGINE_SOURCE" ]; then return; fi
    logMsg "Downloading SymEngine $VERSION_SYMENGINE..."
    curl -L -o "$SCRIPTDIR/symengine-$VERSION_SYMENGINE.tar.gz" "https://github.com/symengine/symengine/archive/v$VERSION_SYMENGINE.tar.gz"
    tar -xf "$SCRIPTDIR/symengine-$VERSION_SYMENGINE.tar.gz"
    if [ ! -d "$SYMENGINE_SOURCE" ]; then errorExit "Failed to extract SymEngine source"; fi
}

configureAndMake() {
    local platform=$1; local arch=$2; local build_dir="$BUILDDIR/$platform-$arch"
    logMsg "================================================================="
    logMsg "Configuring SymEngine for PLATFORM: $platform ARCH: $arch"
    logMsg "================================================================="
    local sdkpath=$(xcrun --sdk $platform --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then errorExit "SDK path not found for platform $platform."; fi
    
    rm -rf "$build_dir"; mkdir -p "$build_dir"; cd "$build_dir"
    local temp_lib_dir="$build_dir/temp-deps"; mkdir -p "$temp_lib_dir"
    ln -sf "$GMP_LIBDIR/libgmp-$platform-$arch.a" "$temp_lib_dir/libgmp.a"
    ln -sf "$MPFR_LIBDIR/libmpfr-$platform-$arch.a" "$temp_lib_dir/libmpfr.a"
    ln -sf "$MPC_LIBDIR/libmpc-$platform-$arch.a" "$temp_lib_dir/libmpc.a"
    ln -sf "$FLINT_LIBDIR/libflint-$platform-$arch.a" "$temp_lib_dir/libflint.a"
    
    export CC=$(xcrun --sdk $platform -f clang); export CXX=$(xcrun --sdk $platform -f clang++)
    local host_arch=$arch; if [[ "$arch" == "arm64" ]]; then host_arch="aarch64"; fi
    
    local cmake_args=""
    if [[ "$platform" == "iphonesimulator" ]]; then
        cmake_args="-DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=$sdkpath -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOSVERSIONMIN -DCMAKE_OSX_ARCHITECTURES=$arch"
        export CFLAGS="-arch $arch -pipe -Os -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN"
        export CXXFLAGS="-arch $arch -pipe -Os -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN -std=c++11"
    else
        cmake_args="-DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT=$sdkpath -DCMAKE_OSX_DEPLOYMENT_TARGET=$IOSVERSIONMIN -DCMAKE_OSX_ARCHITECTURES=$arch"
        export CFLAGS="-arch $arch -pipe -Os -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN"
        export CXXFLAGS="-arch $arch -pipe -Os -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN -std=c++11"
    fi

    # Using the policy flag you confirmed works
    cmake_args="$cmake_args -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_IOS_INSTALL_COMBINED=NO"
    export LDFLAGS="-L$temp_lib_dir"
    
    logMsg "Running CMake configure..."
    cmake "$SYMENGINE_SOURCE" $cmake_args -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
        -DWITH_GMP=ON -DWITH_MPFR=ON -DWITH_MPC=ON -DWITH_FLINT=ON -DINTEGER_CLASS=flint \
        -DWITH_SYMENGINE_THREAD_SAFE=OFF -DWITH_LLVM=OFF -DWITH_TCMALLOC=OFF \
        -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF \
        -DGMP_INCLUDE_DIR="$GMP_HEADERS_DIR" -DGMP_LIBRARY="$temp_lib_dir/libgmp.a" \
        -DMPFR_INCLUDE_DIR="$MPFR_HEADERS_DIR" -DMPFR_LIBRARY="$temp_lib_dir/libmpfr.a" \
        -DMPC_INCLUDE_DIR="$MPC_HEADERS_DIR" -DMPC_LIBRARY="$temp_lib_dir/libmpc.a" \
        -DFLINT_INCLUDE_DIR="$FLINT_HEADERS_DIR" -DFLINT_LIBRARY="$temp_lib_dir/libflint.a"
    
    logMsg "Building SymEngine for $platform $arch..."; make -j$(sysctl -n hw.ncpu)
    
    logMsg "Copying built SymEngine library..."
    [ -d "$LIBDIR" ] || mkdir -p "$LIBDIR"
    # FIX: Copy from the 'symengine' subdirectory instead of 'lib'
    cp "symengine/lib$LIBNAME.a" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
}

createFramework() {
    local FRAMEWORK_NAME="SymEngine"; local FRAMEWORK_DIR="$SCRIPTDIR/$FRAMEWORK_NAME.xcframework"; local HEADERS_DIR="$SYMENGINE_SOURCE"
    logMsg "================================================================="
    logMsg "Creating SymEngine XCFramework"
    logMsg "================================================================="
    rm -rf "$FRAMEWORK_DIR";
    mkdir -p "$FRAMEWORK_DIR/ios-arm64/symengine" "$FRAMEWORK_DIR/ios-arm64-simulator/symengine" "$FRAMEWORK_DIR/ios-x86_64-simulator/symengine"
    cp "$LIBDIR/lib$LIBNAME-iphoneos-arm64.a" "$FRAMEWORK_DIR/ios-arm64/lib$LIBNAME.a"
    cp -r "$HEADERS_DIR/symengine/"*.h "$FRAMEWORK_DIR/ios-arm64/symengine/" 2>/dev/null || true
    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a" "$FRAMEWORK_DIR/ios-arm64-simulator/lib$LIBNAME.a"
    cp -r "$HEADERS_DIR/symengine/"*.h "$FRAMEWORK_DIR/ios-arm64-simulator/symengine/" 2>/dev/null || true
    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" "$FRAMEWORK_DIR/ios-x86_64-simulator/lib$LIBNAME.a"
    cp -r "$HEADERS_DIR/symengine/"*.h "$FRAMEWORK_DIR/ios-x86_64-simulator/symengine/" 2>/dev/null || true
    logMsg "Generating Info.plist..."
    cat > "$FRAMEWORK_DIR/Info.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>AvailableLibraries</key><array><dict><key>LibraryIdentifier</key><string>ios-arm64</string><key>LibraryPath</key><string>lib$LIBNAME.a</string><key>HeadersPath</key><string>.</string><key>SupportedArchitectures</key><array><string>arm64</string></array><key>SupportedPlatform</key><string>ios</string></dict><dict><key>LibraryIdentifier</key><string>ios-arm64-simulator</string><key>LibraryPath</key><string>lib$LIBNAME.a</string><key>HeadersPath</key><string>.</string><key>SupportedArchitectures</key><array><string>arm64</string></array><key>SupportedPlatform</key><string>ios</string><key>SupportedPlatformVariant</key><string>simulator</string></dict><dict><key>LibraryIdentifier</key><string>ios-x86_64-simulator</string><key>LibraryPath</key><string>lib$LIBNAME.a</string><key>HeadersPath</key><string>.</string><key>SupportedArchitectures</key><array><string>x86_64</string></array><key>SupportedPlatform</key><string>ios</string><key>SupportedPlatformVariant</key><string>simulator</string></dict></array><key>CFBundlePackageType</key><string>XFWK</string><key>XCFrameworkFormatVersion</key><string>1.0</string></dict></plist>
EOL
    logMsg "Successfully created $FRAMEWORK_DIR"
}

# --- Main Build Logic ---
logMsg "Starting SymEngine build for iOS..."
checkCMake
checkDependencies
setupIncludeDirectories
downloadSymEngine
if [ -d "$BUILDDIR" ]; then rm -rf "$BUILDDIR"; fi
logMsg "--- Building SymEngine for iOS Device ---"
for ARCH in $DEVARCHS; do configureAndMake "iphoneos" $ARCH; done
logMsg "--- Building SymEngine for iOS Simulator ---"
for ARCH in $SIMARCHS; do configureAndMake "iphonesimulator" $ARCH; done
createFramework
logMsg "🎉 SymEngine build process completed successfully!"
exit 0