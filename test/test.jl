using CCAS

PACKAGE_PATH = Pkg.dir("CCAS")
const LIBCAS_CONFIG = joinpath(PACKAGE_PATH,"libcas/parameters/0.8.3.standard.r13.config.txt")
const LIBCAS_LIB = joinpath(PACKAGE_PATH,"libcas/lib/libcas.dll")

function runtest()
  println(author())

  consts = Constants(25, LIBCAS_CONFIG, 1)
  cas = CASShared(consts,LIBCAS_LIB)
  println("cas handle = ", cas.handle)

  println(version(cas))
  println("max_intruders: ", max_intruders(cas))

  nintruders = max_intruders(cas)
  input = Input(nintruders)
  inputVals = InputVals(nintruders)
  output = Output(nintruders)
  outputVals = OutputVals(nintruders)
  println("output handle = ", output.handle)

  set_id!(output.intruder_collection.intruders[1],100)

  for i=1:5
    println("\ni = ", i)
    reset(cas)

    for t = 1:1
      println("\nt = ", t)

      inputVals.ownInput.dz = 0.0
      inputVals.ownInput.z = 36000
      inputVals.ownInput.psi = 0.0
      inputVals.ownInput.h = 36000
      inputVals.ownInput.modes = 0x123
      inputVals.intruders[1].valid = false
      inputVals.intruders[1].id = 100
      inputVals.intruders[1].modes = 0x456
      inputVals.intruders[1].sr = 10000
      inputVals.intruders[1].z = 10000
      inputVals.intruders[1].chi = 0.0
      inputVals.intruders[1].quant = 25
      inputVals.intruders[1].equipage = EQUIPAGE.EQUIPAGE_ATCRBS

      set!(input,inputVals)

      update(cas,input,output)

      get!(output,outputVals)

      #xdump(inputVals.ownInput)
      #xdump(inputVals.intruders[1])
      #xdump(outputVals)
      #xdump(outputVals.intruders[1])
      println("[",outputVals.cc,",",outputVals.vc,",",outputVals.ua,",",outputVals.da,"]")
      println("target_rate=",outputVals.target_rate)
      println("dh_min=",outputVals.dh_min,", dh_max=",outputVals.dh_max)

      errorMsg = error_msg(cas)
      println( errorMsg == nothing ? "No Errors" : errorMsg )
    end
  end

  println()
  println("Done!")
end
