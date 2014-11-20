using CCAS

PACKAGE_PATH = Pkg.dir("CCAS")
const LIBCAS_CONFIG = joinpath(PACKAGE_PATH,"libcas/parameters/0.8.3.standard.r13.config.txt")
const LIBCAS_LIB = joinpath(PACKAGE_PATH,"libcas/lib/libcas.dll")

println(author())

consts = Constants(25, LIBCAS_CONFIG, 1)
cas = CASShared(consts,LIBCAS_LIB)

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

  inputVals.ownInput.modes = 0x123
  inputVals.ownInput.dz = 0.1
  inputVals.ownInput.z = 0.1t
  inputVals.intruders[1].valid = true
  inputVals.intruders[1].id = 100
  inputVals.intruders[1].modes = 0x456
  inputVals.intruders[1].sr = 0.2t
  inputVals.intruders[1].z = 0.1t
  set!(input,inputVals)

  update(cas,input,output)

  get!(output,outputVals)

  xdump(outputVals)
  xdump(outputVals.intruders[1])

  errorMsg = error_msg(cas)
  println( errorMsg == nothing ? "No Errors" : errorMsg )

end

println()
println("Done!")
