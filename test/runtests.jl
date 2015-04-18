using CCAS

function runtest(libcas::String, config_file::String)
  println(author())

  consts = Constants(25, config_file, 1)
  cas = CASShared(libcas, consts)
  println("cas handle = ", cas.handle)

  println(version(cas))
  println("max_intruders: ", max_intruders(cas))

  nintruders = max_intruders(cas)
  inputVals = InputVals(nintruders)
  outputVals = OutputVals(nintruders)
  println("output handle = ", cas.output.handle)

  for i=1:5
    println("\ni = ", i)
    reset(cas)

    for t = 1:1
      println("\nt = ", t)

      inputVals.ownInput.dz = 0.0
      inputVals.ownInput.z = 1665
      inputVals.ownInput.psi = 0.0
      inputVals.ownInput.h = 1665
      inputVals.ownInput.modes = 0x1
      inputVals.intruders[1].valid = true
      inputVals.intruders[1].id = 100
      inputVals.intruders[1].modes = 0x2
      inputVals.intruders[1].chi = -1.2
      inputVals.intruders[1].sr = 16500
      inputVals.intruders[1].z = 2200
      inputVals.intruders[1].cvc = 0x0
      inputVals.intruders[1].vrc = 0x0
      inputVals.intruders[1].vsb = 0x0
      inputVals.intruders[1].equipage = EQUIPAGE.EQUIPAGE_ATCRBS
      inputVals.intruders[1].quant = 25
      inputVals.intruders[1].sensitivity_index = 0x0
      inputVals.intruders[1].protection_mode = 0x0

      update!(cas,inputVals,outputVals)

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
