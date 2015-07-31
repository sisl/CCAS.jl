# CCAS

CCAS is a Julia wrapper for the MIT-LL libcas (ACASX) C library and interface.  (libcas not included)

## Authors

Ritchie Lee, ritchie.lee@sv.cmu.edu

## Installation

Dependencies: 

* Boost C++ Libraries  >1.46.0
* Boost::Extensions (Put the Extensions folder inside your Boost folder alongside the other component folders, see Downloads section)
* LibCAS distribution

1. Clone CCAS package into your Julia packages folder.
1. Check under CCAS/libccas/lib for available precompiled libraries.  Choose the desired version and rename it to libccas.dll (libccas.lib is not required).  If the desired libraries are not available, then you will need to compile them from source (see below).  Default is Windows x64.
1. When using the CCAS wrapper, you will need to provide (1) the path to the libcas configuration file, and (2) the path to the libcas library (e.g., libcas.dll in Windows).  Make sure to edit the configuration file so that the paths to the dependent parameter files are correct.

To build libccas from source (Windows):

1. Go to CCAS/libccas/src/Build
1. Choose Visual Studio target and run CMake on .. (parent directory).
Note: CMake will try to automatically find your Boost installation.  If Boost is unable to find it, you can specify the directory manually by defining the BOOST_ROOT environment variable.
1. Build the generated solution file, then build the INSTALL project.  INSTALL will automatically put the files in the correct folders.

To build libccas from source (Linux):

1. Go to CCAS/libccas/src/Build
1. cmake ..
Note: If cmake isn't able to automatically detect your boost installation, try setting the BOOST_ROOT environment variable.
1. make
1. make install

## Directory Structure
```
#!text

CCAS/                                   Package - Top level

libccas/                                C wrapper for libcas that stands between Julia and libcas
libccas/doc                          Libccas documentation
libccas/include                    Libccas header files
libccas/lib                            Libccas library files
libccas/src                           Libccas C source files
libccas/src/Build                  Libccas CMake build directory
libccas/VS                           Visual Studio projects for debugging libccas

src/                                     Julia module source

test/                                    Julia module tests

```

## Example Usage
```
#!text

using CCAS

#define constants
const LIBCAS_CONFIG = Pkg.dir("CCAS/libcas/parameters/0.8.3.standard.r13.config.txt")
const LIBCAS_LIB = Pkg.dir("CCAS/libcas/lib/libcas.dll")

consts = Constants(25, LIBCAS_CONFIG, 1)
cas = CASShared(consts,LIBCAS_LIB) #main cas object
nintruders = max_intruders(cas)
inputVals = InputVals(nintruders) #create input structure
outputVals = OutputVals(nintruders) #create output structure

reset(cas) #reset the cas

#loop start

#populate inputVals here...
#...

update!(cas,inputVals,outputVals)

#read output from outputVals here
#...

#read and handle error messages
errorMsg = error_msg(cas)
println( errorMsg == nothing ? "No Errors" : errorMsg )

#loop end

```

***

*Last Updated: 07/31/2015*