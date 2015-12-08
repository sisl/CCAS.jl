using CASInterface
using CCAS

function runtest(libcas::String, libcas_config::String)
  println(author())

  consts = Constants(25, libcas_config, 1)
  cas = CASShared(libcas, consts)
  println("cas handle = ", cas.handle)

  println(version(cas))
  println("max_intruders: ", max_intruders(cas))

  nintruders = max_intruders(cas)
  input = Input(nintruders)
  output = Output(nintruders)
  println("output handle = ", cas.output.handle)

  for i=1:5
    println("\ni = ", i)
    reset(cas)

    for t = 1:1
      println("\nt = ", t)

      input.ownInput.dz = 0.0
      input.ownInput.z = 1665
      input.ownInput.psi = 0.0
      input.ownInput.h = 1665
      input.ownInput.modes = 0x1
      input.intruders[1].valid = true
      input.intruders[1].id = 100
      input.intruders[1].modes = 0x2
      input.intruders[1].chi = -1.2
      input.intruders[1].sr = 16500
      input.intruders[1].z = 2200
      input.intruders[1].cvc = 0x0
      input.intruders[1].vrc = 0x0
      input.intruders[1].vsb = 0x0
      input.intruders[1].equipage = EQUIPAGE.EQUIPAGE_ATCRBS
      input.intruders[1].quant = 25
      input.intruders[1].sensitivity_index = 0x0
      input.intruders[1].protection_mode = 0x0

      update!(cas, input, output)

      #xdump(input.ownInput)
      #xdump(input.intruders[1])
      #xdump(output)
      #xdump(output.intruders[1])
      println("[",output.cc,",",output.vc,",",output.ua,",",output.da,"]")
      println("target_rate=",output.target_rate)
      println("dh_min=",output.dh_min,", dh_max=",output.dh_max)

      errorMsg = error_msg(cas)
      println( errorMsg == nothing ? "No Errors" : errorMsg )
    end
  end

  println()
  println("Done!")
end
