# iOS Mathematical Computing Stack Builder

[](https://developer.apple.com/ios/)
[](https://developer.apple.com/documentation/xcode/building_a_universal_macos_binary)
[](https://opensource.org/licenses/MIT)

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
| `SymEngine.xcframework`   | [SymEngine](https://symengine.org/) 0.11.2                           | A fast symbolic manipulation library.            |

Each framework is built with universal support for physical devices (`arm64`) and simulators (`arm64`, `x86_64`).

-----

## Requirements

  - **macOS** with Xcode and Command Line Tools installed.
  - **CMake**: Required for building SymEngine (`brew install cmake`).
  - **Source Archives**: The following tarballs must be in the project's root directory:
      - `gmp-6.3.0.tar.bz2`
      - `mpfr-4.2.2.tar.xz`
      - `mpc-1.3.1.tar.gz`
      - `flint-3.3.1.tar.gz`
      - `symengine-0.11.2.tar.gz`

-----

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

# 5. Build SymEngine (depends on all of the above)
./build_symengine.sh

# All five XCFrameworks are now ready in the project directory.
```

-----

## Using in iOS Projects

While the .xcframework bundles produced by this project can be used in native Xcode projects, using them in a Flutter application is facilitated by a specific architecture to overcome challenges with static linking. The process is demonstrated in two companion repositories:
* [gmp-bridge](https://github.com/CrispStrobe/gmp-bridge): A local Flutter bridge plugin that wraps the native GMP library.
* [gmp-flutter-test](https://github.com/CrispStrobe/gmp-flutter-test): A Flutter demo app that uses the plugin.

### The Challenge: Symbol Stripping
When linking a static library (.a) to a Flutter app, the native Xcode build process often fails to see any usage of the C functions, as they are only called from the Dart VM via FFI at runtime. This causes the linker to aggressively "strip" the library's code from the final app binary to save space, leading to "symbol not found" errors when your Dart code tries to call the functions.

### The Solution: A Local Plugin Bridge
A robust solution is to create a local Flutter plugin that acts as a bridge. This approach uses iOS's standard dependency manager, CocoaPods, to correctly link the library and prevent symbol stripping.

The architecture works as follows:

* Build the Static Library: This repository (gmp-ios-builder) is used to compile GMP into a universal static library for the simulator (e.g., libgmp-simulator.a).
* Create a Plugin Wrapper (gmp_bridge): A local Flutter plugin is created. The libgmp-simulator.a file is placed inside its ios/ directory. The plugin's configuration file, gmp_bridge.podspec, is modified to command the linker. It tells CocoaPods to find the library and, most importantly, to force-load all of its symbols.

```ruby
# In gmp_bridge/ios/gmp_bridge.podspec

# 1. Tell CocoaPods where to find the static library.
s.vendored_libraries = 'libgmp-simulator.a'

# 2. Add the linker flag to prevent symbol stripping.
s.pod_target_xcconfig = {
  'OTHER_LDFLAGS' => '-force_load "${PODS_TARGET_SRCROOT}/libgmp-simulator.a"'
}
```

* Use the Plugin in the App (gmp_test_app): The main Flutter app adds a local path dependency to the gmp_bridge plugin in its pubspec.yaml. When the app is built, CocoaPods automatically creates a gmp_bridge.framework containing the GMP code. The Dart FFI code can then explicitly load this framework to access the GMP functions.

```ruby
// In gmp_test_app/lib/cas_bridge.dart

// Load the framework created by the plugin, not the main app binary.
_dylib = DynamicLibrary.open('gmp_bridge.framework/gmp_bridge');

// Look up and call GMP functions as needed.
_mpz_pow_ui = _dylib
    .lookup<NativeFunction<MpzPowUiNative>>('__gmpz_pow_ui')
    .asFunction();
```

This plugin-based architecture is the recommended pattern for integrating complex native C/C++ static libraries into a modern Flutter application for iOS.

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

-----

## Troubleshooting

### "Command not found" or Permission Denied

Run `chmod +x build_*.sh` to make all build scripts executable.

### "SDK path not found"

Install the Xcode Command Line Tools via `xcode-select --install`.

### "GMP build not found" (or similar dependency error)

You must run the build scripts in the correct order as described in the "Quick Start" section.

### Linking errors in your iOS app

  - Ensure all five frameworks are added to your Xcode project target.
  - Verify they all appear in the "Link Binary With Libraries" build phase.

-----

## License

This build system is released under the **MIT License**. The underlying mathematical libraries are available under their own open-source licenses (LGPL, GPL), which you must comply with in your application.

## Credits

This project modernizes and extends the concepts from [NeoTeo/gmp-ios-builder](https://github.com/NeoTeo/gmp-ios-builder) to create a full-featured mathematical computing stack.