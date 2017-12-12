@everywhere include("count_heads.jl")
a =  @spawn count_heads(100000000)
b =  @spawn count_heads(100000000)

c = fetch(a) + fetch(b)

println(c)
