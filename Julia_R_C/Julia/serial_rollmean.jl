function rollmean(arr, k)
  n = length(arr)
	meanarr = Array{Float64}(n-k+1)

	for i in 1:(n-k+1)
		 meanarr[i] = arr[i]
		 for j in 1:(k-1)
				meanarr[i] = meanarr[i] + arr[i+j]
		 end
		 meanarr[i] = meanarr[i] / k
  end
  meanarr
end

n = parse(Int64, ARGS[1])
k = parse(Int64, ARGS[2])
arr = collect(1:n)
#println(arr)
meanarr = rollmean(arr, k)
println(meanarr[1])
