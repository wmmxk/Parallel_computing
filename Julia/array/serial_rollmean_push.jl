function rollmean(arr, k)
  n = length(arr)
	meanarr = Float64[]

	for i in 1:(n-k+1)
		 push!(meanarr, arr[i])
				for j in 1:(k-1)
						meanarr[i] = meanarr[i] + arr[i+j]
				end
		 meanarr[i] = meanarr[i] / k
  end
  meanarr
end

n = parse(Int64, ARGS[1])
k = 3
arr = collect(1:n)
println(arr)
meanarr = rollmean(arr, 3)
println(meanarr)
