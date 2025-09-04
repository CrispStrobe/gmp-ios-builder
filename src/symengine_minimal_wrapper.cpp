/*
 * symengine_minimal_wrapper.cpp
 * Minimal C++ implementation for SymEngine wrapper
 * Single source of truth for math-stack-ios-builder
 */
#include "symengine_minimal_wrapper.h"
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
        // Clean up trailing zeros for cleaner output
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
        // Note: SymEngine's factor functionality is limited in the C++ API
        // For now, return expanded form as placeholder
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

} // extern "C"