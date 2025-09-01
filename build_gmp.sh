#!/bin/bash
#############################################################################
#
# build-gmp.sh (FIXED VERSION)
# Creates XCFramework with universal simulator binary
#
#############################################################################
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(cd "$SCRIPTDIR" && pwd )
BUILDDIR=$SCRIPTDIR/build
LIBDIR=$BUILDDIR/lib
LIBNAME=gmp
VERSION=6.3.0
SOFTWARETAR="$SCRIPTDIR/$LIBNAME-$VERSION.tar.bz2"

# Architectures for running on a physical device.
DEVARCHS="arm64"

# Architectures for running on a simulator.
SIMARCHS="x86_64 arm64"

IOSVERSIONMIN=13.0

# --- Functions ---
cleanup() {
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

    # Set compiler and flags
    export CC=$(xcrun --sdk $platform -f clang)
    
    if [[ "$platform" == "iphonesimulator" ]]; then
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN"
        export LDFLAGS="-arch $arch -isysroot $sdkpath -mios-simulator-version-min=$IOSVERSIONMIN"
    else
        export CFLAGS="-arch $arch -pipe -Os -gdwarf-2 -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN"
        export LDFLAGS="-arch $arch -isysroot $sdkpath -miphoneos-version-min=$IOSVERSIONMIN"
    fi

    cd "$extractdir"
    make distclean &> /dev/null || true

    local host_arch=$arch
    if [[ "$arch" == "arm64" ]]; then
        host_arch="aarch64"
    fi

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
    logMsg "Creating XCFramework with Universal Simulator Binary"
    logMsg "================================================================="

    rm -rf "$FRAMEWORK_DIR" # Clean old framework

    # Create universal simulator library
    logMsg "Creating universal simulator library..."
    lipo -create \
        "$LIBDIR/lib$LIBNAME-iphonesimulator-x86_64.a" \
        "$LIBDIR/lib$LIBNAME-iphonesimulator-arm64.a" \
        -output "$LIBDIR/lib$LIBNAME-iphonesimulator-universal.a"

    # Create the directory structure for the XCFramework
    logMsg "Creating XCFramework directory structure..."
    mkdir -p "$FRAMEWORK_DIR/ios-arm64"
    mkdir -p "$FRAMEWORK_DIR/ios-arm64_x86_64-simulator"

    # Copy the libraries and headers
    logMsg "Copying libraries and headers..."
    cp "$LIBDIR/lib$LIBNAME-iphoneos-arm64.a" "$FRAMEWORK_DIR/ios-arm64/lib$LIBNAME.a"
    cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-arm64/gmp.h"

    cp "$LIBDIR/lib$LIBNAME-iphonesimulator-universal.a" "$FRAMEWORK_DIR/ios-arm64_x86_64-simulator/lib$LIBNAME.a"
    cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-arm64_x86_64-simulator/gmp.h"

    # Create the Info.plist manifest file (FIXED VERSION)
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
            <string>ios-arm64_x86_64-simulator</string>
            <key>LibraryPath</key>
            <string>lib$LIBNAME.a</string>
            <key>HeadersPath</key>
            <string>.</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
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