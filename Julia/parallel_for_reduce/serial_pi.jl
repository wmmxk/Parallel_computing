function findpi(n)
        inside = 0
        for i = 1:n
           x,y = rand(2)
           if (x^2 + y^2 <=1)
              inside +=1
           end
        end
        4 * inside /n
       end
@time findpi(300000000)
