# iOS Mathematical Computing Stack Builder

[![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue)](https://developer.apple.com/ios/)
[![Universal](https://img.shields.io/badge/Universal-arm64%20%7C%20x86__64-green)](https://developer.apple.com/documentation/xcode/building_a_universal_macos_binary)
[![License](https://img.shields.io/badge/License-MIT-yellow)](https://opensource.org/licenses/MIT)

A complete build system for creating a powerful mathematical computing stack for iOS. This project compiles **GMP, MPFR, MPC, FLINT, and SymEngine** as static `XCFrameworks` that work on modern iOS devices and simulators (Intel and Apple Silicon).

This provides a full suite of tools for arbitrary-precision arithmetic, number theory, and symbolic manipulation directly on iOS.

## What This Builds

The build process creates five interdependent `XCFrameworks`:

| Framework                 | Library                                                              | Purpose                                          |
| ------------------------- | -------------------------------------------------------------------- | ------------------------------------------------ |
| `GMP.xcframework`         | [GNU Multiple Precision](https://gmplib.org/) 6.3.0                  | Arbitrary-precision integer arithmetic.          |
| `MPFR.xcframework`        | [Multiple-Precision Floating-Point](https://www.mpfr.org/) 4.2.2     | Correctly rounded arbitrary-precision floats.    |
| `MPC.xcframework`         | [Multiple-Precision Complex](http://www.multiprecision.org/) 1.3.1    | Arbitrary-precision complex number arithmetic.   |
| `FLINT.xcframework`       | [Fast Library for Number Theory](https://flintlib.org/) 3.3.1        | Advanced number theory, polynomials, and matrices. |
| `SymEngineWrapper.xcframework` | [SymEngine](https://symengine.org/) 0.11.2 + C Wrapper           | Fast symbolic manipulation with C API.            |

Each framework is built with universal support for physical devices (`arm64`) and simulators (`arm64`, `x86_64`).

## Requirements

- **macOS** with Xcode and Command Line Tools installed.
- **CMake**: Required for building SymEngine (`brew install cmake`).
- **Source Archives**: The following tarballs must be in the project's root directory:
    - `gmp-6.3.0.tar.bz2`
    - `mpfr-4.2.2.tar.xz`
    - `mpc-1.3.1.tar.gz`
    - `flint-3.3.1.tar.gz`
    - `symengine-0.11.2.tar.gz`

## Quick Start: Build the Entire Stack

The libraries have dependencies, so they **must be built in the correct order**.

```bash
# First, make all build scripts executable
chmod +x build_*.sh

# 1. Build GMP (no dependencies)
./build_gmp.sh

# 2. Build MPFR (depends on GMP)
./build_mpfr.sh

# 3. Build MPC (depends on GMP and MPFR)
./build_mpc.sh

# 4. Build FLINT (depends on GMP and MPFR)
./build_flint.sh

# 5. Build SymEngine with C wrapper (depends on all of the above)
./build_symengine.sh

# Copy the built frameworks to your plugin
./copy_symengine_wrapper.sh

# All five XCFrameworks are now ready for use.
```

## Integration with Flutter

This project is designed to work with the **symbolic_math_bridge** Flutter plugin architecture. The XCFrameworks are consumed by the plugin, which provides both high-level symbolic computing and direct low-level access to all mathematical libraries.

### Modern Architecture: Complete Stack Access

Unlike traditional approaches that require separate plugins for each library, this system provides unified access to the entire mathematical computing stack through a single Flutter plugin:

```dart
// High-level symbolic computing
final result = casBridge.evaluate('solve(x^2 + 2*x + 1, x)');

// Direct arbitrary-precision integer arithmetic (GMP)
final bigInt = casBridge.testGMPDirect(256); // 2^256

// Direct arbitrary-precision floating-point (MPFR) 
final pi = casBridge.testMPFRDirect(); // High-precision π calculation

// Direct complex number arithmetic (MPC)
final complex = casBridge.testMPCDirect(); // (3+4i) × (1+2i)

// Direct number theory functions (FLINT)
final factorial = casBridge.testFLINTDirect(); // 20!
```

### The Symbol Linking Solution

A key step in this system is circumventing the "symbol stripping" problem that occurs when static C libraries are used in Flutter apps. Our simple but robust solution involves:

1. **Force Symbol Loading**: The plugin's `SymEngineBridge.m` file contains references to 40+ core functions from all libraries, preventing the linker from stripping them.

2. **XCFramework Integration**: All libraries are packaged as XCFrameworks with proper header access for both plugin compilation and runtime symbol resolution.

3. **Unified Plugin Architecture**: A single plugin (`symbolic_math_bridge`) provides access to all libraries rather than requiring separate plugins for each.

## Companion Repositories

This build system is part of a complete mathematical computing solution:

- **[math-stack-ios-builder](https://github.com/CrispStrobe/math-stack-ios-builder)** (This Repository): Builds the XCFramework libraries
- **[symbolic_math_bridge](https://github.com/CrispStrobe/symbolic_math_bridge)**: Flutter plugin providing unified access to all libraries  
- **[math-stack-test](https://github.com/CrispStrobe/math-stack-test)**: Demo Flutter app showcasing the complete functionality

## Technical Notes

### Build Dependencies

The build order is enforced by dependencies between the libraries:

- **MPFR** requires **GMP**.
- **MPC** requires **GMP** and **MPFR**.
- **FLINT** requires **GMP** and **MPFR**.
- **SymEngine** requires **GMP**, **MPFR**, **MPC**, and **FLINT**.

### Build Configuration

- **Minimum iOS Version**: 13.0
- **Supported Architectures**: `arm64` (device + simulator), `x86_64` (simulator)
- **Assembly**: Disabled (`--disable-assembly`) for maximum iOS compatibility.
- **Linking**: Static libraries only (`--disable-shared`).
- **Thread Safety**: Disabled where applicable for simplicity in a typical iOS context.
- **SymEngine Wrapper**: Includes a C wrapper layer for easier FFI integration.

### SymEngine C Wrapper

The SymEngine build creates both the core library and a C wrapper that provides simplified access to common operations:

```c
// C wrapper functions created during build
char* symengine_evaluate(const char* expression);
char* symengine_solve(const char* expression, const char* symbol);
char* symengine_factor(const char* expression);
char* symengine_expand(const char* expression);
void symengine_free_string(char* str);
```

## Troubleshooting

### "Command not found" or Permission Denied

Run `chmod +x build_*.sh` to make all build scripts executable.

### "SDK path not found"

Install the Xcode Command Line Tools via `xcode-select --install`.

### "GMP build not found" (or similar dependency error)

You must run the build scripts in the correct order as described in the "Quick Start" section.

### Symbol Linking Issues in Flutter

If you encounter "symbol not found" errors:
- Ensure the `SymEngineBridge.m` file includes all necessary symbol references
- Verify the plugin's `.podspec` uses `-all_load` and `DEAD_CODE_STRIPPING = NO`
- Check that all XCFrameworks are properly included in the plugin

## License

This build system is released under the **MIT License**. The underlying mathematical libraries are available under their own open-source licenses (LGPL, GPL), which you must comply with in your application.

## Credits

This project modernizes and extends concepts from [NeoTeo/gmp-ios-builder](https://github.com/NeoTeo/gmp-ios-builder) to create a full-featured mathematical computing stack with unified Flutter integration.