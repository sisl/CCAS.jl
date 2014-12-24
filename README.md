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

1. Clone CCAS package into your Julia packages folder.
2. Put libcas interface files (.h files) under CCAS/libcas/interface
3. Put libcas library files (dll files) under CCAS/libcas/lib
4. Put libcas config files (.txt and .dat files) under CCAS/libcas/parameters.  The main config file contains paths to the other config files.  Make sure to edit the paths.
5. 

CMake will try to automatically find your Boost installation.  If Boost is unable to find it, you can specify the directory manually by defining the BOOST_ROOT environment variable.

## Directory Structure

CCAS/                                   Package - Top level

libcas/                                   Libcas distribution top

libcas/interface                     Place libcas header files here

libcas/lib                               Place libcas library files here

libcas/parameters                Place libcas config files here

libccas/                                C wrapper for libcas that stands between Julia and libcas

libccas/doc                          Libccas documentation

libccas/include                    Libccas header files

libccas/lib                            Libccas library files

libccas/src                           Libccas C source files

libccas/src/Build                  Libccas CMake build directory

libccas/VS                           Visual Studio projects for debugging libccas

src/                                     Julia module source

test/                                    Julia module tests

## Example Usage

TODO


***

*Last Updated: 11/19/2014*