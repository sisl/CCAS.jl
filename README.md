Under construction...

# CCAS

CCAS is a Julia wrapper for the MIT-LL libcas (ACASX) C library and interface.  (libcas not included)

## Authors

Ritchie Lee, ritchie.lee@sv.cmu.edu

## Installation

Dependencies: 
* Boost C++ Libraries  >1.57.0
* Boost::Extensions (Put the Extensions folder inside your Boost folder alongside the other component folders)
* LibCAS distribution

1. Clone CCAS package into your Julia packages folder.
2. Put libcas interface files (.h files) under CCAS/libcas/interface
3. Put libcas library files (dll files) under CCAS/libcas/lib
4. Put libcas config files (.txt and .dat files) under CCAS/libcas/parameters.  The main config file contains paths to the other config files.  Make sure to edit the paths.
5. Check under CCAS/libccas/lib for available precompiled libraries.  Choose the desired version and rename it to libccas.dll (libccas.lib is not required).  If the desired libraries are not available, then you will need to compile it from source.

To build libccas from source (Windows):
1. Go to CCAS/libccas/src/Build
2. Choose Visual Studio target and run CMake on .. (parent directory).
Note: CMake will try to automatically find your Boost installation.  If Boost is unable to find it, you can specify the directory manually by defining the BOOST_ROOT environment variable.
3. Build the generated solution file, then build the INSTALL project.  INSTALL will automatically put the files in the correct folders.


## Directory Structure
```
#!text

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

```

## Example Usage
```
#!text

using CCAS

#define constants
PACKAGE_PATH = Pkg.dir("CCAS")
const LIBCAS_CONFIG = joinpath(PACKAGE_PATH,"libcas/parameters/0.8.3.standard.r13.config.txt")
const LIBCAS_LIB = joinpath(PACKAGE_PATH,"libcas/lib/libcas.dll")
consts = Constants(25, LIBCAS_CONFIG, 1)
cas = CASShared(consts,LIBCAS_LIB) #main cas object
nintruders = max_intruders(cas)
inputVals = InputVals(nintruders) #create input structure
outputVals = OutputVals(nintruders) #create output structure
reset(cas) #reset the cas

#populate inputVals here...
#...

update!(cas,inputVals,outputVals)

#read output from outputVals here
#...

#read and handle error messages
errorMsg = error_msg(cas)
println( errorMsg == nothing ? "No Errors" : errorMsg )

```

***

*Last Updated: 12/24/2014*