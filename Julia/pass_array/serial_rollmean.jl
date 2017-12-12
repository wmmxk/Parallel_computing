function modify(arr)
  n = length(arr)
	for i in 1:n
  arr[i] = arr[i] + 1  
  end
end

n = parse(Int64, ARGS[1])
arr = collect(1:n)
println(arr)
@time meanarr = modify(arr)
println(arr)
