mat_mul_s  <- function(A,B) {
   ans1 <- .C("mat_mul_c_s", as.numeric(A), dim(A), as.numeric(B), dim(B),
														result = numeric(nrow(A)*ncol(B)))$result
   dim(ans1) <- c(nrow(A), ncol(B))
			ans1

}


mat_mul_p  <- function(A,B) {
   ans1 <- .C("mat_mul_c_p", as.numeric(A), dim(A), as.numeric(B), dim(B),
														result = numeric(nrow(A)*ncol(B)))$result
   dim(ans1) <- c(nrow(A), ncol(B))
			ans1

}
