# Install script for directory: /Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/Users/christianstrobele/code/math-stack-ios-builder/build-symengine/macosx-arm64/symengine/libsymengine.a")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsymengine.a" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsymengine.a")
    execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsymengine.a")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES
    "/Users/christianstrobele/code/math-stack-ios-builder/build-symengine/macosx-arm64/symengine/symengine_config.h"
    "/Users/christianstrobele/code/math-stack-ios-builder/build-symengine/macosx-arm64/symengine/symengine_config_cling.h"
    "/Users/christianstrobele/code/math-stack-ios-builder/build-symengine/macosx-arm64/symengine/symengine_export.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/add.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/basic.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/basic-inl.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/basic-methods.inc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/complex_double.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/complex.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/complex_mpc.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/constants.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/cwrapper.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/derivative.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/dict.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/diophantine.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/eval_arb.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/eval_double.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/eval.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/eval_mpc.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/eval_mpfr.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/expression.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/fields.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/finitediff.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/flint_wrapper.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/functions.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/infinity.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/integer.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/lambda_double.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/llvm_double.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/logic.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrix.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/monomials.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/mp_class.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/mp_wrapper.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/mul.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/nan.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/ntheory.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/ntheory_funcs.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/number.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/parser.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/parser" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/parser/parser.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/parser" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/parser/tokenizer.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/parser/sbml" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/parser/sbml/sbml_parser.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/parser/sbml" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/parser/sbml/sbml_tokenizer.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/basic_conversions.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/cancel.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/uexprpoly.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/uintpoly_flint.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/uintpoly.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/uintpoly_piranha.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/upolybase.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/uratpoly.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/usymenginepoly.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/polys" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/polys/msymenginepoly.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/pow.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/prime_sieve.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/printers" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers/codegen.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/printers" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers/mathml.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/printers" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers/sbml.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/printers" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers/strprinter.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/printers" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers/latex.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/printers" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers/unicode.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/printers" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers/stringbox.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/printers.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/rational.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/real_double.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/real_mpfr.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/rings.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/serialize-cereal.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/series_flint.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/series_generic.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/series.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/series_piranha.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/series_visitor.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/sets.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/solve.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/subs.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/symbol.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/symengine_assert.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/symengine_casts.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/symengine_exception.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/symengine_rcp.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/tribool.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/type_codes.inc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/visitor.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/test_visitors.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/assumptions.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/refine.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/simplify.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/stream_fmt.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/tuple.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrix_expressions.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/matrix_expr.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/identity_matrix.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/matrix_symbol.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/zero_matrix.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/diagonal_matrix.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/immutable_dense_matrix.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/matrix_add.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/hadamard_product.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/matrix_mul.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/conjugate_matrix.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/size.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/transpose.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/matrices" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/matrices/trace.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/access.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/archives" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/archives/adapters.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/archives" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/archives/binary.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/archives" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/archives/json.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/archives" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/archives/portable_binary.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/archives" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/archives/xml.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/cereal.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/details" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/details/helpers.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/details" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/details/polymorphic_impl.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/details" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/details/polymorphic_impl_fwd.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/details" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/details/static_object.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/details" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/details/traits.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/details" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/details/util.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/macros.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/specialize.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/array.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/atomic.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/base_class.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/bitset.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/boost_variant.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/chrono.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/common.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/complex.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types/concepts" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/concepts/pair_associative_container.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/deque.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/forward_list.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/functional.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/list.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/map.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/memory.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/optional.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/polymorphic.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/queue.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/set.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/stack.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/string.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/tuple.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/unordered_map.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/unordered_set.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/utility.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/valarray.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/variant.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal/types" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/types/vector.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/symengine/utilities/cereal/include/cereal" TYPE FILE FILES "/Users/christianstrobele/code/math-stack-ios-builder/symengine-0.11.2/symengine/utilities/cereal/include/cereal/version.hpp")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/christianstrobele/code/math-stack-ios-builder/build-symengine/macosx-arm64/symengine/utilities/matchpycpp/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/christianstrobele/code/math-stack-ios-builder/build-symengine/macosx-arm64/symengine/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
