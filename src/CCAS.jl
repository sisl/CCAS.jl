# *****************************************************************************
# Written by Ritchie Lee, ritchie.lee@sv.cmu.edu
# *****************************************************************************
# Copyright ã 2015, United States Government, as represented by the
# Administrator of the National Aeronautics and Space Administration. All
# rights reserved.  The Reinforcement Learning Encounter Simulator (RLES)
# platform is licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You
# may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0. Unless required by applicable
# law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.
# _____________________________________________________________________________
# Reinforcement Learning Encounter Simulator (RLES) includes the following
# third party software. The SISLES.jl package is licensed under the MIT Expat
# License: Copyright (c) 2014: Youngjun Kim.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED
# "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# *****************************************************************************

module CCAS

if WORD_SIZE == 32
  const LIBCCAS = Pkg.dir("CCAS/libccas/lib/libccas_x32")
elseif WORD_SIZE == 64
  const LIBCCAS = Pkg.dir("CCAS/libccas/lib/libccas_x64")
else
  error("CCAS: Architecture must be 32-bit or 64-bit")
end

export   Equipage, EQUIPAGE, Constants, CASShared, reset, reset!, version, error_msg, max_intruders,
         OwnInputVals, IntruderInputVals, InputVals, IntruderOutputVals,
         OutputVals, update!, author

import Base.resize!
import Base.size
import Base.getindex
import Base.reset

immutable Equipage
  EQUIPAGE_ATCRBS::Int32
  EQUIPAGE_MODES::Int32
  EQUIPAGE_TCASTA::Int32
  EQUIPAGE_TCAS::Int32

  function Equipage()
    atcrbs = ccall((:enum_EQUIPAGE_ATCRBS,LIBCCAS),Int32,())
    modes = ccall((:enum_EQUIPAGE_MODES,LIBCCAS),Int32,())
    tcasta = ccall((:enum_EQUIPAGE_TCASTA,LIBCCAS),Int32,())
    tcas = ccall((:enum_EQUIPAGE_TCAS,LIBCCAS),Int32,())

    return new(atcrbs, modes, tcasta, tcas)
  end
end

EQUIPAGE = Equipage()

type OwnInputVals
  dz::Float64
  z::Float64
  psi::Float64
  h::Float64
  modes::UInt32

  OwnInputVals() = new(0.,0.,0.,0.,uint32(0))

  OwnInputVals(dz::Float64,z::Float64,psi::Float64,h::Float64,modes::Integer) =
    new(dz,z,psi,h,checked_convert(UInt32,modes))
end

function reset!(ownInput::OwnInputVals)
  ownInput.dz = 0.0
  ownInput.z = 0.0
  ownInput.psi = 0.0
  ownInput.h = 0.0
  ownInput.modes = uint32(0)
end

type IntruderInputVals
  valid::Bool
  id::UInt32
  modes::UInt32
  sr::Float64
  chi::Float64
  z::Float64
  cvc::UInt8
  vrc::UInt8
  vsb::UInt8
  equipage::Int32
  quant::UInt8
  sensitivity_index::UInt8
  protection_mode::UInt8

  IntruderInputVals() = new(false,uint32(0),uint32(0),0.,0.,0.,uint8(0),uint8(0),uint8(0),int32(0),
                            uint8(0),uint8(0),uint8(0))

  function IntruderInputVals(valid::Bool,id::UInt32,modes::UInt32,sr::Float64,chi::Float64,z::Float64,
                             cvc::UInt8,vrc::UInt8,vsb::UInt8,equipage::Int32,quant::UInt8,
                             sensitivity_index::UInt8,protection_mode::UInt8)
    obj              = new()
    obj.valid        = valid
    obj.id           = id
    obj.modes        = modes
    obj.sr           = sr
    obj.chi          = chi
    obj.z            = z
    obj.cvc          = cvc
    obj.vrc          = vrc
    obj.vsb          = vsb
    obj.equipage     = equipage
    obj.quant        = quant
    obj.sensitivity_index = sensitivity_index
    obj.protection_mode   = protection_mode

    return obj
  end
end

function reset!(iinput::IntruderInputVals)
  iinput.valid        = false
  iinput.id           = uint32(0)
  iinput.modes        = uint32(0)
  iinput.sr           = 0.0
  iinput.chi          = 0.0
  iinput.z            = 0.0
  iinput.cvc          = uint8(0)
  iinput.vrc          = uint8(0)
  iinput.vsb          = uint8(0)
  iinput.equipage     = int32(0)
  iinput.quant        = uint8(0)
  iinput.sensitivity_index = uint8(0)
  iinput.protection_mode   = uint8(0)
end

type InputVals
  ownInput::OwnInputVals
  intruders::Vector{IntruderInputVals}

  function InputVals(nintruders::Int)
    obj = new()
    obj.ownInput       = OwnInputVals()
    obj.intruders      = IntruderInputVals[IntruderInputVals() for i = 1:nintruders]

    return obj
  end

  InputVals(ownInput::OwnInputVals, intruders::Vector{IntruderInputVals}) = new(ownInput, intruders)
end

function reset!(input::InputVals)
  reset!(input.ownInput)

  for i = 1:endof(input.intruders)
    reset!(input.intruders[i])
  end
end

type OwnInput
  handle::Ptr{Void}
end

type IntruderInput
  handle::Ptr{Void}
end

type CollectionIntruderInput
  handle::Ptr{Void}
  intruders::Vector{IntruderInput}

  function CollectionIntruderInput(handle::Ptr{Void})
    obj = new()
    obj.handle = handle
    obj.intruders = IntruderInput[]

    return obj
  end
end

type Input
  handle::Ptr{Void}
  ownInput::OwnInput
  intruder_collection::CollectionIntruderInput

  function Input(nintruders::Int)
    obj = new()
    obj.handle = ccall((:newCInput, LIBCCAS), Ptr{Void}, ())

    obj.ownInput = OwnInput(obj)
    obj.intruder_collection = CollectionIntruderInput(obj,nintruders)

    finalizer(obj, obj -> ccall((:delCInput, LIBCCAS), Void, (Ptr{Void},), obj.handle))

    return obj
  end
end

function OwnInput(input::Input,ownInputVals::Union{OwnInputVals,Void}=nothing)

  handle  = ccall((:getRefCOwnInput,LIBCCAS), Ptr{Void},(Ptr{Void},), input.handle)
  obj = OwnInput(handle)

  if ownInputVals != nothing
    set!(obj,ownInputVals)
  end

  return obj
end

function IntruderInput(collection::CollectionIntruderInput,index_::Integer,
                       inputVals::Union{IntruderInputVals,Void}=nothing)
  index = checked_convert(UInt32, index_-1) #C uses 0 indexing

  handle = ccall((:getRefCIntruderInput,LIBCCAS), Ptr{Void},
                 (Ptr{Void},UInt32), collection.handle, index)
  obj = IntruderInput(handle)

  if inputVals != nothing
    set!(obj,inputVals)
  end

  return obj
end

function CollectionIntruderInput(input::Input,nintruders::Int)
  handle         = ccall((:getRefCCollectionIntruderInput,LIBCCAS), Ptr{Void},
                             (Ptr{Void},),input.handle)
  obj = CollectionIntruderInput(handle)

  resize!(obj,nintruders)
  resize!(obj.intruders,nintruders)

  for i = 1:nintruders
    obj.intruders[i]      = IntruderInput(obj,i)
  end

  return obj
end

function set!(input::OwnInput,inputVals::OwnInputVals)
  ccall((:setCOwnInput,LIBCCAS), Void,
        (Ptr{Void},Float64,Float64,Float64,Float64,UInt32), input.handle, inputVals.dz, inputVals.z,
        inputVals.psi, inputVals.h, inputVals.modes)
end

function set!(input::IntruderInput,inputVals::IntruderInputVals)
  ccall((:setCIntruderInput,LIBCCAS), Void,
        (Ptr{Void},Bool,UInt32, UInt32, Float64, Float64, Float64,
         UInt8, UInt8, UInt8, Int32, UInt8,
         UInt8, UInt8), input.handle,inputVals.valid, inputVals.id,
        inputVals.modes, inputVals.sr,
        inputVals.chi, inputVals.z,
        inputVals.cvc, inputVals.vrc, inputVals.vsb, inputVals.equipage, inputVals.quant,
        inputVals.sensitivity_index, inputVals.protection_mode)
end

function set!(input::Input,inputVals::InputVals)
  set!(input.ownInput,inputVals.ownInput)
  for (input_intruder,inputVals_intruder) in zip(input.intruder_collection.intruders,
                                                 inputVals.intruders)
    set!(input_intruder,inputVals_intruder)
  end
end

function resize!(collection::CollectionIntruderInput,size_::Integer)
  size = checked_convert(UInt32,size_)
  ccall((:resizeCCollectionIntrInput,LIBCCAS), Void, (Ptr{Void},UInt32), collection.handle, size)
end

function size(collection::CollectionIntruderInput)
  csize = ccall((:sizeCCollectionIntrInput,LIBCCAS), UInt32, (Ptr{Void},),
                 collection.handle)
  csize = convert(Int64,csize)
  @assert csize == length(collection.intruders) #make sure we're in sync

  return csize
end

type IntruderOutputVals
  id::UInt32
  cvc::UInt8
  vrc::UInt8
  vsb::UInt8
  tds::Float64
  code::UInt8

  IntruderOutputVals() = IntruderOutputVals(uint32(0), uint8(0), uint8(0), uint8(0), 0., uint8(0))

  function IntruderOutputVals(id::UInt32, cvc::UInt8, vrc::UInt8, vsb::UInt8, tds::Float64, code::UInt8)
    obj         = new()
    obj.id      = id
    obj.cvc     = cvc
    obj.vrc     = vrc
    obj.vsb     = vsb
    obj.tds     = tds
    obj.code    = code

    return obj
  end
end

function reset!(iout::IntruderOutputVals)
  iout.id = uint32(0)
  iout.cvc = uint8(0)
  iout.vrc = uint8(0)
  iout.vsb = uint8(0)
  iout.tds = 0.0
  iout.code = uint8(0)

  return
end

type OutputVals
  cc::UInt8
  vc::UInt8
  ua::UInt8
  da::UInt8
  target_rate::Float64
  turn_off_aurals::Bool
  crossing::Bool
  alarm::Bool
  alert::Bool
  dh_min::Float64
  dh_max::Float64
  sensitivity_index::UInt8
  ddh::Float64
  intruders::Vector{IntruderOutputVals}
end

function OutputVals(nintruders::Int)
  intruders = IntruderOutputVals[IntruderOutputVals() for i = 1:nintruders]

  return OutputVals(uint8(0), uint8(0), uint8(0), uint8(0), 0.0, false, false, false, false,
                    -9999.0, 9999.0, uint8(0), 0.0, intruders)
end

function reset!(out::OutputVals)
  out.cc = uint8(0)
  out.vc = uint8(0)
  out.ua = uint8(0)
  out.da = uint8(0)
  out.target_rate = 0.0
  out.turn_off_aurals = false
  out.crossing = false
  out.alarm = false
  out.alert = false
  out.dh_min = -9999.0
  out.dh_max = 9999.0
  out.sensitivity_index = uint8(0)
  out.ddh = 0.0

  for i = 1:endof(out.intruders)
    reset!(out.intruders[i])
  end

  return
end

type IntruderOutput
  handle::Ptr{Void}
end

type CollectionIntruderOutput
  handle::Ptr{Void}
  intruders::Vector{IntruderOutput}

  function CollectionIntruderOutput(handle::Ptr{Void})
    obj = new()
    obj.handle = handle
    obj.intruders = IntruderOutput[]

    return obj
  end
end

type Output
  handle::Ptr{Void}
  intruder_collection::CollectionIntruderOutput

  function Output(nintruders::Int)
    obj = new()
    obj.handle = ccall((:newCOutput,LIBCCAS), Ptr{Void}, ())
    obj.intruder_collection = CollectionIntruderOutput(obj,nintruders)

    finalizer(obj,obj->ccall((:delCOutput,LIBCCAS), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function IntruderOutput(collection::CollectionIntruderOutput,index_::Integer,
                        outputVals::Union{IntruderOutputVals,Void}=nothing)
  index = checked_convert(UInt32, index_ - 1) #C uses 0 indexing

  handle = ccall((:getRefCIntruderOutput,LIBCCAS), Ptr{Void},
                     (Ptr{Void},UInt32), collection.handle, index)
  obj = IntruderOutput(handle)

  if outputVals != nothing
    set!(obj,outputVals)
  end

  return obj
end

function CollectionIntruderOutput(output::Output, nintruders::Int)
  handle         = ccall((:getRefCCollectionIntruderOutput, LIBCCAS), Ptr{Void},
                             (Ptr{Void},), output.handle)

  obj = CollectionIntruderOutput(handle)

  resize!(obj, nintruders)
  resize!(obj.intruders, nintruders)

  for i = 1:nintruders
    obj.intruders[i]      = IntruderOutput(obj, i)
  end

  return obj
end

function set_id!(intruderOutput::IntruderOutput, id_::Integer)
  id = checked_convert(UInt32, id_)
  ccall((:setCIntrOutput_id, LIBCCAS), Void, (Ptr{Void}, UInt32), intruderOutput.handle, id)
end

function get!(output::IntruderOutput, outputVals::IntruderOutputVals)
  outputVals.id = ccall((:getCIntrOutput_id,LIBCCAS), UInt32, (Ptr{Void},), output.handle)
  outputVals.cvc = ccall((:getCIntrOutput_cvc,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.vrc = ccall((:getCIntrOutput_vrc,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.vsb = ccall((:getCIntrOutput_vsb,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.tds = ccall((:getCIntrOutput_tds,LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.code = ccall((:getCIntrOutput_code,LIBCCAS), UInt8, (Ptr{Void},), output.handle)

  return outputVals
end

function get!(output::Output, outputVals::OutputVals)
  outputVals.cc       = ccall((:getCOutput_cc,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.vc       = ccall((:getCOutput_vc,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.ua       = ccall((:getCOutput_ua,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.da       = ccall((:getCOutput_da,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.target_rate       = ccall((:getCOutput_target_rate,LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.turn_off_aurals   = ccall((:getCOutput_turn_off_aurals,LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.crossing          = ccall((:getCOutput_crossing,LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.alarm    = ccall((:getCOutput_alarm,LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.alert    = ccall((:getCOutput_alert,LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.dh_min   = ccall((:getCOutput_dh_min,LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.dh_max   = ccall((:getCOutput_dh_max,LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.sensitivity_index = ccall((:getCOutput_sensitivity_index,LIBCCAS), UInt8, (Ptr{Void},), output.handle)
  outputVals.ddh      = ccall((:getCOutput_ddh,LIBCCAS), Float64, (Ptr{Void},), output.handle)

  for (out, outVals) in zip(output.intruder_collection.intruders, outputVals.intruders)
    get!(out, outVals)
  end

  return outputVals
end

function resize!(collection::CollectionIntruderOutput, size_::Integer)
  size = checked_convert(UInt32,size_)
  ccall((:resizeCCollectionIntrOutput,LIBCCAS), Void, (Ptr{Void}, UInt32), collection.handle, size)
end

function size(collection::CollectionIntruderOutput)
  csize = ccall((:sizeCCollectionIntrOutput,LIBCCAS), UInt32, (Ptr{Void},),
                 collection.handle)
  csize = convert(Int64,csize)
  @assert csize == length(collection.intruders) #make sure we're in sync

  return csize
end

type Constants
  handle::Ptr{Void} #Pointer to C object

  function Constants(quant_::Integer, config_filename::AbstractString, max_intruders_::Integer)
    quant = checked_convert(UInt8, quant_)
    max_intruders = checked_convert(UInt8, max_intruders_)
    handle = ccall((:newCConstants, LIBCCAS), Ptr{Void}, (UInt8, Ptr{UInt8}, UInt32),
                   quant, config_filename, max_intruders)
    obj = new(handle)
    finalizer(obj,obj->ccall((:delCConstants, LIBCCAS),Void, (Ptr{Void},), obj.handle))

    return obj
  end
end

type CASShared
  handle::Ptr{Void} #Pointer to C object
  libcas::ASCIIString #path to library
  max_intruders::Int64
  input::Input
  output::Output

  function CASShared(libcas::AbstractString, consts::Constants)

    handle = ccall((:newCCASShared,LIBCCAS), Ptr{Void}, (Ptr{Void}, Ptr{UInt8}),
                   consts.handle, libcas)

    obj = new(handle)
    obj.libcas = libcas
    obj.max_intruders = max_intruders(obj)
    obj.input = Input(obj.max_intruders)
    obj.output = Output(obj.max_intruders)

    finalizer(obj,obj->ccall((:delCCASShared,LIBCCAS),Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

reset(cas::CASShared) = ccall((:reset, LIBCCAS), Void, (Ptr{Void},), cas.handle)

version(cas::CASShared) = bytestring(ccall((:version,LIBCCAS), Ptr{UInt8}, (Ptr{Void},), cas.handle))

function error_msg(cas::CASShared)
  err = ccall((:error, LIBCCAS), Ptr{UInt8},(Ptr{Void},), cas.handle)

  return err == C_NULL ? nothing : bytestring(err)
end

max_intruders(cas::CASShared) = ccall((:max_intruders, LIBCCAS), Int64, (Ptr{Void},), cas.handle)

function update(cas::CASShared, input::Input, output::Output)
  ccall((:update, LIBCCAS), Void,(Ptr{Void}, Ptr{Void}, Ptr{Void}), cas.handle, input.handle, output.handle)
end

function update!(cas::CASShared, inputVals::InputVals, outputVals::OutputVals)

  #id in output isn't populated by libcas for some reason, so we'll do it on our side
  for i = 1:cas.max_intruders
    set_id!(cas.output.intruder_collection.intruders[i], inputVals.intruders[i].id)
  end

  set!(cas.input, inputVals)
  update(cas, cas.input,cas.output)
  get!(cas.output, outputVals)

  return outputVals #for convenience, since we are directly modifying outputVals input arg
end

function checked_convert{T <: Unsigned}(::Type{T},n::Integer)
  return (typemin(T) <= n <= typemax(T)) ?
    convert(T,n) : error("Cannot convert numeric type: Out of range")
end

author() = bytestring(ccall((:author, LIBCCAS), Ptr{UInt8},()))

end

