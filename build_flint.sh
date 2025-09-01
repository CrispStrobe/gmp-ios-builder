#!/bin/bash
############################################################################
#
# build_flint.sh 
#
# Builds the FLINT library by using the native 'make install' step to
# reliably collect headers and libraries, creating a clean XCFramework.
#
############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
readonly BUILDDIR="$SCRIPTDIR/build-flint"
readonly LIBDIR="$BUILDDIR/lib"
readonly HEADERDIR="$BUILDDIR/include"
readonly LIBNAME="flint"
readonly VERSION="3.3.1"
readonly SOFTWARETAR="$SCRIPTDIR/$LIBNAME-$VERSION.tar.gz"

# --- Dependency Paths (MUST be built first) ---
readonly GMP_BUILDDIR="$SCRIPTDIR/build"
readonly GMP_LIBDIR="$GMP_BUILDDIR/lib"
readonly GMP_HEADERS_DIR="$GMP_BUILDDIR/include"

readonly MPFR_BUILDDIR="$SCRIPTDIR/build-mpfr"
readonly MPFR_LIBDIR="$MPFR_BUILDDIR/lib"
readonly MPFR_HEADERS_DIR="$MPFR_BUILDDIR/include"

# --- Architectures & Deployment Targets ---
readonly DEVARCHS="arm64"
readonly SIMARCHS="x86_64 arm64"
readonly MACARCHS="x86_64 arm64"

readonly IOS_MIN_VERSION="13.0"
readonly MACOS_MIN_VERSION="10.15"

# --- Utility Functions ---
cleanup() { echo "[CLEANUP] FLINT build script finished."; }
trap cleanup EXIT

logMsg() { printf "[FLINT BUILD] %s\n" "$1"; }
errorExit() { logMsg "❌ ERROR: $1"; logMsg "Build failed."; exit 1; }

# --- Build Functions ---

checkDependencies() {
    logMsg "Checking for pre-built GMP and MPFR dependencies..."
    if [ ! -d "$GMP_BUILDDIR" ]; then errorExit "GMP build directory not found."; fi
    if [ ! -d "$MPFR_BUILDDIR" ]; then errorExit "MPFR build directory not found."; fi
    logMsg "✅ Dependencies found."
}

extractSoftware() {
    local extractdir="$BUILDDIR/source"
    logMsg "Creating build directory and extracting FLINT source..."
    mkdir -p "$extractdir"
    if [ ! -f "$SOFTWARETAR" ]; then errorExit "FLINT archive not found at '$SOFTWARETAR'."; fi
    tar -xzf "$SOFTWARETAR" -C "$extractdir" --strip-components 1 || errorExit "Failed to extract FLINT tarball."
}

configureAndMake() {
    local platform=$1
    local arch=$2
    local extractdir="$BUILDDIR/source"
    
    logMsg "================================================================="
    logMsg "Configuring FLINT for PLATFORM: $platform, ARCH: $arch"
    logMsg "================================================================="
    
    unset CC CXX CFLAGS CXXFLAGS LDFLAGS LIBS SDKROOT CC_FOR_BUILD
    
    local sdkpath=$(xcrun --sdk "$platform" --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then errorExit "SDK path for '$platform' not found."; fi
    
    local target_cc=$(xcrun --sdk "$platform" -f clang)
    local temp_lib_dir="$BUILDDIR/temp-deps-$platform-$arch"
    mkdir -p "$temp_lib_dir"
    ln -sf "$GMP_LIBDIR/libgmp-$platform-$arch.a" "$temp_lib_dir/libgmp.a"
    ln -sf "$MPFR_LIBDIR/libmpfr-$platform-$arch.a" "$temp_lib_dir/libmpfr.a"

    local target_cflags
    local target_ldflags
    
    if [[ "$platform" == "iphoneos" ]]; then
        target_cflags="-arch $arch -pipe -Os -isysroot $sdkpath -miphoneos-version-min=$IOS_MIN_VERSION -I$GMP_HEADERS_DIR -I$MPFR_HEADERS_DIR"
        target_ldflags="-arch $arch -isysroot $sdkpath -miphoneos-version-min=$IOS_MIN_VERSION -L$temp_lib_dir"
    elif [[ "$platform" == "iphonesimulator" ]]; then
        target_cflags="-arch $arch -pipe -Os -isysroot $sdkpath -mios-simulator-version-min=$IOS_MIN_VERSION -I$GMP_HEADERS_DIR -I$MPFR_HEADERS_DIR"
        target_ldflags="-arch $arch -isysroot $sdkpath -mios-simulator-version-min=$IOS_MIN_VERSION -L$temp_lib_dir"
    else # macosx
        target_cflags="-arch $arch -pipe -Os -isysroot $sdkpath -mmacosx-version-min=$MACOS_MIN_VERSION -I$GMP_HEADERS_DIR -I$MPFR_HEADERS_DIR"
        target_ldflags="-arch $arch -isysroot $sdkpath -mmacosx-version-min=$MACOS_MIN_VERSION -L$temp_lib_dir"
    fi
    
    cd "$extractdir"
    make distclean &> /dev/null || true
    
    local host_triplet=$([[ "$arch" == "arm64" ]] && echo "aarch64" || echo "$arch")-apple-darwin
    local configure_args=(
        "--host=$host_triplet"
        "--disable-shared"
        "--enable-static"
        "--disable-assembly"
        "--with-gmp=$GMP_BUILDDIR"
        "--with-mpfr=$MPFR_BUILDDIR"
        "--disable-thread-safe"
    )
    if [[ "$platform" != "macosx" ]]; then
        configure_args+=("--build=$(uname -m)-apple-darwin")
    fi
    
    env CC="$target_cc" CFLAGS="$target_cflags" LDFLAGS="$target_ldflags" LIBS="-lmpfr -lgmp" CC_FOR_BUILD="/usr/bin/clang" \
        ./configure "${configure_args[@]}"

    logMsg "Building FLINT for $platform $arch..."
    make -j"$(sysctl -n hw.ncpu)"
    
    # Use 'make install' to a temporary directory
    # This is our robust way to collect all necessary libraries and headers.
    logMsg "Installing FLINT to temporary location..."
    local install_dir="$BUILDDIR/install-$platform-$arch"
    rm -rf "$install_dir"
    make install DESTDIR="$install_dir"

    logMsg "Copying built FLINT library..."
    mkdir -p "$LIBDIR"
    cp "$install_dir/usr/local/lib/lib$LIBNAME.a" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
    
    rm -rf "$temp_lib_dir"
}

createXCFramework() {
    local framework_name="FLINT"
    local framework_dir="$SCRIPTDIR/$framework_name.xcframework"
    local temp_headers_dir="$BUILDDIR/headers_temp" # Use a temp dir for headers

    logMsg "================================================================="
    logMsg "Creating $framework_name.xcframework"
    logMsg "================================================================="

    rm -rf "$framework_dir"

    logMsg "Creating universal simulator library..."
    local sim_universal_lib="$LIBDIR/lib$LIBNAME-iphonesimulator-universal.a"
    lipo -create -output "$sim_universal_lib" "$LIBDIR"/lib$LIBNAME-iphonesimulator-*.a

    logMsg "Creating universal macOS library..."
    local mac_universal_lib="$LIBDIR/lib$LIBNAME-macosx-universal.a"
    lipo -create -output "$mac_universal_lib" "$LIBDIR"/lib$LIBNAME-macosx-*.a
        
    logMsg "Assembling XCFramework..."
    logMsg "Outputting to path: [$framework_dir]"
    
    xcodebuild -create-xcframework \
        -library "$LIBDIR/lib$LIBNAME-iphoneos-arm64.a" -headers "$HEADERDIR" \
        -library "$sim_universal_lib" -headers "$HEADERDIR" \
        -library "$mac_universal_lib" -headers "$HEADERDIR" \
        -output "$framework_dir"

    logMsg "✅ Successfully created $framework_dir"
}

# --- Main Build Logic ---
logMsg "Starting FLINT build..."
checkDependencies
if [ -d "$BUILDDIR" ]; then logMsg "Cleaning old FLINT build directory..."; rm -rf "$BUILDDIR"; fi
extractSoftware

logMsg "--- Building for iOS Device ---"
for arch in $DEVARCHS; do configureAndMake "iphoneos" "$arch"; done

# Capture headers from the clean 'install' directory ***
logMsg "Capturing installed headers..."
rm -rf "$HEADERDIR"
# The headers are now in the predictable install location from the first build.
cp -R "$BUILDDIR/install-iphoneos-arm64/usr/local/include/." "$HEADERDIR/"
logMsg "✅ Headers captured successfully."

logMsg "--- Building for iOS Simulator ---"
for arch in $SIMARCHS; do configureAndMake "iphonesimulator" "$arch"; done

logMsg "--- Building for macOS ---"
for arch in $MACARCHS; do configureAndMake "macosx" "$arch"; done

createXCFramework

logMsg "🚀 FLINT build process completed successfully!"
exit 0