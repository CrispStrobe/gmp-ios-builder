#!/bin/bash
############################################################################
#
# build_symengine.sh (SINGLE COMPILATION POINT - includes Flutter wrapper)
#
############################################################################
set -e

# --- Configuration ---
readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
readonly BUILDDIR="$SCRIPTDIR/build-symengine"
readonly LIBDIR="$BUILDDIR/lib"
readonly HEADERDIR_FINAL="$BUILDDIR/include"
readonly LIBNAME="symengine"
readonly VERSION_SYMENGINE="0.11.2"
readonly SYMENGINE_SOURCE="$SCRIPTDIR/symengine-$VERSION_SYMENGINE"

# Flutter wrapper source directory
readonly FLUTTER_WRAPPER_SRC="$SCRIPTDIR/src"

# Dependency paths
readonly GMP_BUILDDIR="$SCRIPTDIR/build-gmp"
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

checkCMake() {
    if ! command -v cmake &> /dev/null; then
        errorExit "CMake not found. Please run: brew install cmake"
    fi
    logMsg "✅ CMake found: $(cmake --version | head -1)"
}

checkDependencies() {
    logMsg "Checking for dependency build directories..."
    for dep_dir in "$GMP_BUILDDIR" "$MPFR_BUILDDIR" "$MPC_BUILDDIR" "$FLINT_BUILDDIR"; do
        if [ ! -d "$dep_dir" ]; then
            errorExit "Dependency directory '$dep_dir' not found. Please build all dependencies first."
        fi
    done
    logMsg "✅ All dependency directories found."
}

checkFlutterWrapperSource() {
    logMsg "Checking for Flutter wrapper source files..."
    if [ ! -f "$FLUTTER_WRAPPER_SRC/flutter_symengine_wrapper.h" ]; then
        errorExit "Flutter wrapper header not found: $FLUTTER_WRAPPER_SRC/flutter_symengine_wrapper.h"
    fi
    if [ ! -f "$FLUTTER_WRAPPER_SRC/flutter_symengine_wrapper.c" ]; then
        errorExit "Flutter wrapper source not found: $FLUTTER_WRAPPER_SRC/flutter_symengine_wrapper.c"
    fi
    logMsg "✅ Flutter wrapper source files found."
}

downloadSymEngine() {
    if [ -d "$SYMENGINE_SOURCE" ]; then return; fi
    logMsg "Downloading SymEngine v$VERSION_SYMENGINE..."
    local tarball="$SCRIPTDIR/symengine-$VERSION_SYMENGINE.tar.gz"
    if [ ! -f "$tarball" ]; then
        curl -L -o "$tarball" "https://github.com/symengine/symengine/archive/v$VERSION_SYMENGINE.tar.gz"
    fi
    tar -xzf "$tarball" -C "$SCRIPTDIR"
    if [ ! -d "$SYMENGINE_SOURCE" ]; then errorExit "Failed to extract SymEngine source"; fi
}

# Copy Flutter wrapper source files to build directory
copyFlutterWrapperToDir() {
    local target_dir="$1"
    mkdir -p "$target_dir"
    
    logMsg "Copying Flutter wrapper source files to $target_dir"
    cp "$FLUTTER_WRAPPER_SRC/flutter_symengine_wrapper.h" "$target_dir/"
    cp "$FLUTTER_WRAPPER_SRC/flutter_symengine_wrapper.c" "$target_dir/"
    
    logMsg "✅ Copied Flutter wrapper source files to $target_dir"
}

configureAndMake() {
    local platform=$1
    local arch=$2
    local build_dir="$BUILDDIR/$platform-$arch"

    logMsg "================================================================="
    logMsg "Configuring SymEngine + Flutter Wrapper for PLATFORM: $platform, ARCH: $arch"
    logMsg "================================================================="

    local sdkpath
    sdkpath=$(xcrun --sdk "$platform" --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then errorExit "SDK path not found for platform '$platform'."; fi

    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"

    # Copy Flutter wrapper source files to this build directory
    copyFlutterWrapperToDir "$build_dir"

    local temp_lib_dir="$build_dir/temp-deps"
    mkdir -p "$temp_lib_dir"
    ln -sf "$GMP_BUILDDIR/lib/libgmp-$platform-$arch.a" "$temp_lib_dir/libgmp.a"
    ln -sf "$MPFR_BUILDDIR/lib/libmpfr-$platform-$arch.a" "$temp_lib_dir/libmpfr.a"
    ln -sf "$MPC_BUILDDIR/lib/libmpc-$platform-$arch.a" "$temp_lib_dir/libmpc.a"
    ln -sf "$FLINT_BUILDDIR/lib/libflint-$platform-$arch.a" "$temp_lib_dir/libflint.a"

    local cmake_args=()
    cmake_args+=(
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
        "-DBUILD_SHARED_LIBS=OFF"
        "-DWITH_GMP=ON" "-DWITH_MPFR=ON" "-DWITH_MPC=ON" "-DWITH_FLINT=ON"
        "-DINTEGER_CLASS=flint"
        "-DWITH_SYMENGINE_THREAD_SAFE=OFF" "-DWITH_LLVM=OFF" "-DWITH_TCMALLOC=OFF"
        "-DBUILD_TESTS=OFF" "-DBUILD_BENCHMARKS=OFF"
        "-DGMP_INCLUDE_DIR=$GMP_BUILDDIR/include"
        "-DGMP_LIBRARY=$temp_lib_dir/libgmp.a"
        "-DMPFR_INCLUDE_DIR=$MPFR_BUILDDIR/include"
        "-DMPFR_LIBRARY=$temp_lib_dir/libmpfr.a"
        "-DMPC_INCLUDE_DIR=$MPC_BUILDDIR/include"
        "-DMPC_LIBRARY=$temp_lib_dir/libmpc.a"
        "-DFLINT_INCLUDE_DIR=$FLINT_BUILDDIR/include"
        "-DFLINT_LIBRARY=$temp_lib_dir/libflint.a"
    )

    if [[ "$platform" == "iphoneos" ]] || [[ "$platform" == "iphonesimulator" ]]; then
        cmake_args+=( "-DCMAKE_SYSTEM_NAME=iOS" "-DCMAKE_OSX_ARCHITECTURES=$arch" "-DCMAKE_OSX_SYSROOT=$sdkpath" "-DCMAKE_OSX_DEPLOYMENT_TARGET=$IOS_MIN_VERSION" )
    else # macosx
        cmake_args+=( "-DCMAKE_OSX_ARCHITECTURES=$arch" "-DCMAKE_OSX_SYSROOT=$sdkpath" "-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOS_MIN_VERSION" )
    fi

    logMsg "Running CMake configure for SymEngine..."
    cmake "$SYMENGINE_SOURCE" \
        -DCMAKE_C_COMPILER="$(xcrun --sdk "$platform" -f clang)" \
        -DCMAKE_CXX_COMPILER="$(xcrun --sdk "$platform" -f clang++)" \
        "${cmake_args[@]}"

    logMsg "Building SymEngine for $platform $arch..."
    make -j"$(sysctl -n hw.ncpu)"

    # Now compile our Flutter wrapper against the built SymEngine
    logMsg "Building Flutter wrapper against SymEngine..."
    local target_cc
    target_cc=$(xcrun --sdk "$platform" -f clang)
    
    local target_cflags
    if [[ "$platform" == "iphoneos" ]]; then
        target_cflags="-arch $arch -isysroot $sdkpath -miphoneos-version-min=$IOS_MIN_VERSION"
    elif [[ "$platform" == "iphonesimulator" ]]; then
        target_cflags="-arch $arch -isysroot $sdkpath -mios-simulator-version-min=$IOS_MIN_VERSION"
    else # macosx
        target_cflags="-arch $arch -isysroot $sdkpath -mmacosx-version-min=$MACOS_MIN_VERSION"
    fi
    
    # Add include paths for SymEngine and all dependencies
    target_cflags="$target_cflags -I$SYMENGINE_SOURCE -I$build_dir"
    target_cflags="$target_cflags -I$GMP_BUILDDIR/include"
    target_cflags="$target_cflags -I$MPFR_BUILDDIR/include"  
    target_cflags="$target_cflags -I$MPC_BUILDDIR/include"
    target_cflags="$target_cflags -I$FLINT_BUILDDIR/include"
    
    # Verify files exist before compiling
    if [ ! -f "flutter_symengine_wrapper.c" ]; then
        errorExit "Flutter wrapper source file not found in $build_dir"
    fi
    
    # Compile Flutter wrapper
    "$target_cc" $target_cflags -c "flutter_symengine_wrapper.c" -o "flutter_symengine_wrapper.o"
    
    # Find the built SymEngine library
    local found_lib
    found_lib=$(find . -name "lib$LIBNAME.a" -type f | head -1)
    if [ -z "$found_lib" ]; then
        errorExit "Could not find built SymEngine library (lib$LIBNAME.a) in '$build_dir'."
    fi

    logMsg "Creating combined library with Flutter wrapper..."
    # Create a combined library that includes both SymEngine and our Flutter wrapper
    mkdir -p temp_extract
    cd temp_extract
    ar x "../$found_lib"
    cp "../flutter_symengine_wrapper.o" .
    ar rcs "../libsymengine_flutter_wrapper.a" *.o
    cd ..
    rm -rf temp_extract

    logMsg "Copying built library..."
    mkdir -p "$LIBDIR"
    cp "libsymengine_flutter_wrapper.a" "$LIBDIR/libsymengine_flutter_wrapper-$platform-$arch.a"
}

createFlutterWrapperXCFramework() {
    local framework_name="SymEngineFlutterWrapper"
    local framework_dir="$SCRIPTDIR/$framework_name.xcframework"

    logMsg "================================================================="
    logMsg "Creating $framework_name.xcframework"
    logMsg "================================================================="

    rm -rf "$framework_dir"

    # Define source library paths
    local device_lib="$LIBDIR/libsymengine_flutter_wrapper-iphoneos-arm64.a"
    local sim_universal_lib="$LIBDIR/libsymengine_flutter_wrapper-iphonesimulator-universal.a"
    local mac_universal_lib="$LIBDIR/libsymengine_flutter_wrapper-macosx-universal.a"
    
    # Create universal "fat" libraries for simulator and macOS.
    logMsg "Creating universal libraries..."
    lipo -create -output "$sim_universal_lib" \
        "$LIBDIR/libsymengine_flutter_wrapper-iphonesimulator-x86_64.a" \
        "$LIBDIR/libsymengine_flutter_wrapper-iphonesimulator-arm64.a"

    lipo -create -output "$mac_universal_lib" \
        "$LIBDIR/libsymengine_flutter_wrapper-macosx-x86_64.a" \
        "$LIBDIR/libsymengine_flutter_wrapper-macosx-arm64.a"

    # Set up headers
    logMsg "Setting up headers..."
    rm -rf "$HEADERDIR_FINAL"
    mkdir -p "$HEADERDIR_FINAL"
    cp "$FLUTTER_WRAPPER_SRC/flutter_symengine_wrapper.h" "$HEADERDIR_FINAL/"

    # Create the XCFramework
    logMsg "Assembling XCFramework..."
    xcodebuild -create-xcframework \
        -library "$device_lib" -headers "$HEADERDIR_FINAL" \
        -library "$sim_universal_lib" -headers "$HEADERDIR_FINAL" \
        -library "$mac_universal_lib" -headers "$HEADERDIR_FINAL" \
        -output "$framework_dir"

    # Patch for CocoaPods compatibility
    logMsg "Patching framework for CocoaPods compatibility..."
    mv "$framework_dir/ios-arm64/libsymengine_flutter_wrapper-iphoneos-arm64.a" "$framework_dir/ios-arm64/$framework_name"
    mv "$framework_dir/ios-arm64_x86_64-simulator/libsymengine_flutter_wrapper-iphonesimulator-universal.a" "$framework_dir/ios-arm64_x86_64-simulator/$framework_name"
    mv "$framework_dir/macos-arm64_x86_64/libsymengine_flutter_wrapper-macosx-universal.a" "$framework_dir/macos-arm64_x86_64/$framework_name"

    # Edit the manifest
    local PLIST_PATH="$framework_dir/Info.plist"
    local COUNT=$(/usr/libexec/PlistBuddy -c "Print :AvailableLibraries:" "$PLIST_PATH" | grep -c "Dict")
    for (( i=0; i<$COUNT; i++ )); do
        /usr/libexec/PlistBuddy -c "Set :AvailableLibraries:$i:BinaryPath $framework_name" "$PLIST_PATH"
        /usr/libexec/PlistBuddy -c "Set :AvailableLibraries:$i:LibraryPath $framework_name" "$PLIST_PATH"
    done
    
    logMsg "✅ Successfully created $framework_dir"
}

# --- Main Build Logic ---
logMsg "Starting SymEngine + Flutter wrapper build (SINGLE COMPILATION POINT)..."

checkCMake
checkDependencies
checkFlutterWrapperSource
downloadSymEngine

if [ -d "$BUILDDIR" ]; then rm -rf "$BUILDDIR"; fi

logMsg "--- Building SymEngine + Flutter Wrapper for iOS Device ---"
for ARCH in $DEVARCHS; do configureAndMake "iphoneos" "$ARCH"; done

logMsg "--- Building SymEngine + Flutter Wrapper for iOS Simulator ---"
for ARCH in $SIMARCHS; do configureAndMake "iphonesimulator" "$ARCH"; done

logMsg "--- Building SymEngine + Flutter Wrapper for macOS ---"
for ARCH in $MACARCHS; do configureAndMake "macosx" "$ARCH"; done

createFlutterWrapperXCFramework

logMsg "🚀 SymEngine + Flutter wrapper build process completed successfully!"
exit 0