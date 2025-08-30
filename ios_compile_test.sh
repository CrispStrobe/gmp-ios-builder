#!/bin/bash
# ios_compile_test.sh - Test that your XCFrameworks can be compiled for iOS

# Create a minimal test file
cat > ios_gmp_test.c << 'EOL'
#include <gmp.h>
#include <mpfr.h>

int test_basic_gmp() {
    mpz_t result;
    mpz_init(result);
    mpz_ui_pow_ui(result, 2, 64);  // 2^64
    mpz_clear(result);
    return 0;
}

int test_basic_mpfr() {
    mpfr_t pi;
    mpfr_init2(pi, 64);
    mpfr_const_pi(pi, MPFR_RNDN);
    mpfr_clear(pi);
    return 0;
}

int main() {
    test_basic_gmp();
    test_basic_mpfr();
    return 0;
}
EOL

echo "Testing iOS device compilation..."
xcrun -sdk iphoneos clang -arch arm64 \
    -F. \
    -I GMP.xcframework/ios-arm64 \
    -I MPFR.xcframework/ios-arm64 \
    ios_gmp_test.c \
    GMP.xcframework/ios-arm64/libgmp.a \
    MPFR.xcframework/ios-arm64/libmpfr.a \
    -o ios_test_device

echo "Testing iOS simulator compilation..."
xcrun -sdk iphonesimulator clang -arch arm64 \
    -F. \
    -I GMP.xcframework/ios-arm64-simulator \
    -I MPFR.xcframework/ios-arm64-simulator \
    ios_gmp_test.c \
    GMP.xcframework/ios-arm64-simulator/libgmp.a \
    MPFR.xcframework/ios-arm64-simulator/libmpfr.a \
    -o ios_test_simulator

echo "✅ If no errors above, your XCFrameworks compiled successfully!"
echo "✅ Libraries are ready for iOS integration"

# Clean up
rm -f ios_gmp_test.c ios_test_device ios_test_simulator
