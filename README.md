# gmp-ios-builder

A build system for creating iOS XCFrameworks from the [GNU Multiple Precision Arithmetic Library (GMP)](https://gmplib.org/). This project builds GMP 6.3.0 as a static XCFramework that should work on both iOS devices and simulators (Intel and Apple Silicon).

## What This Builds

The build process creates `GMP.xcframework` containing:
- **iOS Device** (arm64): For physical iPhones and iPads
- **iOS Simulator** (arm64): For Apple Silicon Mac simulators  
- **iOS Simulator** (x86_64): For Intel Mac simulators

## Requirements

- **macOS** with Xcode and Command Line Tools installed
- **Bash** (any modern version - the scripts are compatible with macOS's default bash 3.2+)
- **GMP 6.3.0 source** (included as `gmp-6.3.0.tar.bz2`)

## Quick Start

### Build Everything from Scratch
```bash
# Clone or download this repository
# Make sure gmp-6.3.0.tar.bz2 is in the root directory

# Build all architectures and create XCFramework
chmod +x build_gmp.sh
./build_gmp.sh
```

### Create XCFramework from Existing Libraries
```bash
# If you already have the individual architecture libraries built
chmod +x pack_libs.sh  
./pack_libs.sh
```

## Scripts Overview

### `build_gmp.sh`
The main build script that:
1. Extracts GMP 6.3.0 source code
2. Configures and builds for each target architecture:
   - `iphoneos-arm64` (iOS devices)
   - `iphonesimulator-arm64` (Apple Silicon simulators)
   - `iphonesimulator-x86_64` (Intel simulators)
3. Creates the final `GMP.xcframework` using a manual assembly process

**Key Features:**
- Uses modern iOS deployment target (13.0+)
- Removes deprecated compiler flags (`-fembed-bitcode`)
- Supports only 64-bit architectures (removed old 32-bit support)
- Uses `--disable-assembly` for reliable iOS builds
- Handles Apple Silicon vs Intel architecture naming correctly

### `pack_libs.sh`
A utility script that creates `GMP.xcframework` from pre-built individual architecture libraries. Useful for:
- Re-packaging after build script changes
- Creating XCFramework without full rebuild
- Debugging framework assembly issues

## Build Output

After running `./build_gmp.sh`, you'll have:

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
```

## Using in iOS Projects

### Xcode Integration
1. **Add Framework**: Drag `GMP.xcframework` into your Xcode project
2. **Link Binary**: Ensure it appears in your target's "Link Binary With Libraries" 
3. **Import**: Use `#import <gmp.h>` in your Objective-C code

### Swift Integration
Create a bridging header and import GMP:
```objc
// In YourProject-Bridging-Header.h
#import <gmp.h>
```

### Example Usage
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

## Flutter Integration

This XCFramework works fine with Flutter iOS projects using FFI. See the companion Flutter example for detailed integration steps.

## Technical Notes

### Why Manual XCFramework Assembly?
This project uses manual XCFramework creation instead of `xcodebuild -create-xcframework` because:
- Xcode's tool has issues with multiple `arm64` architectures (device vs simulator)
- Manual assembly provides more control and reliability
- The resulting XCFramework is identical to Xcode-generated ones

### Architecture Support
- **Minimum iOS Version**: 13.0
- **Supported Architectures**: arm64 (device + simulator), x86_64 (simulator)
- **Removed Legacy Support**: armv7, armv7s, i386 (32-bit architectures)

### Build Configuration
- **Optimization**: `-Os` (optimize for size)
- **Assembly**: Disabled (`--disable-assembly`) for iOS compatibility  
- **Linking**: Static libraries only (`--disable-shared`)
- **Debug Info**: DWARF-2 format for Xcode compatibility

## Troubleshooting

### "Command not found" errors
```bash
# Make scripts executable
chmod +x build_gmp.sh pack_libs.sh
```

### "SDK path not found" 
- Install Xcode Command Line Tools: `xcode-select --install`
- Verify Xcode is properly installed

### Build fails on specific architecture
- Check that you have the correct Xcode and iOS SDK installed
- Ensure you're building on a supported macOS version

### XCFramework not recognized by Xcode
- Verify the framework structure matches the output above
- Try cleaning Xcode build folder and rebuilding your project

## Updating GMP Version

To use a different GMP version:
1. Download the desired `.tar.bz2` from [gmplib.org](https://gmplib.org/#DOWNLOAD)
2. Update the `VERSION` variable in `build_gmp.sh`
3. Update the `SOFTWARETAR` path if filename differs
4. Run `./build_gmp.sh`

## License

This build system is released under the MIT License. GMP itself is dual-licensed under LGPL v3+ and GPL v2+.

## Credits

Based on [NeoTeo/gmp-ios-builder](https://github.com/NeoTeo/gmp-ios-builder) with modernization for current iOS development practices.