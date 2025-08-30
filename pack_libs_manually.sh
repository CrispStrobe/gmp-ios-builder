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
# We need the headers from the source directory for the framework to be valid.
HEADERS_DIR="build/source/"

# --- Main Logic ---

# 1. Check if required files exist
if [ ! -f "$LIBDIR/libgmp-iphoneos-arm64.a" ] || \
   [ ! -f "$LIBDIR/libgmp-iphonesimulator-arm64.a" ] || \
   [ ! -f "$LIBDIR/libgmp-iphonesimulator-x86_64.a" ] || \
   [ ! -d "$HEADERS_DIR" ]; then
    echo "ERROR: Not all required .a library files or header directory found in ./build/"
    echo "Please run the full ./build_gmp.sh script first."
    exit 1
fi

# 2. Clean up any previous attempts
echo "Cleaning up old framework if it exists..."
rm -rf "$FRAMEWORK_DIR"

# 3. Create the required directory structure for the .xcframework
echo "Creating XCFramework directory structure..."
mkdir -p "$FRAMEWORK_DIR/ios-arm64/Headers"
mkdir -p "$FRAMEWORK_DIR/ios-arm64-simulator/Headers"
mkdir -p "$FRAMEWORK_DIR/ios-x86_64-simulator/Headers"

# 4. Copy the libraries and headers into their correct locations
echo "Copying libraries and headers..."
# --- Device ---
cp "$LIBDIR/libgmp-iphoneos-arm64.a"         "$FRAMEWORK_DIR/ios-arm64/libgmp.a"
cp "$HEADERS_DIR/gmp.h"                       "$FRAMEWORK_DIR/ios-arm64/Headers/"
# --- Apple Silicon Simulator ---
cp "$LIBDIR/libgmp-iphonesimulator-arm64.a"  "$FRAMEWORK_DIR/ios-arm64-simulator/libgmp.a"
cp "$HEADERS_DIR/gmp.h"                       "$FRAMEWORK_DIR/ios-arm64-simulator/Headers/"
# --- Intel Simulator ---
cp "$LIBDIR/libgmp-iphonesimulator-x86_64.a" "$FRAMEWORK_DIR/ios-x86_64-simulator/libgmp.a"
cp "$HEADERS_DIR/gmp.h"                       "$FRAMEWORK_DIR/ios-x86_64-simulator/Headers/"

# 5. Create the Info.plist manifest file that describes the framework structure
echo "Generating Info.plist manifest..."
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
			<string>Headers</string>
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
			<string>Headers</string>
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
			<string>Headers</string>
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
echo "✅ Success! A valid folder named '$FRAMEWORK_DIR' has been created."
echo "Run 'ls -la' to see it."