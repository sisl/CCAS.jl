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

export Constants, CASShared, reset, reset!, version, error_msg,
            max_intruders, update!, author

using CASInterface
import Base: reset, resize!, size, getindex

#= use value types in 0.4
get_equipage(::Type{Val{EQUIPAGE_ATCRBS}}) = ccall((:enum_EQUIPAGE_ATCRBS, LIBCCAS),Int32,())
get_equipage(::Type{Val{EQUIPAGE_MODES}}) = ccall((:enum_EQUIPAGE_MODES, LIBCCAS),Int32,())
get_equipage(::Type{Val{EQUIPAGE_TCASTA}}) = ccall((:enum_EQUIPAGE_TCASTA, LIBCCAS),Int32,())
get_equipage(::Type{Val{EQUIPAGE_TCAS}}) = ccall((:enum_EQUIPAGE_TCAS, LIBCCAS),Int32,())
=#

function get_equipage(equip::EQUIPAGE)
  if equip == EQUIPAGE_ATCRBS
    return ccall((:enum_EQUIPAGE_ATCRBS, LIBCCAS),Int32,())
  elseif equip == EQUIPAGE_MODES
    return ccall((:enum_EQUIPAGE_MODES, LIBCCAS),Int32,())
  elseif equip == EQUIPAGE_TCASTA
    return ccall((:enum_EQUIPAGE_TCASTA, LIBCCAS),Int32,())
  elseif equip == EQUIPAGE_TCAS
    return ccall((:enum_EQUIPAGE_TCAS, LIBCCAS),Int32,())
  else
    error("No such equipage: $equip")
  end
end

type OwnInputRef
  handle::Ptr{Void}
end

type IntruderInputRef
  handle::Ptr{Void}
end

type CollectionIntruderInputRef
  handle::Ptr{Void}
  intruders::Vector{IntruderInputRef}
end
CollectionIntruderInputRef(handle::Ptr{Void}) = CollectionIntruderInputRef(handle, IntruderInputRef[])

type InputRef
  handle::Ptr{Void}
  ownInput::OwnInputRef
  intruder_collection::CollectionIntruderInputRef

  function InputRef(nintruders::Int)
    obj = new()
    obj.handle = ccall((:newCInput, LIBCCAS), Ptr{Void}, ())
    obj.ownInput = OwnInputRef(obj)
    obj.intruder_collection = CollectionIntruderInputRef(obj, nintruders)

    finalizer(obj, obj -> ccall((:delCInput, LIBCCAS), Void, (Ptr{Void},), obj.handle))
    return obj
  end
end

function OwnInputRef(input::InputRef, ownInputVals::Union(OwnInput,Nothing)=nothing)
  handle = ccall((:getRefCOwnInput, LIBCCAS), Ptr{Void}, (Ptr{Void},), input.handle)
  obj = OwnInputRef(handle)

  if ownInputVals != nothing
    set!(obj, ownInputVals)
  end
  return obj
end

function IntruderInputRef(collection::CollectionIntruderInputRef, index_::Integer,
                       intrVals::Union(IntruderInput,Nothing)=nothing)
  index = checked_convert(Uint32, index_-1) #C uses 0 indexing
  handle = ccall((:getRefCIntruderInput, LIBCCAS), Ptr{Void},
                 (Ptr{Void}, Uint32), collection.handle, index)
  obj = IntruderInputRef(handle)

  if intrVals != nothing
    set!(obj, intrVals)
  end
  return obj
end

function CollectionIntruderInputRef(input::InputRef, nintruders::Int)
  handle = ccall((:getRefCCollectionIntruderInput, LIBCCAS), Ptr{Void}, (Ptr{Void},), input.handle)
  obj = CollectionIntruderInputRef(handle)
  resize!(obj,nintruders)
  resize!(obj.intruders, nintruders)

  for i = 1:nintruders
    obj.intruders[i] = IntruderInputRef(obj, i)
  end
  return obj
end

function set!(input::OwnInputRef, inputVals::OwnInput)
  ccall((:setCOwnInput, LIBCCAS), Void,
        (Ptr{Void}, Float64, Float64, Float64, Float64, Uint32), input.handle, inputVals.dz, inputVals.z,
        inputVals.psi, inputVals.h, inputVals.modes)
end

function set!(input::IntruderInputRef, iinputVals::IntruderInput)
  equipage = get_equipage(iinputVals.equipage)
  ccall((:setCIntruderInput, LIBCCAS), Void,
        (Ptr{Void}, Bool, Uint32, Uint32, Float64, Float64, Float64,
         Uint8, Uint8, Uint8, Int32, Uint8,
         Uint8, Uint8), input.handle, iinputVals.valid, iinputVals.id,
        iinputVals.modes, iinputVals.sr,
        iinputVals.chi, iinputVals.z,
        iinputVals.cvc, iinputVals.vrc, iinputVals.vsb, equipage, iinputVals.quant,
        iinputVals.sensitivity_index, iinputVals.protection_mode)
end

function set!(input::InputRef, inputVals::Input)
  set!(input.ownInput, inputVals.ownInput)
  for (input_intruder, inputVals_intruder) in zip(input.intruder_collection.intruders,
                                                 inputVals.intruders)
    set!(input_intruder, inputVals_intruder)
  end
end

function resize!(collection::CollectionIntruderInputRef, size_::Integer)
  size = checked_convert(Uint32, size_)
  ccall((:resizeCCollectionIntrInput, LIBCCAS), Void, (Ptr{Void},Uint32), collection.handle, size)
end

function size(collection::CollectionIntruderInputRef)
  csize = ccall((:sizeCCollectionIntrInput, LIBCCAS), Uint32, (Ptr{Void},), collection.handle)
  csize = convert(Int64, csize)
  @assert csize == length(collection.intruders) #make sure we're in sync
  return csize
end

type IntruderOutputRef
  handle::Ptr{Void}
end

type CollectionIntruderOutputRef
  handle::Ptr{Void}
  intruders::Vector{IntruderOutputRef}
end
CollectionIntruderOutputRef(handle::Ptr{Void}) = CollectionIntruderOutputRef(handle, IntruderOutputRef[])

type OutputRef
  handle::Ptr{Void}
  intruder_collection::CollectionIntruderOutputRef

  function OutputRef(nintruders::Int)
    obj = new()
    obj.handle = ccall((:newCOutput, LIBCCAS), Ptr{Void}, ())
    obj.intruder_collection = CollectionIntruderOutputRef(obj, nintruders)

    finalizer(obj,obj->ccall((:delCOutput, LIBCCAS), Void, (Ptr{Void},), obj.handle))
    return obj
  end
end

function IntruderOutputRef(collection::CollectionIntruderOutputRef, index_::Integer,
                        outputVals::Union(IntruderOutput,Nothing)=nothing)
  index = checked_convert(Uint32, index_ - 1) #C uses 0 indexing
  handle = ccall((:getRefCIntruderOutput, LIBCCAS), Ptr{Void},
                     (Ptr{Void}, Uint32), collection.handle, index)
  obj = IntruderOutputRef(handle)

  if outputVals != nothing
    set!(obj,outputVals)
  end
  return obj
end

function CollectionIntruderOutputRef(output::OutputRef, nintruders::Int)
  handle = ccall((:getRefCCollectionIntruderOutput, LIBCCAS), Ptr{Void},
                             (Ptr{Void},), output.handle)
  obj = CollectionIntruderOutputRef(handle)

  resize!(obj, nintruders)
  resize!(obj.intruders, nintruders)

  for i = 1:nintruders
    obj.intruders[i] = IntruderOutputRef(obj, i)
  end
  return obj
end

function set_id!(intruderOutput::IntruderOutputRef, id_::Integer)
  id = checked_convert(Uint32, id_)
  ccall((:setCIntrOutput_id, LIBCCAS), Void, (Ptr{Void}, Uint32), intruderOutput.handle, id)
end

function get!(output::IntruderOutputRef, outputVals::IntruderOutput)
  outputVals.id = ccall((:getCIntrOutput_id, LIBCCAS), Uint32, (Ptr{Void},), output.handle)
  outputVals.cvc = ccall((:getCIntrOutput_cvc, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.vrc = ccall((:getCIntrOutput_vrc, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.vsb = ccall((:getCIntrOutput_vsb, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.tds = ccall((:getCIntrOutput_tds, LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.code = ccall((:getCIntrOutput_code, LIBCCAS), Uint8, (Ptr{Void},), output.handle)

  return outputVals
end

function get!(output::OutputRef, outputVals::Output)
  outputVals.cc       = ccall((:getCOutput_cc, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.vc       = ccall((:getCOutput_vc, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.ua       = ccall((:getCOutput_ua, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.da       = ccall((:getCOutput_da, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.target_rate       = ccall((:getCOutput_target_rate, LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.turn_off_aurals   = ccall((:getCOutput_turn_off_aurals, LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.crossing          = ccall((:getCOutput_crossing, LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.alarm    = ccall((:getCOutput_alarm, LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.alert    = ccall((:getCOutput_alert, LIBCCAS), Bool, (Ptr{Void},), output.handle)
  outputVals.dh_min   = ccall((:getCOutput_dh_min, LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.dh_max   = ccall((:getCOutput_dh_max, LIBCCAS), Float64, (Ptr{Void},), output.handle)
  outputVals.sensitivity_index = ccall((:getCOutput_sensitivity_index, LIBCCAS), Uint8, (Ptr{Void},), output.handle)
  outputVals.ddh      = ccall((:getCOutput_ddh, LIBCCAS), Float64, (Ptr{Void},), output.handle)

  for (out, outVals) in zip(output.intruder_collection.intruders, outputVals.intruders)
    get!(out, outVals)
  end

  return outputVals
end

function resize!(collection::CollectionIntruderOutputRef, size_::Integer)
  size = checked_convert(Uint32, size_)
  ccall((:resizeCCollectionIntrOutput, LIBCCAS), Void, (Ptr{Void}, Uint32), collection.handle, size)
end

function size(collection::CollectionIntruderOutputRef)
  csize = ccall((:sizeCCollectionIntrOutput, LIBCCAS), Uint32, (Ptr{Void},),
                 collection.handle)
  csize = convert(Int64,csize)
  @assert csize == length(collection.intruders) #make sure we're in sync

  return csize
end

type Constants
  handle::Ptr{Void} #Pointer to C object

  function Constants(quant_::Integer, config_filename::String, max_intruders_::Integer)
    quant = checked_convert(Uint8, quant_)
    max_intruders = checked_convert(Uint8, max_intruders_)
    handle = ccall((:newCConstants, LIBCCAS), Ptr{Void}, (Uint8, Ptr{Uint8}, Uint32),
                   quant, config_filename, max_intruders)
    obj = new(handle)

    finalizer(obj, obj->ccall((:delCConstants, LIBCCAS),Void, (Ptr{Void},), obj.handle))
    return obj
  end
end

type CASShared
  handle::Ptr{Void} #Pointer to C object
  libcas::String #path to library
  max_intruders::Int64
  input::InputRef
  output::OutputRef

  function CASShared(libcas::String, consts::Constants)

    handle = ccall((:newCCASShared, LIBCCAS), Ptr{Void}, (Ptr{Void}, Ptr{Uint8}),
                   consts.handle, libcas)

    obj = new(handle)
    obj.libcas = libcas
    obj.max_intruders = max_intruders(obj)
    obj.input = InputRef(obj.max_intruders)
    obj.output = OutputRef(obj.max_intruders)

    finalizer(obj,obj->ccall((:delCCASShared, LIBCCAS),Void, (Ptr{Void},),obj.handle))
    return obj
  end
end

reset(cas::CASShared) = ccall((:reset, LIBCCAS), Void, (Ptr{Void},), cas.handle)

version(cas::CASShared) = bytestring(ccall((:version, LIBCCAS), Ptr{Uint8}, (Ptr{Void},), cas.handle))

function error_msg(cas::CASShared)
  err = ccall((:error, LIBCCAS), Ptr{Uint8},(Ptr{Void},), cas.handle)

  return err == C_NULL ? nothing : bytestring(err)
end

max_intruders(cas::CASShared) = ccall((:max_intruders, LIBCCAS), Int64, (Ptr{Void},), cas.handle)

function update(cas::CASShared, input::InputRef, output::OutputRef)
  ccall((:update, LIBCCAS), Void,(Ptr{Void}, Ptr{Void}, Ptr{Void}), cas.handle, input.handle, output.handle)
end

function update!(cas::CASShared, inputVals::Input, outputVals::Output)

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

author() = bytestring(ccall((:author, LIBCCAS), Ptr{Uint8},()))

end

