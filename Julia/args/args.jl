# how to pass an argument and convert it to an integer
n = parse(Int64,ARGS[1])
arr = collect(1:n)
println(ARGS[1])
println(arr)
