module CCAS

export   Equipage, EQUIPAGE, Constants, CASShared, reset, version, error_msg, max_intruders, OwnInputVals,
         OwnInput, set!, IntruderInputVals, IntruderInput, CollectionIntruderInput,
         size, InputVals, Input, IntruderOutputVals, IntruderOutput, CollectionIntruderOutput,
         OutputVals, Output, update, author

using Base.Test
import Base.resize!
import Base.size
import Base.getindex
import Base.reset

const libccas = "D:/bin/Debug/libccas"

immutable Equipage
  EQUIPAGE_ATCRBS::Int32
  EQUIPAGE_MODES::Int32
  EQUIPAGE_TCASTA::Int32
  EQUIPAGE_TCAS::Int32

  function Equipage()
    atcrbs = ccall((:enum_EQUIPAGE_ATCRBS,libccas),Int32,())
    modes = ccall((:enum_EQUIPAGE_MODES,libccas),Int32,())
    tcasta = ccall((:enum_EQUIPAGE_TCASTA,libccas),Int32,())
    tcas = ccall((:enum_EQUIPAGE_TCAS,libccas),Int32,())

    return new(atcrbs, modes, tcasta, tcas)
  end
end

EQUIPAGE = Equipage()

type Constants
  handle::Ptr{Void} #Pointer to C object

  function Constants(quant_::Integer,config_filename::String,max_intruders_::Integer)
    quant = checked_convert(Uint8,quant_)
    max_intruders = checked_convert(Uint8,max_intruders_)
    handle = ccall((:newCConstants,libccas), Ptr{Void}, (Uint8,Ptr{Uint8},Uint32), quant, config_filename, max_intruders)
    obj = new(handle)
    finalizer(obj,obj->ccall((:delCConstants,libccas),Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

type CASShared
  handle::Ptr{Void} #Pointer to C object

  function CASShared(consts::Constants,library_path::String)
    handle = ccall((:newCCASShared,libccas), Ptr{Void}, (Ptr{Void},Ptr{Uint8}), consts.handle, library_path)
    obj = new(handle)
    finalizer(obj,obj->ccall((:delCCASShared,libccas),Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

reset(cas::CASShared) = ccall((:reset,libccas),Void,(Ptr{Void},),cas.handle)

version(cas::CASShared) = bytestring(ccall((:version,libccas),Ptr{Uint8},(Ptr{Void},),cas.handle))

function error_msg(cas::CASShared)
  err = ccall((:error,libccas),Ptr{Uint8},(Ptr{Void},),cas.handle)

  return err == C_NULL ? nothing : bytestring(err)
end

max_intruders(cas::CASShared) = ccall((:max_intruders,libccas),Int64,(Ptr{Void},),cas.handle)

type OwnInputVals
  dz::Float64
  z::Float64
  psi::Float64
  h::Float64
  modes::Uint32

  OwnInputVals() = new(0.,0.,0.,0.,uint32(0))

  OwnInputVals(dz::Float64,z::Float64,psi::Float64,h::Float64,modes::Integer) =
    new(dz,z,psi,h,checked_convert(Uint32,modes))
end

type OwnInput
  handle::Ptr{Void}

  OwnInput() = OwnInput(0.,0.,0.,0.,uint32(0))

  function OwnInput(dz::Float64,z::Float64,psi::Float64,h::Float64,modes::Uint32)
    obj         = new()
    obj.handle  = ccall((:newCOwnInput,libccas), Ptr{Void},
                   (Float64,Float64,Float64,Float64,Uint32), dz, z, psi, h, modes)
    finalizer(obj,obj->ccall((:delCOwnInput,libccas), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function set!(inputVals::OwnInputVals,input::OwnInput)
  ccall((:setCOwnInput,libccas), Void,
        (Ptr{Void},Float64,Float64,Float64,Float64,Uint32), input.handle, inputVals.dz, inputVals.z,
        inputVals.psi, inputVals.h, inputVals.modes)
end

type IntruderInputVals
  valid::Bool
  id::Uint32
  modes::Uint32
  sr::Float64
  chi::Float64
  z::Float64
  cvc::Uint8
  vrc::Uint8
  vsb::Uint8
  equipage::Int32
  quant::Uint8
  sensitivity_index::Uint8
  protection_mode::Uint8

  IntruderInputVals() = new(false,uint32(0),uint32(0),0.,0.,0.,uint8(0),uint8(0),uint8(0),int32(0),
                            uint8(0),uint8(0),uint8(0))

  function IntruderInputVals(valid::Bool,id::Uint32,modes::Uint32,sr::Float64,chi::Float64,z::Float64,
                             cvc::Uint8,vrc::Uint8,vsb::Uint8,equipage::Int32,quant::Uint8,
                             sensitivity_index::Uint8,protection_mode::Uint8)
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

type IntruderInput
  handle::Ptr{Void}

  IntruderInput() = IntruderInput(false,uint32(0),uint32(0),0.,0.,0.,uint8(0),uint8(0),uint8(0),int32(0),
                            uint8(0),uint8(0),uint8(0))

  function IntruderInput(valid::Bool,id::Uint32,modes::Uint32,sr::Float64,chi::Float64,z::Float64,
                         cvc::Uint8,vrc::Uint8,vsb::Uint8,equipage::Int32,quant::Uint8,
                         sensitivity_index::Uint8,protection_mode::Uint8)
    obj = new()
    obj.handle = ccall((:newCIntruderInput,libccas), Ptr{Void},
                   (Bool,Uint32, Uint32, Float64, Float64, Float64,
                    Uint8, Uint8, Uint8, Int32, Uint8,
                    Uint8, Uint8), valid, id, modes, sr, chi, z, cvc, vrc, vsb, equipage, quant,
                   sensitivity_index, protection_mode)
    finalizer(obj,obj->ccall((:delCIntruderInput,libccas), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function set!(input::IntruderInput,inputVals::IntruderInputVals)
  ccall((:setCIntruderInput,libccas), Void,
        (Ptr{Void},Bool,Uint32, Uint32, Float64, Float64, Float64,
         Uint8, Uint8, Uint8, Int32, Uint8,
         Uint8, Uint8), input.handle,inputVals.valid, inputVals.id,
        inputVals.modes, inputVals.sr,
        inputVals.chi, inputVals.z,
        inputVals.cvc, inputVals.vrc, inputVals.vsb, inputVals.equipage, inputVals.quant,
        inputVals.sensitivity_index, inputVals.protection_mode)
end

type CollectionIntruderInput
  handle::Ptr{Void}
  intruders::Vector{IntruderInput}

  function CollectionIntruderInput(nintruders::Int)
    obj                = new()
    obj.handle         = ccall((:newCCollectionIntruderInput,libccas), Ptr{Void}, ())
    obj.intruders      = IntruderInput[IntruderInput() for i = 1:nintruders]

    resize!(obj,nintruders)

    for i = 1:nintruders
      setIndex!(obj,i,obj.intruders[i])
    end

    finalizer(obj,obj->ccall((:delCCollectionIntruderInput,libccas), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function resize!(collection::CollectionIntruderInput,size_::Integer)
  size = checked_convert(Uint32,size_)
  ccall((:resizeCCollectionIntrInput,libccas), Void, (Ptr{Void},Uint32), collection.handle, size)
end

function getIndex(collection::CollectionIntruderInput,index_::Integer)
  index = checked_convert(Uint32, index_-1) #C uses 0 indexing
  handle = ccall((:getIndexCCollectionIntrInput,libccas), Ptr{Void}, (Ptr{Void},Uint32),
                 collection.handle, index)

  return handle
end

function setIndex!(collection::CollectionIntruderInput,index_::Integer,input::IntruderInput)
  index = checked_convert(Uint32,index_-1) #C uses 0 indexing
  ccall((:setIndexCCollectionIntrInput,libccas), Void, (Ptr{Void},Uint32,Ptr{Void}),
                 collection.handle, index, input.handle)
end

function size(collection::CollectionIntruderInput)
  csize = ccall((:sizeCCollectionIntrInput,libccas), Uint32, (Ptr{Void},),
                 collection.handle)
  csize = convert(Int64,csize)
  @test csize == length(collection.intruders) #make sure we're in sync

  return csize
end

type InputVals
  ownInput::OwnInputVals
  intruders::Vector{IntruderInputVals}

  function InputVals(nintruders::Int)
    obj = new()
    obj.ownInput       = OwnInputVals()
    obj.intruders      = IntruderInputVals[IntruderInputVals() for i=1:nintruders]

    return obj
  end

  InputVals(ownInput::OwnInputVals,intruders::Vector{IntruderInputVals}) = new(ownInput,intruders)
end

type Input
  handle::Ptr{Void}
  ownInput::OwnInput
  intruders_collection::CollectionIntruderInput

  Input(nintruders::Int) = Input(OwnInput(),CollectionIntruderInput(nintruders))

  function Input(ownInput::OwnInput,intruders_collection::CollectionIntruderInput)
    obj = new()
    obj.handle = ccall((:newCInput,libccas), Ptr{Void}, (Ptr{Void},Ptr{Void}), ownInput.handle,
                   intruders_collection.handle)
    obj.ownInput = ownInput
    obj.intruders_collection = intruders_collection
    finalizer(obj,obj->ccall((:delCInput,libccas), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function set!(input::Input,inputVals::InputVals)
  set!(inputVals.ownInput,input.ownInput)
  for (inputVals_intruder,input_intruder) in zip(inputVals.intruders,input.intruders_collection.intruders)
    set!(input_intruder,inputVals_intruder)
  end
end

type IntruderOutputVals
  id::Uint32
  cvc::Uint8
  vrc::Uint8
  vsb::Uint8
  tds::Float64
  code::Uint8

  IntruderOutputVals() = IntruderOutputVals(uint32(0),uint8(0),uint8(0),uint8(0),0.,uint8(0))

  function IntruderOutputVals(id::Uint32,cvc::Uint8,vrc::Uint8,vsb::Uint8,tds::Float64,code::Uint8)
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

type IntruderOutput
  handle::Ptr{Void}

  IntruderOutput() = IntruderOutput(uint32(0),uint8(0),uint8(0),uint8(0),0.,uint8(0))

  function IntruderOutput(id::Uint32,cvc::Uint8,vrc::Uint8,vsb::Uint8,tds::Float64,code::Uint8)
    obj           = new()
    obj.handle    = ccall((:newCIntruderOutput,libccas), Ptr{Void},
                          (Uint32, Uint8, Uint8, Uint8, Float64, Uint8), id, cvc, vrc, vsb,
                          tds, code)
    finalizer(obj,obj->ccall((:delCIntruderOutput,libccas), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function get!(output::IntruderOutput,outputVals::IntruderOutputVals)
  outputVals.id = ccall((:getCIntrOutput_id,libccas), Uint32, (Ptr{Void},), output.handle)
  outputVals.cvc = ccall((:getCIntrOutput_cvc,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.vrc = ccall((:getCIntrOutput_vrc,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.vsb = ccall((:getCIntrOutput_vsb,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.tds = ccall((:getCIntrOutput_tds,libccas), Float64, (Ptr{Void},), output.handle)
  outputVals.code = ccall((:getCIntrOutput_code,libccas), Uint8, (Ptr{Void},), output.handle)

  return outputVals
end

type CollectionIntruderOutput
  handle::Ptr{Void}
  intruders::Vector{IntruderOutput}

  function CollectionIntruderOutput(nintruders::Int)
    obj             = new()
    obj.handle      = ccall((:newCCollectionIntruderOutput,libccas), Ptr{Void}, ())
    obj.intruders   = IntruderOutput[IntruderOutput() for i = 1:nintruders]

    resize!(obj,nintruders)

    for i = 1:nintruders
      setIndex!(obj,i,obj.intruders[i])
    end

    finalizer(obj,obj->ccall((:delCCollectionIntruderOutput,libccas), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function resize!(collection::CollectionIntruderOutput,size_::Integer)
  size = checked_convert(Uint32,size_)
  ccall((:resizeCCollectionIntrOutput,libccas), Void, (Ptr{Void},Uint32), collection.handle, size)
end

function getIndex(collection::CollectionIntruderOutput,index_::Integer)
  index = checked_convert(Uint32, index_-1) #C uses 0 indexing
  return ccall((:getIndexCCollectionIntrOutput,libccas), Ptr{Void}, (Ptr{Void},Uint32),
                 collection.handle, index)
end

function setIndex!(collection::CollectionIntruderOutput,index_::Integer,input::IntruderOutput)
  index = checked_convert(Uint32,index_-1) #C uses 0 indexing
  ccall((:setIndexCCollectionIntrOutput,libccas), Void, (Ptr{Void},Uint32,Ptr{Void}),
                 collection.handle, index, input.handle)
end

function size(collection::CollectionIntruderOutput)
  csize = ccall((:sizeCCollectionIntrOutput,libccas), Uint32, (Ptr{Void},),
                 collection.handle)
  csize = convert(Int64,csize)
  @test csize == length(collection.intruders) #make sure we're in sync

  return csize
end

type OutputVals
  cc::Uint8
  vc::Uint8
  ua::Uint8
  da::Uint8
  target_rate::Float64
  turn_off_aurals::Bool
  crossing::Bool
  alarm::Bool
  alert::Bool
  dh_min::Float64
  dh_max::Float64
  sensitivity_index::Uint8
  ddh::Float64
  intruders::Vector{IntruderOutputVals}

  function OutputVals(nintruders::Int)
    intruders = IntruderOutputVals[IntruderOutputVals() for i=1:nintruders]

    return new(uint8(0),uint8(0),uint8(0),uint8(0),0.,false,false,false,false,
               0.,0.,uint8(0),0.,intruders)
  end

  function OutputVals(cc::Uint8,vc::Uint8,ua::Uint8,da::Uint8,target_rate::Float64,turn_off_aurals::Bool,
                      crossing::Bool,alarm::Bool,alert::Bool,dh_min::Float64,dh_max::Float64,
                      sensitivity_index::Uint8,ddh::Float64,
                      intruders::Vector{IntruderOutputVals})
    obj                    = new()
    obj.cc                 = cc
    obj.vc                 = vc
    obj.ua                 = ua
    obj.da                 = da
    obj.target_rate        = target_rate
    obj.turn_off_aurals    = turn_off_aurals
    obj.crossing           = crossing
    obj.alarm              = alarm
    obj.alert              = alert
    obj.dh_min             = dh_min
    obj.dh_max             = dh_max
    obj.sensitivity_index  = sensitivity_index
    obj.ddh                = ddh
    obj.intruders          = intruders

    return obj
  end
end

type Output
  handle::Ptr{Void}
  intruder_collection::CollectionIntruderOutput

  Output(nintruders::Int) = Output(uint8(0),uint8(0),uint8(0),uint8(0),0.,
                                   false,false,false,false,0.,0.,uint8(0),0.,
                                   CollectionIntruderOutput(nintruders))

  function Output(cc::Uint8,vc::Uint8,ua::Uint8,da::Uint8,target_rate::Float64,turn_off_aurals::Bool,
                      crossing::Bool,alarm::Bool,alert::Bool,dh_min::Float64,dh_max::Float64,
                      sensitivity_index::Uint8,ddh::Float64,
                      intruder_collection::CollectionIntruderOutput)

    obj           = new()
    obj.handle    = ccall((:newCOutput,libccas), Ptr{Void},
                          (Uint8,Uint8,Uint8,Uint8,Float64,Bool,Bool,Bool,Bool,Float64,Float64,Uint8,Float64,
                           Ptr{Void}),
                          cc, vc, ua, da, target_rate, turn_off_aurals,
                          crossing, alarm, alert, dh_min, dh_max,
                          sensitivity_index, ddh, intruder_collection.handle)
    obj.intruder_collection   = intruder_collection
    finalizer(obj,obj->ccall((:delCOutput,libccas), Void, (Ptr{Void},),obj.handle))

    return obj
  end
end

function get!(output::Output,outputVals::OutputVals)
  outputVals.cc       = ccall((:getCOutput_cc,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.vc       = ccall((:getCOutput_vc,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.ua       = ccall((:getCOutput_ua,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.da       = ccall((:getCOutput_da,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.target_rate       = ccall((:getCOutput_target_rate,libccas), Float64, (Ptr{Void},), output.handle)
  outputVals.turn_off_aurals   = ccall((:getCOutput_turn_off_aurals,libccas), Bool, (Ptr{Void},), output.handle)
  outputVals.crossing          = ccall((:getCOutput_crossing,libccas), Bool, (Ptr{Void},), output.handle)
  outputVals.alarm    = ccall((:getCOutput_alarm,libccas), Bool, (Ptr{Void},), output.handle)
  outputVals.alert    = ccall((:getCOutput_alert,libccas), Bool, (Ptr{Void},), output.handle)
  outputVals.dh_min   = ccall((:getCOutput_dh_min,libccas), Float64, (Ptr{Void},), output.handle)
  outputVals.dh_max   = ccall((:getCOutput_dh_max,libccas), Float64, (Ptr{Void},), output.handle)
  outputVals.sensitivity_index = ccall((:getCOutput_sensitivity_index,libccas), Uint8, (Ptr{Void},), output.handle)
  outputVals.ddh      = ccall((:getCOutput_ddh,libccas), Float64, (Ptr{Void},), output.handle)

  for (out,outVals) in zip(output.intruder_collection.intruders,outputVals.intruders)
    get!(out,outVals)
  end

  return outputVals
end

function update(cas::CASShared,input::Input,output::Output)
  ccall((:update,libccas),Void,(Ptr{Void},Ptr{Void},Ptr{Void}),cas.handle,input.handle,output.handle)
end

function checked_convert{T <: Unsigned}(::Type{T},n::Integer)
  return (typemin(T) <= n <= typemax(T)) ? convert(T,n) : error("Cannot convert numeric type: Out of range")
end

author() = bytestring(ccall((:author,libccas),Ptr{Uint8},()))

function unittest()
  println(author())

  config_filename = "D:/svn/sisl-rcnlee/SISLES_MCTS/libcas/run13_parameters_20140911/0.8.3.standard.r13.config.txt"
  consts = Constants(25, config_filename, 1)

  library_path = "D:/svn/sisl-rcnlee/SISLES_MCTS/libcas/libcas.0.8.3_win64_20140911/Release/libcas.dll"
  cas = CASShared(consts,library_path)

  errorMsg = error_msg(cas)
  println( errorMsg == nothing ? "No Errors" : errorMsg )

  println(version(cas))
  println("max_intruders: ", max_intruders(cas))

  nintruders = max_intruders(cas)
  input = Input(nintruders)
  inputVals = InputVals(nintruders)
  output = Output(nintruders)
  outputVals = OutputVals(nintruders)

  reset(cas)
  for t = 1:5
    println("\nt = ", t)

    inputVals.ownInput.dz = 0.1
    inputVals.ownInput.z = 0.1t
    inputVals.intruders[1].valid = true
    inputVals.intruders[1].sr = 0.2t
    inputVals.intruders[1].z = 0.1t
    set!(input,inputVals)

    update(cas,input,output)

    get!(output,outputVals)

    xdump(outputVals)
    xdump(outputVals.intruders[1])
  end

end

end

#TODOs:
# check for nulls before ccalls?
