using CASInterface
using CCAS

const LIBCAS = Pkg.dir("CCAS/libcas0.10.1/lib/libcas.so")
const LIBCAS_CONFIG = Pkg.dir("CCAS/libcas0.10.1/parameters/0.10.1.standard.r15mtf.tcas.xa.config.txt")
const LIBCAS_R14 = Pkg.dir("CCAS/libcas0.9.3/lib/libcas.so")
const LIBCAS_CONFIG_R14 = Pkg.dir("CCAS/libcas0.9.3/parameters/0.9.3.standard.r14.xa.config.txt")

function set_input_coc!(input::Input)
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
    input.intruders[1].equipage = EQUIPAGE_MODES
    input.intruders[1].quant = 25
    input.intruders[1].sensitivity_index = 0x0
    input.intruders[1].protection_mode = 0x0
    input
end

function set_input_ra!(input::Input, t)
    input.ownInput.dz = 0.0
    input.ownInput.z = 5000
    input.ownInput.psi = 0.0
    input.ownInput.h = 5000
    input.ownInput.modes = 0x1
    input.intruders[1].valid = true
    input.intruders[1].id = 100
    input.intruders[1].modes = 0x2
    input.intruders[1].chi = 0.0
    input.intruders[1].sr = 10000 - 500 * t
    input.intruders[1].z = 5000
    input.intruders[1].cvc = 0x0
    input.intruders[1].vrc = 0x0
    input.intruders[1].vsb = 0x0
    input.intruders[1].equipage = EQUIPAGE_TCAS
    input.intruders[1].quant = 25
    input.intruders[1].sensitivity_index = 0x0
    input.intruders[1].protection_mode = 0x0
    input
end

function timingtest(libcas::AbstractString=LIBCAS, 
    libcas_config::AbstractString=LIBCAS_CONFIG; ntrials::Int64=10, nsteps::Int64=50,
    printout::Bool=true)

    println("===============")
    println("Timing test")
    println("===============")
  
    result = Dict{ASCIIString,Any}()
    result["reset"] = Array(Float64, ntrials)
    result["update"] = Array(Float64, (ntrials, nsteps))

    println(author())
    consts = Constants(25, libcas_config, 1)
    cas = CASShared(libcas, consts)
    println(version(cas)) 

    nintruders = max_intruders(cas)
    input = Input(nintruders)
    output = Output(nintruders)

    for i = 1:ntrials
        println("trial $i of $ntrials")
        tic();
        reset(cas)
        result["reset"][i] = toq();

        for t = 1:nsteps
            set_input_ra!(input, t)
            tic();
            update!(cas, input, output)
            result["update"][i,t] = toq();
        end
    end
    if printout
        println("Results")
        println("=======")
        for (item, times) in result
            println("$item: $(mean(times)) seconds")
        end
    end
    result
end

function runtest(libcas::AbstractString=LIBCAS, 
    libcas_config::AbstractString=LIBCAS_CONFIG)
    
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

    println("===============")
    println("COC test")
    println("===============")
    for i = 1:5
        println("\ni = ", i)
        reset(cas)

        for t = 1:1
            println("\nt = ", t)

            set_input_coc!(input)
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

    println("")
    println("===============")
    println("active RA test")
    println("===============")
    for t = 1:20
        println("\nt = ", t)

        set_input_ra!(input, t)
        update!(cas, input, output)

        #xdump(input.ownInput)
        #xdump(input.intruders[1])
        #xdump(output)
        #xdump(output.intruders[1])
        println("own_out[",output.cc,",",output.vc,",",output.ua,",",output.da,"]")
        println("intr_out[",output.intruders[1].cvc,",",output.intruders[1].vrc,",",output.intruders[1].vsb,"]")
        println("target_rate=",output.target_rate)
        println("dh_min=",output.dh_min,", dh_max=",output.dh_max)

        errorMsg = error_msg(cas)
        println( errorMsg == nothing ? "No Errors" : errorMsg )
    end

    println()
    println("Done!")
end
