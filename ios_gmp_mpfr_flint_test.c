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
