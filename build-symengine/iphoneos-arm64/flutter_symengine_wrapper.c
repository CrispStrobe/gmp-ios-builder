/*
 * flutter_symengine_wrapper.c
 * Flutter-specific C wrapper implementation using SymEngine cwrapper.h API
 * All functions renamed with flutter_ prefix to avoid conflicts
 */
#include "flutter_symengine_wrapper.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symengine/cwrapper.h"

// Error handling helper
static char* create_error_string(const char* operation, const char* error) {
    size_t len = strlen("Error in ") + strlen(operation) + strlen(": ") + strlen(error) + 1;
    char* result = (char*)malloc(len);
    if (result) {
        snprintf(result, len, "Error in %s: %s", operation, error);
    }
    return result;
}

// Helper function to convert basic to string safely
static char* basic_to_string_safe(basic b) {
    char* result = basic_str(b);
    if (!result) {
        result = (char*)malloc(20);
        if (result) {
            strcpy(result, "conversion_error");
        }
    }
    return result;
}

// Core SymEngine wrapper functions for Flutter FFI (ALL with flutter_ prefix)
char* flutter_symengine_evaluate(const char* expression) {
    if (!expression) {
        return create_error_string("evaluate", "null expression");
    }
    
    basic expr;
    basic_new_stack(expr);
    
    // Parse the expression
    CWRAPPER_OUTPUT_TYPE parse_result = basic_parse(expr, expression);
    if (parse_result != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(expr);
        return create_error_string("evaluate", "parse failed");
    }
    
    // For evaluation, expand and simplify
    basic result;
    basic_new_stack(result);
    
    CWRAPPER_OUTPUT_TYPE expand_result = basic_expand(result, expr);
    if (expand_result != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(expr);
        basic_free_stack(result);
        return create_error_string("evaluate", "expansion failed");
    }
    
    char* result_str = basic_to_string_safe(result);
    
    basic_free_stack(expr);
    basic_free_stack(result);
    
    return result_str;
}

char* flutter_symengine_solve(const char* expression, const char* symbol) {
    if (!expression || !symbol) {
        return create_error_string("solve", "null input");
    }
    
    basic expr, sym;
    basic_new_stack(expr);
    basic_new_stack(sym);
    
    // Parse expression and symbol
    if (basic_parse(expr, expression) != SYMENGINE_NO_EXCEPTION ||
        symbol_set(sym, symbol) != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(expr);
        basic_free_stack(sym);
        return create_error_string("solve", "parsing failed");
    }
    
    // Try to solve as polynomial
    CSetBasic* solutions = setbasic_new();
    CWRAPPER_OUTPUT_TYPE solve_result = basic_solve_poly(solutions, expr, sym);
    
    char* result_str;
    if (solve_result == SYMENGINE_NO_EXCEPTION) {
        // Convert solutions to string representation
        size_t num_solutions = setbasic_size(solutions);
        if (num_solutions == 0) {
            result_str = (char*)malloc(20);
            if (result_str) {
                strcpy(result_str, "no_solutions");
            }
        } else {
            // For simplicity, get first solution
            basic first_solution;
            basic_new_stack(first_solution);
            setbasic_get(solutions, 0, first_solution);
            result_str = basic_to_string_safe(first_solution);
            basic_free_stack(first_solution);
        }
    } else {
        result_str = create_error_string("solve", "solve failed");
    }
    
    setbasic_free(solutions);
    basic_free_stack(expr);
    basic_free_stack(sym);
    
    return result_str;
}

char* flutter_symengine_factor(const char* expression) {
    if (!expression) {
        return create_error_string("factor", "null expression");
    }
    
    basic expr;
    basic_new_stack(expr);
    
    if (basic_parse(expr, expression) != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(expr);
        return create_error_string("factor", "parse failed");
    }
    
    // SymEngine doesn't have a direct factor function in the C wrapper
    // For now, return expanded form as placeholder
    basic result;
    basic_new_stack(result);
    
    if (basic_expand(result, expr) != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(expr);
        basic_free_stack(result);
        return create_error_string("factor", "expansion failed");
    }
    
    char* result_str = basic_to_string_safe(result);
    
    basic_free_stack(expr);
    basic_free_stack(result);
    
    return result_str;
}

char* flutter_symengine_expand(const char* expression) {
    if (!expression) {
        return create_error_string("expand", "null expression");
    }
    
    basic expr;
    basic_new_stack(expr);
    
    if (basic_parse(expr, expression) != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(expr);
        return create_error_string("expand", "parse failed");
    }
    
    basic result;
    basic_new_stack(result);
    
    if (basic_expand(result, expr) != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(expr);
        basic_free_stack(result);
        return create_error_string("expand", "expansion failed");
    }
    
    char* result_str = basic_to_string_safe(result);
    
    basic_free_stack(expr);
    basic_free_stack(result);
    
    return result_str;
}

void flutter_symengine_free_string(char* str) {
    if (str) {
        // Since we're using malloc in our wrapper, use free()
        free(str);
    }
}

// Utility functions
char* flutter_symengine_version(void) {
    // Return a static version string for now
    return strdup("SymEngine Flutter Wrapper v1.0");
}

char* flutter_symengine_test_basic_operations(void) {
    basic x, y, result;
    basic_new_stack(x);
    basic_new_stack(y);
    basic_new_stack(result);
    
    // Test basic operations: x + y where x=2, y=3
    integer_set_si(x, 2);
    integer_set_si(y, 3);
    
    if (basic_add(result, x, y) != SYMENGINE_NO_EXCEPTION) {
        basic_free_stack(x);
        basic_free_stack(y);
        basic_free_stack(result);
        return create_error_string("test", "addition failed");
    }
    
    char* result_str = basic_to_string_safe(result);
    
    basic_free_stack(x);
    basic_free_stack(y);
    basic_free_stack(result);
    
    return result_str;
}

char* flutter_symengine_test_symbolic(void) {
    basic x, expr, result;
    basic_new_stack(x);
    basic_new_stack(expr);
    basic_new_stack(result);
    
    // Create symbol x
    symbol_set(x, "x");
    
    // Create expression x^2 + 2*x + 1
    basic x2, two, one, term1, term2;
    basic_new_stack(x2);
    basic_new_stack(two);
    basic_new_stack(one);
    basic_new_stack(term1);
    basic_new_stack(term2);
    
    integer_set_si(two, 2);
    integer_set_si(one, 1);
    
    // x^2
    basic_pow(x2, x, two);
    // 2*x  
    basic_mul(term1, two, x);
    // x^2 + 2*x
    basic_add(term2, x2, term1);
    // x^2 + 2*x + 1
    basic_add(expr, term2, one);
    
    // Expand the expression
    basic_expand(result, expr);
    
    char* result_str = basic_to_string_safe(result);
    
    basic_free_stack(x);
    basic_free_stack(expr);
    basic_free_stack(result);
    basic_free_stack(x2);
    basic_free_stack(two);
    basic_free_stack(one);
    basic_free_stack(term1);
    basic_free_stack(term2);
    
    return result_str;
}

// Extended functions - implement core ones, placeholder for others
char* flutter_symengine_differentiate(const char* expression, const char* symbol) {
    return create_error_string("differentiate", "not implemented yet");
}

char* flutter_symengine_integrate(const char* expression, const char* symbol) {
    return create_error_string("integrate", "not implemented yet");
}

char* flutter_symengine_simplify(const char* expression) {
    // For now, use expand as a basic simplification
    return flutter_symengine_expand(expression);
}

char* flutter_symengine_substitute(const char* expression, const char* symbol, const char* value) {
    return create_error_string("substitute", "not implemented yet");
}

// Placeholder implementations for other functions
char* flutter_symengine_gcd(const char* a, const char* b) {
    return create_error_string("gcd", "not implemented yet");
}

char* flutter_symengine_lcm(const char* a, const char* b) {
    return create_error_string("lcm", "not implemented yet");
}

char* flutter_symengine_factorial(int n) {
    if (n < 0 || n > 20) {
        return create_error_string("factorial", "invalid input");
    }
    
    long long result = 1;
    for (int i = 2; i <= n; i++) {
        result *= i;
    }
    
    char* result_str = (char*)malloc(32);
    if (result_str) {
        snprintf(result_str, 32, "%lld", result);
    }
    return result_str;
}

char* flutter_symengine_fibonacci(int n) {
    if (n < 0 || n > 50) {
        return create_error_string("fibonacci", "invalid input");
    }
    
    if (n <= 1) {
        char* result = (char*)malloc(8);
        if (result) {
            snprintf(result, 8, "%d", n);
        }
        return result;
    }
    
    long long a = 0, b = 1, result;
    for (int i = 2; i <= n; i++) {
        result = a + b;
        a = b;
        b = result;
    }
    
    char* result_str = (char*)malloc(32);
    if (result_str) {
        snprintf(result_str, 32, "%lld", result);
    }
    return result_str;
}

char* flutter_symengine_get_pi(void) {
    return strdup("pi");
}

char* flutter_symengine_get_e(void) {
    return strdup("E");
}

char* flutter_symengine_get_euler_gamma(void) {
    return strdup("EulerGamma");
}

char* flutter_symengine_matrix_det(const char* matrix_str, int rows, int cols) {
    return create_error_string("matrix_det", "not implemented yet");
}

char* flutter_symengine_matrix_inv(const char* matrix_str, int rows, int cols) {
    return create_error_string("matrix_inv", "not implemented yet");
}