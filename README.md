# gmp-mpfr-ios-builder

A build system for creating iOS XCFrameworks from the [GNU Multiple Precision Arithmetic Library (GMP)](https://gmplib.org/) and [MPFR (Multiple Precision Floating-Point Reliable)](https://www.mpfr.org/). This project builds GMP 6.3.0 and MPFR 4.2.2 as static XCFrameworks that work on both iOS devices and simulators (Intel and Apple Silicon).

## What This Builds

The build process creates two XCFrameworks:

### `GMP.xcframework`
- **iOS Device** (arm64): For physical iPhones and iPads
- **iOS Simulator** (arm64): For Apple Silicon Mac simulators  
- **iOS Simulator** (x86_64): For Intel Mac simulators

### `MPFR.xcframework` 
- **iOS Device** (arm64): For physical iPhones and iPads
- **iOS Simulator** (arm64): For Apple Silicon Mac simulators
- **iOS Simulator** (x86_64): For Intel Mac simulators

## Requirements

- **macOS** with Xcode and Command Line Tools installed
- **Bash** (any modern version - the scripts are compatible with macOS's default bash 3.2+)
- **GMP 6.3.0 source** (included as `gmp-6.3.0.tar.bz2`)
- **MPFR 4.2.2 source** (included as `mpfr-4.2.2.tar.xz`)

## Quick Start

### Build Everything from Scratch
```bash
# Clone or download this repository
# Make sure both gmp-6.3.0.tar.bz2 and mpfr-4.2.2.tar.xz are in the root directory

# Build GMP first (MPFR depends on GMP)
chmod +x build_gmp.sh
./build_gmp.sh

# Build MPFR (requires GMP to be built first)
chmod +x build_mpfr.sh
./build_mpfr.sh

# Test that both frameworks compile correctly
chmod +x ios_compile_test.sh
./ios_compile_test.sh
```

### Create XCFramework from Existing Libraries
```bash
# If you already have the individual architecture libraries built
chmod +x pack_libs.sh  
./pack_libs.sh
```

## Scripts Overview

### `build_gmp.sh`
The GMP build script that:
1. Extracts GMP 6.3.0 source code
2. Configures and builds for each target architecture
3. Creates the final `GMP.xcframework`

**Key Features:**
- Uses modern iOS deployment target (13.0+)
- Removes deprecated compiler flags (`-fembed-bitcode`)
- Supports only 64-bit architectures (removed old 32-bit support)
- Uses `--disable-assembly` for reliable iOS builds
- Handles Apple Silicon vs Intel architecture naming correctly

### `build_mpfr.sh`
The MPFR build script that:
1. Verifies GMP dependency is available
2. Extracts MPFR 4.2.2 source code
3. Configures and builds for each target architecture with GMP linking
4. Creates the final `MPFR.xcframework`

**Dependencies:**
- **Must be run after `build_gmp.sh`** - MPFR requires GMP libraries and headers
- Links against the static GMP libraries built in the previous step
- Uses the same iOS deployment targets and compiler flags as GMP

### `ios_compile_test.sh`
A test script that verifies both XCFrameworks can be compiled and linked correctly:
- Tests device (arm64) compilation
- Tests simulator (arm64 and x86_64) compilation  
- Includes basic GMP and MPFR function calls
- Automatically cleans up test files

### `pack_libs.sh`
A utility script for creating `GMP.xcframework` from pre-built libraries. Note: This script only handles GMP, not MPFR.

## Build Output

After running both build scripts, you'll have:

```
GMP.xcframework/
├── Info.plist                    # XCFramework manifest
├── ios-arm64/                   # iOS Device slice
│   ├── libgmp.a                # Static library for devices
│   └── gmp.h                   # Header file
├── ios-arm64-simulator/         # Apple Silicon simulator slice  
│   ├── libgmp.a                # Static library for arm64 simulator
│   └── gmp.h                   # Header file
└── ios-x86_64-simulator/        # Intel simulator slice
    ├── libgmp.a                # Static library for x86_64 simulator
    └── gmp.h                   # Header file

MPFR.xcframework/
├── Info.plist                   # XCFramework manifest
├── ios-arm64/                  # iOS Device slice
│   ├── libmpfr.a               # Static library for devices
│   └── mpfr.h                  # Header file
├── ios-arm64-simulator/        # Apple Silicon simulator slice
│   ├── libmpfr.a               # Static library for arm64 simulator
│   └── mpfr.h                  # Header file
└── ios-x86_64-simulator/       # Intel simulator slice
    ├── libmpfr.a               # Static library for x86_64 simulator
    └── mpfr.h                  # Header file
```

## Using in iOS Projects

### Xcode Integration
1. **Add Frameworks**: Drag both `GMP.xcframework` and `MPFR.xcframework` into your Xcode project
2. **Link Binary**: Ensure both appear in your target's "Link Binary With Libraries"
3. **Import**: Use `#import <gmp.h>` and `#import <mpfr.h>` in your Objective-C code

### Swift Integration
Create a bridging header and import both libraries:
```objc
// In YourProject-Bridging-Header.h
#import <gmp.h>
#import <mpfr.h>
```

### Example Usage

#### GMP Integer Arithmetic
```objc
#import <gmp.h>

- (NSString *)calculateLargePower {
    mpz_t result;
    mpz_init(result);
    mpz_ui_pow_ui(result, 2, 100);  // Calculate 2^100
    
    char *str = mpz_get_str(NULL, 10, result);
    NSString *resultString = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    
    free(str);
    mpz_clear(result);
    return resultString;
}
```

#### MPFR Floating-Point Arithmetic
```objc
#import <gmp.h>
#import <mpfr.h>

- (NSString *)calculatePiWithPrecision:(int)precision {
    mpfr_t pi;
    mpfr_init2(pi, precision);
    mpfr_const_pi(pi, MPFR_RNDN);
    
    char *str = mpfr_get_str(NULL, NULL, 10, 0, pi, MPFR_RNDN);
    NSString *piString = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
    
    mpfr_free_str(str);
    mpfr_clear(pi);
    return piString;
}
```

## Flutter Integration

Both XCFrameworks work with Flutter iOS projects using FFI. You'll need to link both frameworks and create appropriate Dart bindings for the C functions you want to use.

## Technical Notes

### Build Dependencies
- **MPFR depends on GMP**: Always build GMP first, then MPFR
- **Linked libraries**: MPFR libraries are linked against their corresponding GMP architecture libraries
- **Header dependencies**: MPFR compilation requires GMP headers from the built GMP source

### Why Manual XCFramework Assembly?
This project uses manual XCFramework creation instead of `xcodebuild -create-xcframework` because:
- Xcode's tool has issues with multiple `arm64` architectures (device vs simulator)
- Manual assembly provides more control and reliability
- The resulting XCFrameworks are identical to Xcode-generated ones

### Architecture Support
- **Minimum iOS Version**: 13.0
- **Supported Architectures**: arm64 (device + simulator), x86_64 (simulator)
- **Removed Legacy Support**: armv7, armv7s, i386 (32-bit architectures)

### Build Configuration
- **Optimization**: `-Os` (optimize for size)
- **Assembly**: Disabled (`--disable-assembly`) for iOS compatibility  
- **Linking**: Static libraries only (`--disable-shared`)
- **Debug Info**: DWARF-2 format for Xcode compatibility
- **MPFR Thread Safety**: Disabled (`--disable-thread-safe`) for iOS compatibility

## Troubleshooting

### "Command not found" errors
```bash
# Make scripts executable
chmod +x build_gmp.sh build_mpfr.sh ios_compile_test.sh
```

### "SDK path not found" 
- Install Xcode Command Line Tools: `xcode-select --install`
- Verify Xcode is properly installed

### "GMP build not found" when building MPFR
- Run `./build_gmp.sh` first - MPFR requires GMP to be built
- Verify `build/lib/` contains the GMP libraries

### Build fails on specific architecture
- Check that you have the correct Xcode and iOS SDK installed
- Ensure you're building on a supported macOS version

### Linking errors in iOS app
- Ensure both frameworks are added to your Xcode project
- Verify both appear in "Link Binary With Libraries"
- Check that you're importing the correct headers

### XCFramework not recognized by Xcode
- Verify the framework structure matches the output above
- Try cleaning Xcode build folder and rebuilding your project

## Updating Library Versions

### To update GMP:
1. Download the desired `.tar.bz2` from [gmplib.org](https://gmplib.org/#DOWNLOAD)
2. Update the `VERSION` variable in `build_gmp.sh`
3. Update the `SOFTWARETAR` path if filename differs
4. Run `./build_gmp.sh`

### To update MPFR:
1. Download the desired `.tar.xz` from [mpfr.org](https://www.mpfr.org/mpfr-current/)
2. Update the `VERSION` variable in `build_mpfr.sh`
3. Update the `SOFTWARETAR` path if filename differs
4. Rebuild both: `./build_gmp.sh` then `./build_mpfr.sh`

## License

This build system is released under the MIT License. GMP itself is dual-licensed under LGPL v3+ and GPL v2+. MPFR is licensed under LGPL v3+.

## Credits

Based on [NeoTeo/gmp-ios-builder](https://github.com/NeoTeo/gmp-ios-builder) with modernization for current iOS development practices and extended to support MPFR.