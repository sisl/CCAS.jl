# CCAS

CCAS is a Julia wrapper for the MIT-LL libcas (ACAS X) C library and interface.  (libcas not included)

## Authors

Ritchie Lee, ritchie.lee@sv.cmu.edu

## Installation

Dependencies: 

* Libcas distribution
* Visual Studio 2013 redistributable for Windows dll (Windows only)

1. Clone CCAS package into your Julia packages folder.
1. Create a folder for the libcas distribution.  e.g., CCAS/libcas0.10.1, and create the following subfolders and put the corresponding libcas distribution files into the respective folders:
  1. CCAS/libcas0.10.1/interface to contain all the .h header files
  1. CCAS/libcas0.10.1/parameters to contain all the configuration files.
  1. CCAS/libcas0.10.1/lib to contain the dll or so binary library.
1. Edit the configuration file to use the absolute paths to the dependent parameter files. 

## Building libccas from source

Dependencies:

* Boost C++ Libraries  >1.46.0
* Boost::Extensions (Put the Extensions folder inside your Boost folder alongside the other component folders, see Downloads section)
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

Testing your installation of CCAS:

1. Start a Julia session at CCAS/test
1. include("runtests.jl")
1. runtest(libcas, libcas_config), where libcas is path to libcas dynamic library, and libcas_config is path to main parameter file.
1. It should complete without errors and you should see author information, libcas version, some ACAS X output (including dh_min=-9999.0, dh_max=9999.0), No Errors, and Done! 

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

*Last Updated: 11/3/2016*
