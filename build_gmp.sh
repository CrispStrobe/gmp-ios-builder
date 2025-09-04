#!/bin/bash
#############################################################################
#
# build_gmp.sh
#
# Creates a GMP.xcframework with universal binaries for iOS device,
# iOS simulator (x86_64, arm64), and macOS (x86_64, arm64).
# This script correctly handles cross-compilation environments to avoid
# configuration errors and build warnings.
#
#############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
# VVVV DIRECTORY NAME CHANGED HERE VVVV
readonly BUILDDIR="$SCRIPTDIR/build-gmp"
readonly LIBDIR="$BUILDDIR/lib"
readonly HEADERDIR="$BUILDDIR/include"
readonly LIBNAME="gmp"
readonly VERSION="6.3.0"
readonly SOFTWARETAR="$SCRIPTDIR/$LIBNAME-$VERSION.tar.bz2"

# Architectures for physical iOS devices.
readonly DEVARCHS="arm64"
# Architectures for the iOS simulator.
readonly SIMARCHS="x86_64 arm64"
# Architectures for macOS.
readonly MACARCHS="x86_64 arm64"

# Minimum deployment targets.
readonly IOS_MIN_VERSION="13.0"
readonly MACOS_MIN_VERSION="10.15"

# --- Utility Functions ---

# Executed on script exit for cleanup.
cleanup() {
    echo "[CLEANUP] Build script finished."
}
trap cleanup EXIT

# Log a message to the console.
logMsg() {
    printf "[GMP BUILD] %s\n" "$1"
}

# Log an error and exit.
errorExit() {
    logMsg "❌ ERROR: $1"
    logMsg "Build failed."
    exit 1
}

# --- Core Build Functions ---

# Download and extract the GMP source tarball.
extractSoftware() {
    local extractdir="$BUILDDIR/source"
    logMsg "Creating build directory and extracting source..."
    mkdir -p "$extractdir"

    if [ ! -f "$SOFTWARETAR" ]; then
        errorExit "Software archive not found at '$SOFTWARETAR'. Please download it first."
    fi

    # Use tar to extract the software, stripping the top-level directory.
    tar -xjf "$SOFTWARETAR" -C "$extractdir" --strip-components 1 || errorExit "Failed to extract tarball."
}

# Configure and build GMP for a specific platform and architecture.
configureAndMake() {
    local platform=$1
    local arch=$2
    local extractdir="$BUILDDIR/source"
    
    logMsg "================================================================="
    logMsg "Configuring for PLATFORM: $platform, ARCH: $arch"
    logMsg "================================================================="
    
    # Unset variables to ensure a completely clean state from any previous run.
    unset CC CXX CFLAGS CXXFLAGS LDFLAGS LIBS SDKROOT CC_FOR_BUILD
    
    # --- Define variables locally WITHOUT exporting them ---
    
    local sdkpath
    sdkpath=$(xcrun --sdk "$platform" --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then
        errorExit "SDK path not found for platform '$platform'. Is Xcode installed? Run: xcode-select --install"
    fi
    logMsg "Using SDK: $sdkpath"
    
    local target_cc
    target_cc=$(xcrun --sdk "$platform" -f clang)

    local target_cflags
    local target_ldflags
    
    if [[ "$platform" == "iphoneos" ]]; then
        target_cflags="-arch $arch -pipe -Os -isysroot $sdkpath -miphoneos-version-min=$IOS_MIN_VERSION"
        target_ldflags="-arch $arch -isysroot $sdkpath -miphoneos-version-min=$IOS_MIN_VERSION"
    elif [[ "$platform" == "iphonesimulator" ]]; then
        target_cflags="-arch $arch -pipe -Os -isysroot $sdkpath -mios-simulator-version-min=$IOS_MIN_VERSION"
        target_ldflags="-arch $arch -isysroot $sdkpath -mios-simulator-version-min=$IOS_MIN_VERSION"
    else # macosx
        target_cflags="-arch $arch -pipe -Os -isysroot $sdkpath -mmacosx-version-min=$MACOS_MIN_VERSION"
        target_ldflags="-arch $arch -isysroot $sdkpath -mmacosx-version-min=$MACOS_MIN_VERSION"
    fi
    
    cd "$extractdir"
    
    make distclean &> /dev/null || true
    
    local host_triplet
    host_triplet=$( [[ "$arch" == "arm64" ]] && echo "aarch64" || echo "$arch" )-apple-darwin

    local configure_args=(
        "--host=$host_triplet"
        "--disable-assembly"
        "--enable-static"
        "--disable-shared"
    )

    # --- Prepare environment variables for the configure command ---
    local build_cc="/usr/bin/clang"
    local build_host_triplet
    
    # For cross-compilation, define the build machine environment.
    if [[ "$platform" != "macosx" ]]; then
        build_host_triplet=$(uname -m)-apple-darwin
        configure_args+=( "--build=$build_host_triplet" )
        
        logMsg "Configuring with (Cross-Compilation):"
        logMsg "  CC_FOR_BUILD: $build_cc"
        logMsg "  BUILD_HOST:   $build_host_triplet"
    else
        logMsg "Configuring with (Native Compilation):"
    fi

    logMsg "  TARGET_HOST:  $host_triplet"
    logMsg "  CC (target):  $target_cc"
    logMsg "  CFLAGS:       $target_cflags"
    logMsg "  LDFLAGS:      $target_ldflags"
    
    # *** KEY CHANGE HERE ***
    # Pass environment variables on the SAME LINE as the command.
    # This prevents them from leaking into the sub-processes that test CC_FOR_BUILD.
    env \
        CC="$target_cc" \
        CFLAGS="$target_cflags" \
        LDFLAGS="$target_ldflags" \
        CC_FOR_BUILD="$build_cc" \
        ./configure "${configure_args[@]}"

    logMsg "Building GMP for $platform $arch..."
    make -j"$(sysctl -n hw.ncpu)"
    
    logMsg "Installing built library and headers..."
    make install DESTDIR="$BUILDDIR/install-$platform-$arch"
    
    # Copy the static library to our central library directory.
    mkdir -p "$LIBDIR"
    cp "$BUILDDIR/install-$platform-$arch/usr/local/lib/lib$LIBNAME.a" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
}

# Create the final XCFramework from the built static libraries.
createXCFramework() {
    local framework_name="GMP"
    local framework_dir="$SCRIPTDIR/$framework_name.xcframework"
    logMsg "Creating $framework_name.xcframework..."
    rm -rf "$framework_dir"

    # Define source library paths
    local device_lib="$LIBDIR/lib$LIBNAME-iphoneos-arm64.a"
    local sim_universal_lib="$LIBDIR/lib$LIBNAME-iphonesimulator-universal.a"
    local mac_universal_lib="$LIBDIR/lib$LIBNAME-macosx-universal.a"
    
    # Create universal "fat" libs for simulator and macOS
    lipo -create -output "$sim_universal_lib" "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a"
    lipo -create -output "$mac_universal_lib" "$LIBDIR/lib$LIBNAME-macosx-x86_64.a" "$LIBDIR/lib$LIBNAME-macosx-arm64.a"
    
    mkdir -p "$HEADERDIR"; cp "$BUILDDIR/install-iphoneos-arm64/usr/local/include/gmp.h" "$HEADERDIR/"

    # Step 1: Create the XCFramework
    xcodebuild -create-xcframework \
        -library "$device_lib" -headers "$HEADERDIR" \
        -library "$sim_universal_lib" -headers "$HEADERDIR" \
        -library "$mac_universal_lib" -headers "$HEADERDIR" \
        -output "$framework_dir"

    # Step 2: Patch the XCFramework for CocoaPods compatibility
    logMsg "Patching generated framework..."
    
    # Rename the binaries inside each slice to be consistent
    mv "$framework_dir/ios-arm64/libgmp-iphoneos-arm64.a" "$framework_dir/ios-arm64/$framework_name"
    mv "$framework_dir/ios-arm64_x86_64-simulator/libgmp-iphonesimulator-universal.a" "$framework_dir/ios-arm64_x86_64-simulator/$framework_name"
    mv "$framework_dir/macos-arm64_x86_64/libgmp-macosx-universal.a" "$framework_dir/macos-arm64_x86_64/$framework_name"

    # Edit the manifest (Info.plist) to reflect the new binary names
    local PLIST_PATH="$framework_dir/Info.plist"
    local COUNT=$(/usr/libexec/PlistBuddy -c "Print :AvailableLibraries:" "$PLIST_PATH" | grep -c "Dict")
    for (( i=0; i<$COUNT; i++ )); do
        /usr/libexec/PlistBuddy -c "Set :AvailableLibraries:$i:BinaryPath $framework_name" "$PLIST_PATH"
        /usr/libexec/PlistBuddy -c "Set :AvailableLibraries:$i:LibraryPath $framework_name" "$PLIST_PATH"
    done
    
    logMsg "✅ Successfully created and patched $framework_dir"
}

# --- Main Build Logic ---

logMsg "Starting GMP build for iOS and macOS..."

# Clean up previous build artifacts.
if [ -d "$BUILDDIR" ]; then
    logMsg "Cleaning old build directory..."
    rm -rf "$BUILDDIR"
fi

extractSoftware

logMsg "--- Building for iOS Device ---"
for arch in $DEVARCHS; do
    configureAndMake "iphoneos" "$arch"
done

logMsg "--- Building for iOS Simulator ---"
for arch in $SIMARCHS; do
    configureAndMake "iphonesimulator" "$arch"
done

logMsg "--- Building for macOS ---"
for arch in $MACARCHS; do
    configureAndMake "macosx" "$arch"
done

createXCFramework

logMsg "🚀 GMP build process completed successfully!"
exit 0