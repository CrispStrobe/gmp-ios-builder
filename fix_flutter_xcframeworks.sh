#!/bin/bash
#############################################################################
# fix_flutter_xcframeworks.sh
# 
# Repackages the new Flutter SymEngine wrapper into properly structured XCFrameworks
# Fixes CocoaPods "Invalid XCFramework slice type" errors by ensuring consistent naming
#############################################################################
set -e

readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
readonly BUILDDIR_GMP="$SCRIPTDIR/build"
readonly BUILDDIR_MPFR="$SCRIPTDIR/build-mpfr" 
readonly BUILDDIR_MPC="$SCRIPTDIR/build-mpc"
readonly BUILDDIR_FLINT="$SCRIPTDIR/build-flint"
readonly BUILDDIR_SYMENGINE="$SCRIPTDIR/build-symengine"
readonly TARGET_PLUGIN_DIR="../symbolic_math_bridge/ios"

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
    
    if [[ "$lib_name" == "symengine_flutter_wrapper" ]]; then
        # NEW: Flutter wrapper needs its own header
        local flutter_header="$SCRIPTDIR/src/flutter_symengine_wrapper.h"
        if [[ -f "$flutter_header" ]]; then
            cp "$flutter_header" "$headers_dir/"
        else
            errorExit "Flutter wrapper header not found at $flutter_header"
        fi
    elif [[ "$lib_name" == "symengine" ]]; then
        # Original SymEngine headers
        local symengine_source="$SCRIPTDIR/symengine-0.11.2"
        if [[ -d "$symengine_source/symengine" ]]; then
            cp -R "$symengine_source/symengine" "$headers_dir/"
        else
            errorExit "SymEngine source headers not found at $symengine_source"
        fi
        
        # Then overwrite with generated config headers for each platform
        for platform_dir in "$build_dir"/*/symengine; do
            if [[ -d "$platform_dir" ]]; then
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

# Special function for Flutter wrapper with different naming
create_flutter_wrapper_xcframework() {
    logMsg "Creating Flutter wrapper XCFramework..."
    
    local build_dir="$BUILDDIR_SYMENGINE"
    local lib_dir="$build_dir/lib"
    local temp_dir="/tmp/flutter_wrapper_$$"
    local output_framework="$SCRIPTDIR/SymEngineFlutterWrapper.xcframework"
    
    # Clean up
    rm -rf "$output_framework"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    # CocoaPods requires IDENTICAL names
    local consistent_lib_name="libsymengine_flutter_wrapper.a"
    
    # Create platform directories
    mkdir -p "$temp_dir/device" "$temp_dir/simulator" "$temp_dir/macos"
    
    # Copy device library
    if [[ -f "$lib_dir/libsymengine_flutter_wrapper-iphoneos-arm64.a" ]]; then
        cp "$lib_dir/libsymengine_flutter_wrapper-iphoneos-arm64.a" "$temp_dir/device/$consistent_lib_name"
    else
        errorExit "Missing Flutter wrapper device library"
    fi
    
    # Create simulator universal library
    if [[ -f "$lib_dir/libsymengine_flutter_wrapper-iphonesimulator-x86_64.a" && -f "$lib_dir/libsymengine_flutter_wrapper-iphonesimulator-arm64.a" ]]; then
        lipo -create -output "$temp_dir/simulator/$consistent_lib_name" \
            "$lib_dir/libsymengine_flutter_wrapper-iphonesimulator-x86_64.a" \
            "$lib_dir/libsymengine_flutter_wrapper-iphonesimulator-arm64.a"
    else
        errorExit "Missing Flutter wrapper simulator libraries"
    fi
    
    # Create macOS universal library
    if [[ -f "$lib_dir/libsymengine_flutter_wrapper-macosx-x86_64.a" && -f "$lib_dir/libsymengine_flutter_wrapper-macosx-arm64.a" ]]; then
        lipo -create -output "$temp_dir/macos/$consistent_lib_name" \
            "$lib_dir/libsymengine_flutter_wrapper-macosx-x86_64.a" \
            "$lib_dir/libsymengine_flutter_wrapper-macosx-arm64.a"
    else
        errorExit "Missing Flutter wrapper macOS libraries"
    fi
    
    # Prepare headers
    local headers_dir="$temp_dir/headers"
    mkdir -p "$headers_dir"
    
    local flutter_header="$SCRIPTDIR/src/flutter_symengine_wrapper.h"
    if [[ -f "$flutter_header" ]]; then
        cp "$flutter_header" "$headers_dir/"
    else
        errorExit "Flutter wrapper header not found at $flutter_header"
    fi
    
    # Create XCFramework
    logMsg "Creating Flutter wrapper XCFramework with xcodebuild..."
    xcodebuild -create-xcframework \
        -library "$temp_dir/device/$consistent_lib_name" -headers "$headers_dir" \
        -library "$temp_dir/simulator/$consistent_lib_name" -headers "$headers_dir" \
        -library "$temp_dir/macos/$consistent_lib_name" -headers "$headers_dir" \
        -output "$output_framework"
    
    # Clean up
    rm -rf "$temp_dir"
    
    logMsg "✅ Successfully created Flutter wrapper XCFramework"
}

verify_xcframework() {
    local framework_path="$1"
    local framework_name=$(basename "$framework_path" .xcframework)
    
    logMsg "Verifying $framework_name..."
    
    if [[ ! -d "$framework_path" ]]; then
        logMsg "❌ $framework_name not found"
        return 1
    fi
    
    # Check Info.plist
    local plist_path="$framework_path/Info.plist"
    if [[ ! -f "$plist_path" ]]; then
        logMsg "❌ $framework_name missing Info.plist"
        return 1
    fi
    
    # Check each slice has consistent binary names
    for slice_dir in "$framework_path"/*/; do
        if [[ -d "$slice_dir" ]]; then
            local slice_name=$(basename "$slice_dir")
            logMsg "  Slice: $slice_name"
            
            # List binaries in this slice
            local binaries=$(find "$slice_dir" -name "*.a" -o -name "$framework_name" 2>/dev/null)
            if [[ -n "$binaries" ]]; then
                echo "$binaries" | while read binary; do
                    logMsg "    Binary: $(basename "$binary")"
                done
            else
                logMsg "    ❌ No binaries found"
            fi
        fi
    done
    
    logMsg "✅ $framework_name verification complete"
}

# Main execution
logMsg "Starting XCFramework repackaging process for new architecture..."

# Check if build directories exist
for build_dir in "$BUILDDIR_GMP" "$BUILDDIR_MPFR" "$BUILDDIR_MPC" "$BUILDDIR_FLINT" "$BUILDDIR_SYMENGINE"; do
    if [[ ! -d "$build_dir" ]]; then
        errorExit "Build directory not found: $build_dir"
    fi
done

# Repackage base math libraries (same as before)
create_fixed_xcframework "gmp" "$BUILDDIR_GMP" "$BUILDDIR_GMP/include/gmp.h" "GMP"
create_fixed_xcframework "mpfr" "$BUILDDIR_MPFR" "$BUILDDIR_MPFR/include/mpfr.h" "MPFR"  
create_fixed_xcframework "mpc" "$BUILDDIR_MPC" "$BUILDDIR_MPC/include/mpc.h" "MPC"
create_fixed_xcframework "flint" "$BUILDDIR_FLINT" "$BUILDDIR_FLINT/include" "FLINT"

# NEW: Create Flutter wrapper XCFramework with proper naming
create_flutter_wrapper_xcframework

logMsg "🚀 All XCFrameworks repackaged successfully!"

# Verify all frameworks
verify_xcframework "GMP.xcframework"
verify_xcframework "MPFR.xcframework"
verify_xcframework "MPC.xcframework"
verify_xcframework "FLINT.xcframework"
verify_xcframework "SymEngineFlutterWrapper.xcframework"

logMsg "Copying to plugin directory..."

# Copy to plugin directory
if [[ -d "$TARGET_PLUGIN_DIR" ]]; then
    cp -R GMP.xcframework MPFR.xcframework MPC.xcframework FLINT.xcframework SymEngineFlutterWrapper.xcframework "$TARGET_PLUGIN_DIR/"
    logMsg "✅ Fixed XCFrameworks copied to symbolic_math_bridge/ios/"
else
    errorExit "Plugin directory not found: $TARGET_PLUGIN_DIR"
fi

logMsg "✅ All XCFrameworks fixed and ready for CocoaPods!"
logMsg "You can now run 'flutter run' in your test app."

exit 0