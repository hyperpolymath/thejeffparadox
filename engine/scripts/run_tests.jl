#!/usr/bin/env julia
#
# run_tests.jl - Run JeffEngine tests with proper module loading
#

using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()

# Include the module
include(joinpath(@__DIR__, "..", "src", "JeffEngine.jl"))
using .JeffEngine

# Run the test suite
include(joinpath(@__DIR__, "..", "test", "runtests.jl"))
