library(Rcpp)
cppFunction('int add(int x, int y, int z) {
  int sum = x + y + z;
  return sum;
  }')
# add works like a regular R function

#> function (x, y, z)
#> .Primitive(".Call")(<pointer: 0x7f2f4aa933d0>, x, y, z)
add(1, 2, 3)
