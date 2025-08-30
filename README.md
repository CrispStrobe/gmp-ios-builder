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

Each framework supports:

  - **iOS Device** (arm64): For physical iPhones and iPads.
  - **iOS Simulator** (arm64): For Apple Silicon Mac simulators.
  - **iOS Simulator** (x86\_64): For Intel Mac simulators.

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

### Xcode Integration

1.  **Add Frameworks**: Drag all five `.xcframework` bundles into your Xcode project's "Frameworks, Libraries, and Embedded Content" section.
2.  **Import Headers**: Use the appropriate headers in your Objective-C, Objective-C++, or Swift bridging header files.

### Swift Integration

Create a bridging header (`YourProject-Bridging-Header.h`) and import the C headers you need.

```objc
// In YourProject-Bridging-Header.h

// For basic arithmetic
#import <gmp.h>
#import <mpfr.h>
#import <mpc.h>

// For number theory
#import <flint/flint.h>
#import <flint/fmpz.h>
#import <flint/fmpz_poly.h>

// For symbolic math (use the C wrapper)
#import <symengine/cwrapper.h>
```

-----

## Example Usage

### GMP: Integer Arithmetic

```objc
#import <gmp.h>

mpz_t base, result;
mpz_init_set_ui(base, 2); // base = 2
mpz_init(result);
mpz_pow_ui(result, base, 512); // result = 2^512

char *str = mpz_get_str(NULL, 10, result);
NSLog(@"2^512 = %s", str);

free(str);
mpz_clears(base, result, NULL);
```

### MPFR & MPC: High-Precision Pi and Complex Log

```objc
#import <mpfr.h>
#import <mpc.h>

// Calculate Pi to 256 bits of precision
mpfr_t pi;
mpfr_init2(pi, 256);
mpfr_const_pi(pi, MPFR_RNDN);
mpfr_printf("Pi = %.50Rf\n", pi);

// Calculate log(1 + i*pi)
mpc_t z, res;
mpc_init2(z, 256);
mpc_init2(res, 256);
mpc_set_fr_fr(z, mpfr_get_si(pi, MPFR_RNDN), pi, MPC_RNDNN); // z = 1 + i*pi (approx)
mpc_log(res, z, MPC_RNDNN);
mpc_printf("log(1 + i*pi) = (%.10Rg, %.10Rg)\n", res);

mpfr_clear(pi);
mpc_clears(z, res, NULL);
```

### FLINT: Polynomial Factorization

```objc
#import <flint/fmpz.h>
#import <flint/fmpz_poly.h>
#import <flint/fmpz_poly_factor.h>

// Factor the polynomial x^2 - 4
fmpz_poly_t poly;
fmpz_poly_init(poly);
fmpz_poly_set_coeff_si(poly, 2, 1);  // 1*x^2
fmpz_poly_set_coeff_si(poly, 0, -4); // -4

fmpz_poly_factor_t factors;
fmpz_poly_factor_init(factors);
fmpz_poly_factor(factors, poly); // factorize

// Print factors: (x - 2) * (x + 2)
fmpz_poly_factor_print(factors);

fmpz_poly_clear(poly);
fmpz_poly_factor_clear(factors);
```

### SymEngine: Symbolic Differentiation

```objc
#import <symengine/cwrapper.h>

// Create a symbolic expression for sin(x)
CVecBasic *args = vec_basic_new();
CBasic *x = symbol("x");
vec_basic_push_back(args, x);
CBasic *expr = basic_function("sin", args);

// Differentiate sin(x) with respect to x
CBasic *deriv = basic_diff(expr, x);

// The result is cos(x)
char *s = basic_str(deriv);
NSLog(@"d/dx(sin(x)) = %s", s);

// Clean up
basic_free(deriv);
basic_free(expr);
basic_free(x);
vec_basic_free(args);
free(s);
```

-----

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