module LabelledArrays

using LinearAlgebra, StaticArrays

include("slarray.jl")
include("larray.jl")
include("slsliced.jl")
include("lsliced.jl")

using MacroTools

struct PrintWrapper{T,N,F,X<:AbstractArray{T,N}} <: AbstractArray{T,N}
    f::F
    x::X
end

import Base: eltype, length, ndims, size, axes, eachindex, stride, strides
MacroTools.@forward PrintWrapper.x eltype, length, ndims, size, axes, eachindex, stride, strides
Base.getindex(A::PrintWrapper, idxs...) = A.f(A.x, A.x[idxs...], idxs)

function lazypair(A, x, idxs)
    syms = symnames(typeof(A))
    II = LinearIndices(A)
    key = eltype(syms) <: Symbol ? syms[II[idxs...]] : findfirst(syms) do sym
        ii = idxs isa Tuple ? II[idxs...] : II[idxs]
        sym isa Tuple ? ii in II[sym...] : ii in II[sym]
    end
    key => x
end

Base.show(io::IO, ::MIME"text/plain", x::Union{LArray,SLArray}) = show(io, x)
function Base.show(io::IO, x::Union{LArray,SLArray})
    syms = symnames(typeof(x))
    n = length(syms)
    PrintWrapper(lazypair, x)
    Base.print_array(io, PrintWrapper(lazypair, x))
end

export SLArray, LArray, SLVector, LVector, @SLVector, @LArray, @LVector, @SLArray

export @SLSliced, @LSliced

export symbols, dimSymbols, rowSymbols, colSymbols

end # module
