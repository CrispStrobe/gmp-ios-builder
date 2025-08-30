#!/bin/bash
# ios_compile_test.sh - Test that your XCFrameworks can be compiled for iOS

# Create a minimal test file that uses GMP, MPFR, and FLINT
cat > ios_gmp_mpfr_flint_test.c << 'EOL'
#include <gmp.h>
#include <mpfr.h>
#include <flint.h>
#include <fmpz.h>
#include <fmpq.h>

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

int test_basic_flint() {
    fmpz_t a, b, c;
    fmpq_t x, y, z;
    
    // Test FLINT integer arithmetic
    fmpz_init(a);
    fmpz_init(b); 
    fmpz_init(c);
    
    fmpz_set_ui(a, 123);
    fmpz_set_ui(b, 456);
    fmpz_mul(c, a, b);  // c = a * b
    
    fmpz_clear(a);
    fmpz_clear(b);
    fmpz_clear(c);
    
    // Test FLINT rational arithmetic
    fmpq_init(x);
    fmpq_init(y);
    fmpq_init(z);
    
    fmpq_set_si(x, 1, 2);  // x = 1/2
    fmpq_set_si(y, 3, 4);  // y = 3/4
    fmpq_add(z, x, y);     // z = x + y
    
    fmpq_clear(x);
    fmpq_clear(y);
    fmpq_clear(z);
    
    return 0;
}

int main() {
    // Initialize FLINT (required for FLINT 3.x)
    flint_init();
    
    test_basic_gmp();
    test_basic_mpfr();
    test_basic_flint();
    
    // Clean up FLINT
    flint_cleanup();
    
    return 0;
}
EOL

echo "🧪 Testing iOS device compilation (arm64)..."
xcrun -sdk iphoneos clang -arch arm64 \
    -F. \
    -I GMP.xcframework/ios-arm64 \
    -I MPFR.xcframework/ios-arm64 \
    -I FLINT.xcframework/ios-arm64 \
    -I FLINT.xcframework/ios-arm64/src \
    ios_gmp_mpfr_flint_test.c \
    GMP.xcframework/ios-arm64/libgmp.a \
    MPFR.xcframework/ios-arm64/libmpfr.a \
    FLINT.xcframework/ios-arm64/libflint.a \
    -o ios_test_device

if [ $? -eq 0 ]; then
    echo "✅ iOS device compilation successful!"
else
    echo "❌ iOS device compilation failed!"
    exit 1
fi

echo "🧪 Testing iOS simulator compilation (arm64)..."
xcrun -sdk iphonesimulator clang -arch arm64 \
    -F. \
    -I GMP.xcframework/ios-arm64-simulator \
    -I MPFR.xcframework/ios-arm64-simulator \
    -I FLINT.xcframework/ios-arm64-simulator \
    -I FLINT.xcframework/ios-arm64-simulator/src \
    ios_gmp_mpfr_flint_test.c \
    GMP.xcframework/ios-arm64-simulator/libgmp.a \
    MPFR.xcframework/ios-arm64-simulator/libmpfr.a \
    FLINT.xcframework/ios-arm64-simulator/libflint.a \
    -o ios_test_simulator_arm64

if [ $? -eq 0 ]; then
    echo "✅ iOS simulator (arm64) compilation successful!"
else
    echo "❌ iOS simulator (arm64) compilation failed!"
    exit 1
fi

echo "🧪 Testing iOS simulator compilation (x86_64)..."
xcrun -sdk iphonesimulator clang -arch x86_64 \
    -F. \
    -I GMP.xcframework/ios-x86_64-simulator \
    -I MPFR.xcframework/ios-x86_64-simulator \
    -I FLINT.xcframework/ios-x86_64-simulator \
    -I FLINT.xcframework/ios-x86_64-simulator/src \
    ios_gmp_mpfr_flint_test.c \
    GMP.xcframework/ios-x86_64-simulator/libgmp.a \
    MPFR.xcframework/ios-x86_64-simulator/libmpfr.a \
    FLINT.xcframework/ios-x86_64-simulator/libflint.a \
    -o ios_test_simulator_x86_64

if [ $? -eq 0 ]; then
    echo "✅ iOS simulator (x86_64) compilation successful!"
else
    echo "❌ iOS simulator (x86_64) compilation failed!"
    exit 1
fi

echo ""
echo "🎉 All compilations successful!"
echo "✅ Your GMP, MPFR, and FLINT XCFrameworks are ready for iOS integration"
echo ""
echo "📋 Integration summary:"
echo "   • GMP: Integer arithmetic with arbitrary precision"
echo "   • MPFR: Floating-point arithmetic with arbitrary precision"  
echo "   • FLINT: Advanced number theory (polynomials, matrices, factorization, etc.)"
echo ""
echo "📚 In your iOS project:"
echo "   1. Add all three XCFrameworks to your Xcode project"
echo "   2. Link all three in 'Build Phases' → 'Link Binary With Libraries'"
echo "   3. Import: #import <gmp.h>, #import <mpfr.h>, #import <flint.h>"
echo "   4. Include FLINT headers as needed: #import <fmpz.h>, #import <fmpq.h>, etc."
echo "   5. Call flint_init() at app startup and flint_cleanup() at shutdown"

# Clean up test files
rm -f ios_gmp_mpfr_flint_test.c ios_test_device ios_test_simulator_arm64 ios_test_simulator_x86_64