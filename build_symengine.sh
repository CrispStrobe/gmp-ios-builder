#!/bin/bash
############################################################################
#
# build_symengine.sh (Corrected & Robust Version)
#
# Build script for SymEngine for iOS, Simulator, and macOS,
# creating a single, robust XCFramework.
#
############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
readonly BUILDDIR="$SCRIPTDIR/build-symengine"
readonly LIBDIR="$BUILDDIR/lib"
readonly HEADERDIR_FINAL="$BUILDDIR/include" # Central location for final headers
readonly LIBNAME="symengine"
readonly VERSION_SYMENGINE="0.11.2"
readonly SYMENGINE_SOURCE="$SCRIPTDIR/symengine-$VERSION_SYMENGINE"

# Dependency paths (assuming they are in the same parent directory)
readonly GMP_BUILDDIR="$SCRIPTDIR/build"
readonly MPFR_BUILDDIR="$SCRIPTDIR/build-mpfr"
readonly MPC_BUILDDIR="$SCRIPTDIR/build-mpc"
readonly FLINT_BUILDDIR="$SCRIPTDIR/build-flint"

# Architectures
readonly DEVARCHS="arm64"
readonly SIMARCHS="x86_64 arm64"
readonly MACARCHS="x86_64 arm64"

# Minimum deployment targets
readonly IOS_MIN_VERSION="13.0"
readonly MACOS_MIN_VERSION="10.15"

# --- Utility Functions ---
cleanup() { echo "[CLEANUP] SymEngine build script finished."; }
trap cleanup EXIT

logMsg() { printf "[SYMENGINE BUILD] %s\n" "$1"; }
errorExit() { logMsg "❌ ERROR: $1"; logMsg "Build failed."; exit 1; }

# --- Prerequisite Checks & Setup ---

# Checks if CMake is installed.
checkCMake() {
    if ! command -v cmake &> /dev/null; then
        errorExit "CMake not found. Please run: brew install cmake"
    fi
    logMsg "✅ CMake found: $(cmake --version | head -1)"
}

# Verifies that dependency build directories exist.
checkDependencies() {
    logMsg "Checking for dependency build directories..."
    for dep_dir in "$GMP_BUILDDIR" "$MPFR_BUILDDIR" "$MPC_BUILDDIR" "$FLINT_BUILDDIR"; do
        if [ ! -d "$dep_dir" ]; then
            errorExit "Dependency directory '$dep_dir' not found. Please build all dependencies first."
        fi
    done
    logMsg "✅ All dependency directories found."
}

# Downloads and extracts the SymEngine source code if not present.
downloadSymEngine() {
    if [ -d "$SYMENGINE_SOURCE" ]; then return; fi
    logMsg "Downloading SymEngine v$VERSION_SYMENGINE..."
    local tarball="$SCRIPTDIR/symengine-$VERSION_SYMENGINE.tar.gz"
    curl -L -o "$tarball" "https://github.com/symengine/symengine/archive/v$VERSION_SYMENGINE.tar.gz"
    tar -xzf "$tarball" -C "$SCRIPTDIR"
    rm "$tarball"
    if [ ! -d "$SYMENGINE_SOURCE" ]; then errorExit "Failed to extract SymEngine source"; fi
}

# --- Core Build Functions ---

# Configure and build SymEngine for a specific platform and architecture.
configureAndMake() {
    local platform=$1
    local arch=$2
    local build_dir="$BUILDDIR/$platform-$arch"

    logMsg "================================================================="
    logMsg "Configuring SymEngine for PLATFORM: $platform, ARCH: $arch"
    logMsg "================================================================="

    # Find the correct SDK path.
    local sdkpath
    sdkpath=$(xcrun --sdk "$platform" --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then errorExit "SDK path not found for platform '$platform'."; fi

    # Create a clean build directory.
    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"

    # --- Prepare dependency libraries for this specific build ---
    local temp_lib_dir="$build_dir/temp-deps"
    mkdir -p "$temp_lib_dir"
    ln -sf "$GMP_BUILDDIR/lib/libgmp-$platform-$arch.a" "$temp_lib_dir/libgmp.a"
    ln -sf "$MPFR_BUILDDIR/lib/libmpfr-$platform-$arch.a" "$temp_lib_dir/libmpfr.a"
    ln -sf "$MPC_BUILDDIR/lib/libmpc-$platform-$arch.a" "$temp_lib_dir/libmpc.a"
    ln -sf "$FLINT_BUILDDIR/lib/libflint-$platform-$arch.a" "$temp_lib_dir/libflint.a"

    # --- Define CMake arguments WITHOUT using export ---
    local cmake_args=()

    # Common CMake settings for all platforms.
    cmake_args+=(
        # *** KEY CHANGE HERE: Add the required policy flag back in ***
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DBUILD_SHARED_LIBS=OFF"
        "-DWITH_GMP=ON"
        "-DWITH_MPFR=ON"
        "-DWITH_MPC=ON"
        "-DWITH_FLINT=ON"
        "-DINTEGER_CLASS=flint"
        "-DWITH_SYMENGINE_THREAD_SAFE=OFF"
        "-DWITH_LLVM=OFF"
        "-DWITH_TCMALLOC=OFF"
        "-DBUILD_TESTS=OFF"
        "-DBUILD_BENCHMARKS=OFF"
        "-DGMP_INCLUDE_DIR=$GMP_BUILDDIR/include"
        "-DGMP_LIBRARY=$temp_lib_dir/libgmp.a"
        "-DMPFR_INCLUDE_DIR=$MPFR_BUILDDIR/include"
        "-DMPFR_LIBRARY=$temp_lib_dir/libmpfr.a"
        "-DMPC_INCLUDE_DIR=$MPC_BUILDDIR/include"
        "-DMPC_LIBRARY=$temp_lib_dir/libmpc.a"
        "-DFLINT_INCLUDE_DIR=$FLINT_BUILDDIR/include"
        "-DFLINT_LIBRARY=$temp_lib_dir/libflint.a"
    )

    # Platform-specific CMake settings.
    if [[ "$platform" == "iphoneos" ]] || [[ "$platform" == "iphonesimulator" ]]; then
        cmake_args+=(
            "-DCMAKE_SYSTEM_NAME=iOS"
            "-DCMAKE_OSX_ARCHITECTURES=$arch"
            "-DCMAKE_OSX_SYSROOT=$sdkpath"
            "-DCMAKE_OSX_DEPLOYMENT_TARGET=$IOS_MIN_VERSION"
        )
    else # macosx
        cmake_args+=(
            "-DCMAKE_OSX_ARCHITECTURES=$arch"
            "-DCMAKE_OSX_SYSROOT=$sdkpath"
            "-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_MIN_VERSION"
        )
    fi

    logMsg "Running CMake configure..."
    cmake "$SYMENGINE_SOURCE" \
        -DCMAKE_C_COMPILER="$(xcrun --sdk "$platform" -f clang)" \
        -DCMAKE_CXX_COMPILER="$(xcrun --sdk "$platform" -f clang++)" \
        "${cmake_args[@]}"

    logMsg "Building SymEngine for $platform $arch..."
    make -j"$(sysctl -n hw.ncpu)"

    # The library is usually found in a sub-directory, find it robustly.
    local found_lib
    found_lib=$(find . -name "lib$LIBNAME.a" -type f | head -1)
    if [ -z "$found_lib" ]; then
        errorExit "Could not find built SymEngine library (lib$LIBNAME.a) in '$build_dir'."
    fi
    logMsg "Found SymEngine library at: $found_lib"

    logMsg "Copying built SymEngine library..."
    mkdir -p "$LIBDIR"
    cp "$found_lib" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
}

# Create the final XCFramework from the built static libraries.
createXCFramework() {
    local framework_name="SymEngine"
    local framework_dir="$SCRIPTDIR/$framework_name.xcframework"

    logMsg "================================================================="
    logMsg "Creating $framework_name.xcframework"
    logMsg "================================================================="

    rm -rf "$framework_dir"

    # Create universal "fat" libraries for simulator and macOS.
    logMsg "Creating universal simulator library..."
    local sim_universal_lib="$LIBDIR/lib$LIBNAME-iphonesimulator-universal.a"
    lipo -create -output "$sim_universal_lib" \
        "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" \
        "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a"

    logMsg "Creating universal macOS library..."
    local mac_universal_lib="$LIBDIR/lib$LIBNAME-macosx-universal.a"
    lipo -create -output "$mac_universal_lib" \
        "$LIBDIR/lib$LIBNAME-macosx-x86_64.a" \
        "$LIBDIR/lib$LIBNAME-macosx-arm64.a"

    # SymEngine headers are nested. We must copy them to a single include directory.
    logMsg "Gathering SymEngine headers..."
    rm -rf "$HEADERDIR_FINAL"
    mkdir -p "$HEADERDIR_FINAL"
    cp -R "$SYMENGINE_SOURCE/symengine" "$HEADERDIR_FINAL/"

    # *** KEY CHANGE HERE ***
    # Use xcodebuild to create the XCFramework. This is the modern, reliable method.
    logMsg "Assembling XCFramework..."
    xcodebuild -create-xcframework \
        -library "$LIBDIR/lib$LIBNAME-iphoneos-arm64.a" \
        -headers "$HEADERDIR_FINAL" \
        -library "$sim_universal_lib" \
        -headers "$HEADERDIR_FINAL" \
        -library "$mac_universal_lib" \
        -headers "$HEADERDIR_FINAL" \
        -output "$framework_dir"

    logMsg "✅ Successfully created $framework_dir"
}

# --- Main Build Logic ---
logMsg "Starting SymEngine build..."

checkCMake
checkDependencies
downloadSymEngine

if [ -d "$BUILDDIR" ]; then rm -rf "$BUILDDIR"; fi

logMsg "--- Building SymEngine for iOS Device ---"
for ARCH in $DEVARCHS; do configureAndMake "iphoneos" "$ARCH"; done

logMsg "--- Building SymEngine for iOS Simulator ---"
for ARCH in $SIMARCHS; do configureAndMake "iphonesimulator" "$ARCH"; done

logMsg "--- Building SymEngine for macOS ---"
for ARCH in $MACARCHS; do configureAndMake "macosx" "$ARCH"; done

createXCFramework

logMsg "🚀 SymEngine build process completed successfully!"
exit 0