@everywhere include("modify.jl")

n = parse(Int64, ARGS[1])
arr = collect(1:n)
println(arr)

@everywhere arr
remotecall_fetch(()->modify(arr,1,3),2)

remotecall_fetch(()->modify(arr,4,n),3)


println(arr)
