#!/bin/bash
############################################################################
#
# build_symengine.sh (Fixed - creates wrapper files per build)
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

# Dependency paths
readonly GMP_BUILDDIR="$SCRIPTDIR/build"
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

# Create wrapper source files in a specific directory
createCWrapperInDir() {
    local target_dir="$1"
    mkdir -p "$target_dir"
    
    # Create the C header file (ONLY C, no C++)
    cat > "$target_dir/symengine_c_wrapper.h" << 'EOF'
#ifndef SYMENGINE_C_WRAPPER_H
#define SYMENGINE_C_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

char* symengine_evaluate(const char* expression);
char* symengine_solve(const char* expression, const char* symbol);
char* symengine_factor(const char* expression);
char* symengine_expand(const char* expression);
void symengine_free_string(char* str);

#ifdef __cplusplus
}
#endif

#endif
EOF

    # Create the C++ implementation file
    cat > "$target_dir/symengine_c_wrapper.cpp" << 'EOF'
#include "symengine_c_wrapper.h"
#include <string>
#include <iostream>
#include <sstream>
#include <cstring>
#include <vector>
#include <utility>

#include <symengine/basic.h>
#include <symengine/symbol.h>
#include <symengine/parser.h>
#include <symengine/eval_double.h>
#include <symengine/solve.h>
#include <symengine/sets.h>
#include <symengine/visitor.h>

using namespace SymEngine;

static char* string_to_char_ptr(const std::string& s) {
    return strdup(s.c_str());
}

extern "C" {
    char* symengine_evaluate(const char* input_expr) {
        try {
            RCP<const Basic> expr = parse(std::string(input_expr));
            double result = eval_double(*expr);
            std::ostringstream oss;
            oss << result;
            std::string result_str = oss.str();
            if (result_str.find('.') != std::string::npos) {
                result_str.erase(result_str.find_last_not_of('0') + 1, std::string::npos);
                if (!result_str.empty() && result_str.back() == '.') {
                    result_str.pop_back();
                }
            }
            return string_to_char_ptr(result_str);
        } catch (const std::exception& e) {
            return string_to_char_ptr("Error");
        }
    }

    char* symengine_solve(const char* input_expr, const char* symbol_name) {
        try {
            RCP<const Basic> expr = parse(std::string(input_expr));
            RCP<const Symbol> sym = symbol(std::string(symbol_name));
            RCP<const Set> solution_set = solve_poly(expr, sym);
            
            if (is_a<FiniteSet>(*solution_set)) {
                auto container = rcp_static_cast<const FiniteSet>(solution_set)->get_container();
                if (container.empty()) {
                    return string_to_char_ptr("No solutions found");
                }
                
                std::ostringstream oss;
                bool first = true;
                for (const auto& sol : container) {
                    if (!first) oss << ", ";
                    try {
                        double val = eval_double(*sol);
                        oss << val;
                    } catch (const std::exception&) {
                        oss << sol->__str__();
                    }
                    first = false;
                }
                return string_to_char_ptr(oss.str());
            } else {
                return string_to_char_ptr(rcp_static_cast<const Basic>(solution_set)->__str__());
            }
        } catch (const std::exception&) {
            return string_to_char_ptr("Solve error");
        }
    }

    char* symengine_factor(const char* input_expr) {
        try {
            RCP<const Basic> expr = parse(std::string(input_expr));
            RCP<const Basic> result = expand(expr);
            return string_to_char_ptr(result->__str__());
        } catch (const std::exception&) {
            return string_to_char_ptr("Factor Error");
        }
    }

    char* symengine_expand(const char* input_expr) {
        try {
            RCP<const Basic> expr = parse(std::string(input_expr));
            RCP<const Basic> expanded_expr = expand(expr);
            return string_to_char_ptr(expanded_expr->__str__());
        } catch (const std::exception&) {
            return string_to_char_ptr("Expand Error");
        }
    }

    void symengine_free_string(char* str) {
        if (str != nullptr) {
            free(str);
        }
    }
}
EOF

    logMsg "✅ Created C wrapper source files in $target_dir"
}

configureAndMake() {
    local platform=$1
    local arch=$2
    local build_dir="$BUILDDIR/$platform-$arch"

    logMsg "================================================================="
    logMsg "Configuring SymEngine + C Wrapper for PLATFORM: $platform, ARCH: $arch"
    logMsg "================================================================="

    local sdkpath
    sdkpath=$(xcrun --sdk "$platform" --show-sdk-path)
    if [ ! -d "$sdkpath" ]; then errorExit "SDK path not found for platform '$platform'."; fi

    rm -rf "$build_dir"
    mkdir -p "$build_dir"
    cd "$build_dir"

    # Create wrapper source files in THIS build directory
    createCWrapperInDir "$build_dir"

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

    # Now compile our C wrapper against the built SymEngine
    logMsg "Building C wrapper against SymEngine..."
    local target_cxx
    target_cxx=$(xcrun --sdk "$platform" -f clang++)
    
    local target_cxxflags
    if [[ "$platform" == "iphoneos" ]]; then
        target_cxxflags="-arch $arch -std=c++14 -stdlib=libc++ -isysroot $sdkpath -miphoneos-version-min=$IOS_MIN_VERSION"
    elif [[ "$platform" == "iphonesimulator" ]]; then
        target_cxxflags="-arch $arch -std=c++14 -stdlib=libc++ -isysroot $sdkpath -mios-simulator-version-min=$IOS_MIN_VERSION"
    else # macosx
        target_cxxflags="-arch $arch -std=c++14 -stdlib=libc++ -isysroot $sdkpath -mmacosx-version-min=$MACOS_MIN_VERSION"
    fi
    
    # Add include paths for SymEngine and all dependencies
    target_cxxflags="$target_cxxflags -I$SYMENGINE_SOURCE -I$build_dir"
    target_cxxflags="$target_cxxflags -I$GMP_BUILDDIR/include"
    target_cxxflags="$target_cxxflags -I$MPFR_BUILDDIR/include"  
    target_cxxflags="$target_cxxflags -I$MPC_BUILDDIR/include"
    target_cxxflags="$target_cxxflags -I$FLINT_BUILDDIR/include"
    
    # Verify files exist before compiling
    if [ ! -f "symengine_c_wrapper.cpp" ]; then
        errorExit "Wrapper source file not found in $build_dir"
    fi
    
    # Compile wrapper (using relative path since we're in the build directory)
    "$target_cxx" $target_cxxflags -c "symengine_c_wrapper.cpp" -o "symengine_c_wrapper.o"
    
    # Find the built SymEngine library
    local found_lib
    found_lib=$(find . -name "lib$LIBNAME.a" -type f | head -1)
    if [ -z "$found_lib" ]; then
        errorExit "Could not find built SymEngine library (lib$LIBNAME.a) in '$build_dir'."
    fi

    logMsg "Creating combined library with C wrapper..."
    # Create a combined library that includes both SymEngine and our wrapper
    mkdir -p temp_extract
    cd temp_extract
    ar x "../$found_lib"
    cp "../symengine_c_wrapper.o" .
    ar rcs "../libsymengine_wrapper.a" *.o
    cd ..
    rm -rf temp_extract

    logMsg "Copying built library..."
    mkdir -p "$LIBDIR"
    cp "libsymengine_wrapper.a" "$LIBDIR/libsymengine_wrapper-$platform-$arch.a"
}

createXCFramework() {
    local framework_name="SymEngineWrapper"
    local framework_dir="$SCRIPTDIR/$framework_name.xcframework"

    logMsg "================================================================="
    logMsg "Creating and patching $framework_name.xcframework"
    logMsg "================================================================="

    rm -rf "$framework_dir"

    # Define source library paths
    local device_lib="$LIBDIR/libsymengine_wrapper-iphoneos-arm64.a"
    local sim_universal_lib="$LIBDIR/libsymengine_wrapper-iphonesimulator-universal.a"
    local mac_universal_lib="$LIBDIR/libsymengine_wrapper-macosx-universal.a"
    
    # Create universal "fat" libraries for simulator and macOS.
    logMsg "Creating universal libraries..."
    lipo -create -output "$sim_universal_lib" \
        "$LIBDIR/libsymengine_wrapper-iphonesimulator-x86_64.a" \
        "$LIBDIR/libsymengine_wrapper-iphonesimulator-arm64.a"

    lipo -create -output "$mac_universal_lib" \
        "$LIBDIR/libsymengine_wrapper-macosx-x86_64.a" \
        "$LIBDIR/libsymengine_wrapper-macosx-arm64.a"

    # Copy only the C wrapper header (no C++ headers!)
    logMsg "Setting up C-only headers..."
    rm -rf "$HEADERDIR_FINAL"
    mkdir -p "$HEADERDIR_FINAL"
    # Get the header from any of the build directories (they're all the same)
    cp "$BUILDDIR/iphoneos-arm64/symengine_c_wrapper.h" "$HEADERDIR_FINAL/"

    # Step 1: Create the XCFramework
    logMsg "Assembling initial XCFramework..."
    xcodebuild -create-xcframework \
        -library "$device_lib" -headers "$HEADERDIR_FINAL" \
        -library "$sim_universal_lib" -headers "$HEADERDIR_FINAL" \
        -library "$mac_universal_lib" -headers "$HEADERDIR_FINAL" \
        -output "$framework_dir"

    # Step 2: Immediately Patch the XCFramework
    logMsg "Patching generated framework for CocoaPods compatibility..."
    
    # Rename the binaries inside the framework to be consistent
    mv "$framework_dir/ios-arm64/libsymengine_wrapper-iphoneos-arm64.a" "$framework_dir/ios-arm64/$framework_name"
    mv "$framework_dir/ios-arm64_x86_64-simulator/libsymengine_wrapper-iphonesimulator-universal.a" "$framework_dir/ios-arm64_x86_64-simulator/$framework_name"
    mv "$framework_dir/macos-arm64_x86_64/libsymengine_wrapper-macosx-universal.a" "$framework_dir/macos-arm64_x86_64/$framework_name"

    # Edit the manifest (Info.plist) to reflect the new, consistent binary names
    local PLIST_PATH="$framework_dir/Info.plist"
    local COUNT=$(/usr/libexec/PlistBuddy -c "Print :AvailableLibraries:" "$PLIST_PATH" | grep -c "Dict")
    for (( i=0; i<$COUNT; i++ )); do
        /usr/libexec/PlistBuddy -c "Set :AvailableLibraries:$i:BinaryPath $framework_name" "$PLIST_PATH"
        /usr/libexec/PlistBuddy -c "Set :AvailableLibraries:$i:LibraryPath $framework_name" "$PLIST_PATH"
    done
    
    logMsg "✅ Successfully created and patched $framework_dir"
}

# --- Main Build Logic ---
logMsg "Starting SymEngine C Wrapper build..."

checkCMake
checkDependencies
downloadSymEngine

if [ -d "$BUILDDIR" ]; then rm -rf "$BUILDDIR"; fi

logMsg "--- Building SymEngine + C Wrapper for iOS Device ---"
for ARCH in $DEVARCHS; do configureAndMake "iphoneos" "$ARCH"; done

logMsg "--- Building SymEngine + C Wrapper for iOS Simulator ---"
for ARCH in $SIMARCHS; do configureAndMake "iphonesimulator" "$ARCH"; done

logMsg "--- Building SymEngine + C Wrapper for macOS ---"
for ARCH in $MACARCHS; do configureAndMake "macosx" "$ARCH"; done

createXCFramework

logMsg "🚀 SymEngine C Wrapper build process completed successfully!"
exit 0