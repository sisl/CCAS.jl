Under construction...

# CCAS

CCAS is a Julia wrapper for the MIT-LL libcas (ACASX) C library and interface.  (libcas not included)

## Authors

Ritchie Lee, Ph.D. Student, ritchie.lee@sv.cmu.edu

## Installation

Dependencies: 
* Boost C++ Libraries  >1.57.0
* Boost::Extensions
* LibCAS distribution


CMake will try to automatically find your Boost installation.  If Boost is unable to find it, you can specify the directory manually by defining the BOOST_ROOT environment variable.

```
#!text

CCAS.jl                           wrapper module

src/
    CCAS.jl                         Julia wrapper

csrc/
    SISLES.jl                       top-level include file for developers

clib/


```

## Example Usage

TODO


***

*Last Updated: 11/19/2014*