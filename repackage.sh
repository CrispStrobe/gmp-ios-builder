#!/bin/bash
#############################################################################
#
# repackage.sh (Final Corrected Version)
#
# Repackages existing compiled libraries into CocoaPods-compatible XCFrameworks
# by enforcing a consistent internal binary name (e.g., "libgmp.a") across all
# slices before creating the framework. This directly resolves the
# "Invalid XCFramework slice type" error without post-creation patching.
# This script does NOT recompile any code.
#
#############################################################################
set -e

readonly SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)
readonly BUILDDIR_GMP="$SCRIPTDIR/build-gmp"
readonly BUILDDIR_MPFR="$SCRIPTDIR/build-mpfr"
readonly BUILDDIR_MPC="$SCRIPTDIR/build-mpc"
readonly BUILDDIR_FLINT="$SCRIPTDIR/build-flint"
readonly BUILDDIR_SYMENGINE="$SCRIPTDIR/build-symengine"

logMsg() { printf "[REPACKAGE] %s\n" "$1"; }
errorExit() { logMsg "❌ ERROR: $1"; exit 1; }

# A robust function to repackage an XCFramework with a consistent internal binary name.
repackage_with_consistent_name() {
    local lib_name_internal=$1         # e.g., "gmp" or "symengine_flutter_wrapper"
    local build_dir=$2                 # e.g., "$BUILDDIR_GMP"
    local framework_name_output=$3     # e.g., "GMP"
    local header_source_dir=$4         # e.g., "$BUILDDIR_GMP/include"
    
    # Define the consistent internal binary name (e.g., libgmp.a)
    local consistent_binary_name="lib${lib_name_internal}.a"
    
    logMsg "--- Repackaging $framework_name_output with internal name $consistent_binary_name ---"
    
    local lib_dir="$build_dir/lib"
    local output_framework="$SCRIPTDIR/$framework_name_output.xcframework"
    
    local temp_dir="/tmp/xcframework_repackage_$$"
    mkdir -p "$temp_dir/ios" "$temp_dir/sim" "$temp_dir/mac"
    rm -rf "$output_framework"
    
    # Define paths to source libraries
    local ios_lib_src="$lib_dir/lib${lib_name_internal}-iphoneos-arm64.a"
    local sim_x86_64_lib_src="$lib_dir/lib${lib_name_internal}-iphonesimulator-x86_64.a"
    local sim_arm64_lib_src="$lib_dir/lib${lib_name_internal}-iphonesimulator-arm64.a"
    local mac_x86_64_lib_src="$lib_dir/lib${lib_name_internal}-macosx-x86_64.a"
    local mac_arm64_lib_src="$lib_dir/lib${lib_name_internal}-macosx-arm64.a"

    # Verify that all required .a files exist
    for lib_file in "$ios_lib_src" "$sim_x86_64_lib_src" "$sim_arm64_lib_src" "$mac_x86_64_lib_src" "$mac_arm64_lib_src"; do
        if [[ ! -f "$lib_file" ]]; then
            errorExit "Missing required library file: $lib_file"
        fi
    done

    # 1. Copy or `lipo` source libraries to temporary files with the CONSISTENT name.
    logMsg "Creating consistently named temporary binaries..."
    cp "$ios_lib_src" "$temp_dir/ios/$consistent_binary_name"
    lipo -create -output "$temp_dir/sim/$consistent_binary_name" "$sim_x86_64_lib_src" "$sim_arm64_lib_src"
    lipo -create -output "$temp_dir/mac/$consistent_binary_name" "$mac_x86_64_lib_src" "$mac_arm64_lib_src"

    # 2. Create the XCFramework using the temporary, consistently named libraries.
    #    xcodebuild will automatically generate the correct Info.plist.
    logMsg "Creating XCFramework with xcodebuild..."
    xcodebuild -create-xcframework \
        -library "$temp_dir/ios/$consistent_binary_name" -headers "$header_source_dir" \
        -library "$temp_dir/sim/$consistent_binary_name" -headers "$header_source_dir" \
        -library "$temp_dir/mac/$consistent_binary_name" -headers "$header_source_dir" \
        -output "$output_framework"

    # 3. Clean up the temporary directory.
    rm -rf "$temp_dir"
    logMsg "✅ Successfully created $output_framework"
}

# --- Main Execution ---
logMsg "Starting XCFramework repackaging process..."

# Check that all build directories exist
for dir in "$BUILDDIR_GMP" "$BUILDDIR_MPFR" "$BUILDDIR_MPC" "$BUILDDIR_FLINT" "$BUILDDIR_SYMENGINE"; do
    if [[ ! -d "$dir" ]]; then
        errorExit "Build directory not found: $dir. Run the main build scripts first."
    fi
done

# Repackage each library, ensuring the internal binary is named "lib<name>.a"
repackage_with_consistent_name "gmp" "$BUILDDIR_GMP" "GMP" "$BUILDDIR_GMP/include"
repackage_with_consistent_name "mpfr" "$BUILDDIR_MPFR" "MPFR" "$BUILDDIR_MPFR/include"
repackage_with_consistent_name "mpc" "$BUILDDIR_MPC" "MPC" "$BUILDDIR_MPC/include"
repackage_with_consistent_name "flint" "$BUILDDIR_FLINT" "FLINT" "$BUILDDIR_FLINT/include"
repackage_with_consistent_name "symengine_flutter_wrapper" "$BUILDDIR_SYMENGINE" "SymEngineFlutterWrapper" "$BUILDDIR_SYMENGINE/include"

logMsg "🚀 All XCFrameworks repackaged successfully!"
logMsg "Run your copy script, then 'flutter clean && flutter run'."

exit 0

