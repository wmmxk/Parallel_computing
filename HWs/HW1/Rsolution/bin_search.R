bin_search <- function( arr, l, r, x){

  if (r>=l) {
					mid = l+(r-l)%/%2
					if(arr[mid] == x) return(mid)

					if (arr[mid] > x)  
					  return(bin_search(arr, l, mid-1, x))

					return(bin_search(arr, mid+1,r,x))
				}
  return(-1)
}
