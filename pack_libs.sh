#!/bin/bash
# This script packages the pre-compiled static GMP libraries into a single
# .xcframework bundle using a manual process to avoid xcodebuild errors.
# It should be run from the root of the 'gmp-ios-builder' directory.
set -e

# --- Configuration ---
BUILDDIR="build"
LIBDIR="build/lib"
FRAMEWORK_NAME="GMP"
FRAMEWORK_DIR="GMP.xcframework"
HEADERS_DIR="build/source/" # Headers are needed for the framework

# --- Check if required libraries exist ---
echo "Checking for required libraries..."
REQUIRED_LIBS=(
    "$LIBDIR/libgmp-iphonesimulator-x86_64.a"
    "$LIBDIR/libgmp-iphonesimulator-arm64.a" 
    "$LIBDIR/libgmp-iphoneos-arm64.a"
)

for lib in "${REQUIRED_LIBS[@]}"; do
    if [ ! -f "$lib" ]; then
        echo "ERROR: Required library not found: $lib"
        echo "Please run build_gmp.sh first to build the individual architecture libraries."
        exit 1
    fi
done

# Check if headers directory exists
if [ ! -d "$HEADERS_DIR" ] || [ ! -f "$HEADERS_DIR/gmp.h" ]; then
    echo "ERROR: Headers directory or gmp.h not found in: $HEADERS_DIR"
    echo "Please run build_gmp.sh first to extract and build the source."
    exit 1
fi

# --- Clean up any previous attempts ---
echo "Cleaning up old framework if it exists..."
rm -rf "$FRAMEWORK_DIR"

# --- Create the directory structure for the XCFramework ---
echo "Creating XCFramework directory structure..."
# Device slice
mkdir -p "$FRAMEWORK_DIR/ios-arm64"
# Simulator slices
mkdir -p "$FRAMEWORK_DIR/ios-arm64-simulator"
mkdir -p "$FRAMEWORK_DIR/ios-x86_64-simulator"

# --- Copy the libraries and headers into their correct locations ---
echo "Copying libraries and headers..."
cp "$LIBDIR/libgmp-iphoneos-arm64.a" "$FRAMEWORK_DIR/ios-arm64/libgmp.a"
cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-arm64/gmp.h"

cp "$LIBDIR/libgmp-iphonesimulator-arm64.a" "$FRAMEWORK_DIR/ios-arm64-simulator/libgmp.a"
cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-arm64-simulator/gmp.h"

cp "$LIBDIR/libgmp-iphonesimulator-x86_64.a" "$FRAMEWORK_DIR/ios-x86_64-simulator/libgmp.a"
cp "$HEADERS_DIR/gmp.h" "$FRAMEWORK_DIR/ios-x86_64-simulator/gmp.h"

# --- Create the Info.plist manifest file ---
echo "Generating Info.plist..."
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
            <string>libgmp.a</string>
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
            <string>libgmp.a</string>
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
            <string>libgmp.a</string>
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

echo ""
echo "✅ Success! XCFramework created at: $FRAMEWORK_DIR"
echo ""
echo "Framework info:"
echo "- Device (iOS): ios-arm64/libgmp.a"
echo "- Simulator (arm64): ios-arm64-simulator/libgmp.a" 
echo "- Simulator (x86_64): ios-x86_64-simulator/libgmp.a"
echo ""
echo "Library sizes:"
for lib in "${REQUIRED_LIBS[@]}"; do
    if [ -f "$lib" ]; then
        ls -lh "$lib"
    fi
done

echo ""
echo "🎯 Next steps:"
echo "1. Drag GMP.xcframework into your Xcode project"
echo "2. In your target's Build Phases, ensure it's in 'Link Binary With Libraries'"
echo "3. Import in your code with: #import <gmp.h>"
echo "4. You can now use GMP functions in your iOS app!"#!/bin/bash
# --- Step 1: Define variables for convenience ---
# This makes the commands cleaner and easier to read.
BUILDDIR="build"
LIBDIR="build/lib"
FRAMEWORK_NAME="GMP"
FRAMEWORK_DIR="GMP.xcframework"
HEADERS_DIR="build/source/"

# --- Step 2: Check if required libraries exist ---
echo "Checking for required libraries..."
REQUIRED_LIBS=(
    "$LIBDIR/libgmp-iphonesimulator-x86_64.a"
    "$LIBDIR/libgmp-iphonesimulator-arm64.a" 
    "$LIBDIR/libgmp-iphoneos-arm64.a"
)

for lib in "${REQUIRED_LIBS[@]}"; do
    if [ ! -f "$lib" ]; then
        echo "ERROR: Required library not found: $lib"
        echo "Please run build_gmp.sh first to build the individual architecture libraries."
        exit 1
    fi
done

# Check if headers directory exists
if [ ! -d "$HEADERS_DIR" ]; then
    echo "ERROR: Headers directory not found: $HEADERS_DIR"
    echo "Please run build_gmp.sh first to extract and build the source."
    exit 1
fi

# --- Step 3: Clean up any previous failed attempts ---
echo "Cleaning up old framework if it exists..."
rm -rf "$FRAMEWORK_DIR"

# --- Step 4: Build the final .xcframework from individual architecture libraries ---
# Let xcodebuild handle the architecture bundling instead of using lipo
echo "Creating the final XCFramework from individual architecture libraries..."
xcodebuild -create-xcframework \
    -library "$LIBDIR/libgmp-iphonesimulator-x86_64.a" -headers "$HEADERS_DIR" \
    -library "$LIBDIR/libgmp-iphonesimulator-arm64.a" -headers "$HEADERS_DIR" \
    -library "$LIBDIR/libgmp-iphoneos-arm64.a" -headers "$HEADERS_DIR" \
    -output "$FRAMEWORK_DIR"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create XCFramework"
    exit 1
fi

echo "Success! XCFramework created at: $FRAMEWORK_DIR"
echo "You can now drag this framework into your Xcode project."

# --- Step 5: Show some info about the created framework ---
echo ""
echo "Framework info:"
echo "- XCFramework: $FRAMEWORK_DIR"
echo ""
echo "Individual library sizes:"
for lib in "${REQUIRED_LIBS[@]}"; do
    if [ -f "$lib" ]; then
        ls -lh "$lib"
    fi
done

echo ""
echo "XCFramework contents:"
if [ -d "$FRAMEWORK_DIR" ]; then
    find "$FRAMEWORK_DIR" -name "*.a" -exec ls -lh {} \;
fi