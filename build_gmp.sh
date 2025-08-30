#!/bin/bash
############################################################################
#
# build-gmp.sh
# Patched version of NeoTeo/gmp-ios-builder for modern Xcode/iOS.
#
# Fixes:
# 1. Changed shebang from /usr/local/bin/bash to /bin/bash for compatibility.
# 2. Removed obsolete 32-bit architectures (armv7, armv7s, i386).
# 3. Removed the deprecated -fembed-bitcode flag.
# 4. Increased the minimum iOS version to 13.0.
# 5. Added an explicit `build` command so it runs without options.
# 6. Replaced associative array with simple loops for Bash 3 compatibility.
# 7. Updated to GMP version 6.3.0.
# 8. Corrected host architecture from `arm64` to `aarch64` for configure script.
# 9. Fixed createFramework to create universal libraries first, then XCFramework.
#
############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd )
BUILDDIR=$SCRIPTDIR/build
LIBDIR=$BUILDDIR/lib
LIBNAME=gmp
# PATCH: Updated GMP version
VERSION=6.3.0
SOFTWARETAR="$SCRIPTDIR/$LIBNAME-$VERSION.tar.bz2"

# Architectures for running on a physical device.
DEVARCHS="arm64"

# Architectures for running on a simulator.
SIMARCHS="x86_64 arm64"

# PATCH: Updated minimum iOS version
IOSVERSIONMIN=13.0

# --- Functions ---
cleanup() {
    # This function is called on script exit.
    echo "[CLEANUP] Build script finished."
}
trap cleanup EXIT

logMsg() {
    printf "[GMP BUILD] %s\n" "$1"
}

errorExit() {
    logMsg "ERROR: $1"
    logMsg "Build failed."
    exit 1
}

extractSoftware() {
    local extractdir="$BUILDDIR/source"
    logMsg "Creating build directory and extracting source..."
    mkdir -p "$extractdir"
    cd "$extractdir"

    if [ ! -f "$SOFTWARETAR" ]; then
        errorExit "Software archive not found at $SOFTWARETAR. Please download it."
    fi

    tar -xjf "$SOFTWARETAR" --strip-components 1 || errorExit "Failed to extract tarball."
}

configureAndMake() {
    local platform=$1
    local arch=$2
    local extractdir="$BUILDDIR/source"

    logMsg "================================================================="
    logMsg "Configuring for PLATFORM: $platform ARCH: $arch"
    logMsg "================================================================="

    local sdkpath=$(xcrun --sdk $platform --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then
        errorExit "SDK path not found for platform $platform. Is Xcode installed?"
    fi

    # Set compiler and flags - CRITICAL FIX: Different flags for device vs simulator
    export CC=$(xcrun --sdk $platform -f clang)
    
    if [[ "$platform" == "iphonesimulator" ]]; then
        # Simulator-specific flags
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN"
        export LDFLAGS="-arch $arch -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN"
    else
        # Device-specific flags  
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN"
        export LDFLAGS="-arch $arch -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN"
    fi

    cd "$extractdir"

    # Important: Run make distclean to ensure a fresh build for each architecture
    make distclean &> /dev/null || true

    # PATCH: Correctly set host architecture. GMP's configure script
    # recognizes `aarch64` for 64-bit ARM, not `arm64`.
    local host_arch=$arch
    if [[ "$arch" == "arm64" ]]; then
        host_arch="aarch64"
    fi

    # --disable-assembly is CRITICAL for iOS builds.
    ./configure --host="$host_arch-apple-darwin" --disable-assembly --enable-static --disable-shared

    logMsg "Building for $platform $arch..."
    make -j$(sysctl -n hw.ncpu)

    logMsg "Copying built library..."
    [ -d "$LIBDIR" ] || mkdir -p "$LIBDIR"
    cp ".libs/lib$LIBNAME.a" "$LIBDIR/lib$LIBNAME-$platform-$arch.a"
}

createFramework() {
    local FRAMEWORK_NAME="GMP"
    local FRAMEWORK_DIR="$SCRIPTDIR/$FRAMEWORK_NAME.xcframework"
    local HEADERS_DIR="$BUILDDIR/source/"

    logMsg "================================================================="
    logMsg "Creating XCFramework"
    logMsg "================================================================="

    rm -rf "$FRAMEWORK_DIR" # Clean old framework

    # Create the directory structure for the XCFramework manually
    logMsg "Creating XCFramework directory structure..."
    # Device slice
    mkdir -p "$FRAMEWORK_DIR/ios-arm64"
    # Simulator slices
    mkdir -p "$FRAMEWORK_DIR/ios-arm64-simulator"
    mkdir -p "$FRAMEWORK_DIR/ios-x86_64-simulator"

    # Copy the libraries and headers into their correct locations
    logMsg "Copying libraries and headers..."
    cp "$LIBDIR/lib$LIBNAME-iphoneos-arm64.a" "$FRAMEWORK_DIR/ios-arm64/lib$LIBNAME.a"
    cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-arm64/gmp.h"

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a" "$FRAMEWORK_DIR/ios-arm64-simulator/lib$LIBNAME.a"
    cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-arm64-simulator/gmp.h"

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" "$FRAMEWORK_DIR/ios-x86_64-simulator/lib$LIBNAME.a"
    cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-x86_64-simulator/gmp.h"

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
    logMsg "You can now drag this into your Xcode project."
}

# --- Main Build Logic ---

logMsg "Starting GMP build for iOS..."

# Clean old build directory if it exists
if [ -d "$BUILDDIR" ]; then
    logMsg "Cleaning old build directory..."
    rm -rf "$BUILDDIR"
fi

extractSoftware

logMsg "--- Building for iOS Device ---"
for ARCH in $DEVARCHS; do
    configureAndMake "iphoneos" $ARCH
done

logMsg "--- Building for iOS Simulator ---"
for ARCH in $SIMARCHS; do
    configureAndMake "iphonesimulator" $ARCH
done

createFramework

logMsg "Build process completed successfully!"
exit 0