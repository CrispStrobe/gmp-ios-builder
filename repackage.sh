#!/bin/bash
#############################################################################
# fix_xcframeworks.sh
# 
# Repackages existing compiled libraries into properly structured XCFrameworks
# without recompiling. This fixes CocoaPods "Invalid XCFramework slice type" errors.
# All libraries within an XCFramework must have identical names.
#############################################################################
set -e

readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
readonly BUILDDIR_GMP="$SCRIPTDIR/build"
readonly BUILDDIR_MPFR="$SCRIPTDIR/build-mpfr" 
readonly BUILDDIR_MPC="$SCRIPTDIR/build-mpc"
readonly BUILDDIR_FLINT="$SCRIPTDIR/build-flint"
readonly BUILDDIR_SYMENGINE="$SCRIPTDIR/build-symengine"

logMsg() { printf "[REPACKAGE] %s\n" "$1"; }
errorExit() { logMsg "❌ ERROR: $1"; exit 1; }

# Function to create a properly structured XCFramework from existing binaries
create_fixed_xcframework() {
    local lib_name=$1
    local build_dir=$2
    local header_source=$3
    local framework_name=$4
    
    logMsg "Repackaging $lib_name XCFramework..."
    
    local lib_dir="$build_dir/lib"
    local temp_dir="/tmp/xcframework_fix_$$_$lib_name"
    local output_framework="$SCRIPTDIR/$framework_name.xcframework"
    
    # Clean up any existing framework
    rm -rf "$output_framework"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    # CocoaPods requires all libraries to have the SAME name
    local consistent_lib_name="lib$lib_name.a"
    
    # Create separate directories for each platform
    mkdir -p "$temp_dir/device" "$temp_dir/simulator" "$temp_dir/macos"
    
    # Prepare device library (iOS arm64) 
    if [[ -f "$lib_dir/lib$lib_name-iphoneos-arm64.a" ]]; then
        cp "$lib_dir/lib$lib_name-iphoneos-arm64.a" "$temp_dir/device/$consistent_lib_name"
    else
        errorExit "Missing device library: $lib_dir/lib$lib_name-iphoneos-arm64.a"
    fi
    
    # Prepare simulator universal library
    if [[ -f "$lib_dir/lib$lib_name-iphonesimulator-x86_64.a" && -f "$lib_dir/lib$lib_name-iphonesimulator-arm64.a" ]]; then
        lipo -create -output "$temp_dir/simulator/$consistent_lib_name" \
            "$lib_dir/lib$lib_name-iphonesimulator-x86_64.a" \
            "$lib_dir/lib$lib_name-iphonesimulator-arm64.a"
    else
        errorExit "Missing simulator libraries for $lib_name"
    fi
    
    # Prepare macOS universal library  
    if [[ -f "$lib_dir/lib$lib_name-macosx-x86_64.a" && -f "$lib_dir/lib$lib_name-macosx-arm64.a" ]]; then
        lipo -create -output "$temp_dir/macos/$consistent_lib_name" \
            "$lib_dir/lib$lib_name-macosx-x86_64.a" \
            "$lib_dir/lib$lib_name-macosx-arm64.a"
    else
        errorExit "Missing macOS libraries for $lib_name"
    fi
    
    # Prepare headers directory
    local headers_dir="$temp_dir/headers"
    mkdir -p "$headers_dir"
    
    if [[ "$lib_name" == "symengine" ]]; then
        # SymEngine needs generated headers from each platform's build directory
        # Copy source headers first
        local symengine_source="$SCRIPTDIR/symengine-0.11.2"
        if [[ -d "$symengine_source/symengine" ]]; then
            cp -R "$symengine_source/symengine" "$headers_dir/"
        else
            errorExit "SymEngine source headers not found at $symengine_source"
        fi
        
        # Then overwrite with generated config headers for each platform
        for platform_dir in "$build_dir"/*/symengine; do
            if [[ -d "$platform_dir" ]]; then
                # Copy generated headers, overwriting the .h.in templates
                find "$platform_dir" -name "*.h" -exec cp {} "$headers_dir/symengine/" \;
            fi
        done
    else
        # Single header file for GMP, MPFR, MPC, FLINT
        local header_file
        case "$lib_name" in
            "gmp") header_file="gmp.h" ;;
            "mpfr") header_file="mpfr.h" ;;
            "mpc") header_file="mpc.h" ;;
            "flint") header_file="flint/flint.h" ;;
        esac
        
        if [[ -f "$header_source" ]]; then
            cp "$header_source" "$headers_dir/"
        elif [[ -f "$build_dir/include/$header_file" ]]; then
            if [[ "$lib_name" == "flint" ]]; then
                # FLINT has nested headers
                cp -R "$build_dir/include/flint" "$headers_dir/"
            else
                cp "$build_dir/include/$header_file" "$headers_dir/"
            fi
        else
            errorExit "Header file not found for $lib_name"
        fi
    fi
    
    # Create the XCFramework using xcodebuild (this creates proper structure)
    logMsg "Creating XCFramework with xcodebuild..."
    xcodebuild -create-xcframework \
        -library "$temp_dir/device/$consistent_lib_name" -headers "$headers_dir" \
        -library "$temp_dir/simulator/$consistent_lib_name" -headers "$headers_dir" \
        -library "$temp_dir/macos/$consistent_lib_name" -headers "$headers_dir" \
        -output "$output_framework"
    
    # Clean up temp directory
    rm -rf "$temp_dir"
    
    logMsg "✅ Successfully created $output_framework"
}

# Main execution
logMsg "Starting XCFramework repackaging process..."

# Check if build directories exist
for build_dir in "$BUILDDIR_GMP" "$BUILDDIR_MPFR" "$BUILDDIR_MPC" "$BUILDDIR_FLINT" "$BUILDDIR_SYMENGINE"; do
    if [[ ! -d "$build_dir" ]]; then
        errorExit "Build directory not found: $build_dir"
    fi
done

# Repackage each library
create_fixed_xcframework "gmp" "$BUILDDIR_GMP" "$BUILDDIR_GMP/include/gmp.h" "GMP"
create_fixed_xcframework "mpfr" "$BUILDDIR_MPFR" "$BUILDDIR_MPFR/include/mpfr.h" "MPFR"  
create_fixed_xcframework "mpc" "$BUILDDIR_MPC" "$BUILDDIR_MPC/include/mpc.h" "MPC"
create_fixed_xcframework "flint" "$BUILDDIR_FLINT" "$BUILDDIR_FLINT/include" "FLINT"
create_fixed_xcframework "symengine" "$BUILDDIR_SYMENGINE" "" "SymEngine"

logMsg "🚀 All XCFrameworks repackaged successfully!"
logMsg "Now copying to plugin directory..."

# Copy to plugin directory
cp -R GMP.xcframework MPFR.xcframework MPC.xcframework FLINT.xcframework SymEngine.xcframework ../symbolic_math_bridge/ios/

logMsg "✅ Fixed XCFrameworks copied to symbolic_math_bridge/ios/"
logMsg "You can now run 'pod install' in your Flutter app."

exit 0