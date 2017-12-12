function pfindpi(n)
         inside = @parallel (+) for i = 1:n
               x, y = rand(2)
               x^2 + y^2 <=1 ? 1:0
         end
         4 * inside /n
         end
@time pfindpi(300000000)
