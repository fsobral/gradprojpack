"""
    gerador(prob)

Return A, b, c, x0, λ0 and s0 for a given problem `prob`.
"""
function gerador(prob)

    if prob == 1

        # Restricoes
        # x + y <= 1
        # x >= 0
        # y >= 0
        A = [  1.0  1.0
              -1.0  0.0
               0.0 -1.0 ]
        b = [1.0, 0.0, 0.0]

        x0 = [3.0, 3.0]

        f = quadratica
        g = grad_quadratica

	elseif prob == 2

        # Restricoes
        # x + y <= 4
        # x >= 0
        # y >= 0
        A = [  1.0  1.0
              -1.0  0.0
               0.0 -1.0 ]
        b = [4.0, 0.0, 0.0]

        x0 = [0.0, 0.0]

        f = f2
        g = g2

	elseif prob == 3

        # Restricoes
        # x + y >= 1
        # x +2y <= 2
        A = [ -1.0 -1.0
              1.0  2.0 ]
        b = [-1.0, 2.0]

        x0 = [1.0, 0.0]

        f = f3
        g = g3

	elseif prob == 4

        # Restricoes
        # x + y >= 1
        # x + y <= 3
        # x     >= 0
        #     y >= 0
        A = [ -1.0 -1.0
			   1.0  1.0
              -1.0  0.0
			   0.0 -1.0 ]
        b = [-1.0, 3.0, 0.0, 0.0]

        x0 = [2.0, 1.0]

        f = f4
        g = g4
        
	elseif prob == 5

        # Restricoes
        #  x + y + z  = 2
		# -x +2y     <= 3
        #  x         >= 0
        #      y     >= 0
        #          z >= 0
        A = [ -1.0 -1.0 -1.0
			   1.0  1.0  1.0
			  -1.0  2.0  0.0
			  -1.0  0.0  0.0
               0.0 -1.0  0.0
			   0.0  0.0 -1.0 ]
        b = [-2.0, 2.0, 3.0, 0.0, 0.0, 0.0]

        x0 = [0.0, 0.0, 2.0]

        f = f5
        g = g5

	elseif prob == 6 # seu minimizador deve ser (0, 1)

        # Restricoes
        #  x >= 0
	#  y >= 0
	#  x <= 1
	#  y <= 1
        A = [ -1.0 0.0
	   0.0  -1.0
	  1.0  0.0
	  0.0  1.0 ]
        b = [0.0, 0.0, 1.0, 1.0]

        x0 = [1.0, 1.0]

        f = f6
        g = g6

	elseif prob == 7 # pirâmide

		# Restrições
		#  x + y + z <= 5
		# -x + y + z <= 5
		#  x - y + z <= 5
		# -x - y + z <= 5
		#          z >= 0

        A = [  1.0  1.0  1.0
			  -1.0  1.0  1.0
			   1.0 -1.0  1.0
			  -1.0 -1.0  1.0
			   0.0  0.0  -1.0 ]
		b = [5.0, 5.0, 5.0, 5.0, 0.0]
		x0 = [0.0, 0.0, 5.0]

        f = f7
        g = g7


    else
        error("Error! Bad problem number.")
    end

    return f, A, b, g, x0
        
end

# Funcoes

# Esta funcao possui minimizador irrestrito em (0.5, -1).
quadratica(x) = (x[1] - 0.5) ^ 2.0 + (x[2] + 1.0) ^ 2.0
grad_quadratica(x) = [2.0 * (x[1] - 0.5), 2.0 * (x[2] + 1)]

f2(x) = x[1]^2 - x[1]*x[2] +x[2]^2 -3.0*x[1]
g2(x) = [2*x[1]-x[2]-3.0, -x[1]+2*x[2]]

f3(x) = -x[1]*x[2]
g3(x) = [-x[2], -x[1]]

f4(x) = (x[1] + 1.0)^2 +(x[2]-1)^2
g4(x) = [2.0*x[1],2.0*x[2]]

f5(x) = x[1]^2 +x[1]*x[2] + 2.0*x[2]^2 - 6.0*x[1] -2.0*x[2] -12.0*x[3]
g5(x) = [2.0*x[1]+x[2]-6.0, x[1]+4.0*x[2]-2.0, -12.0]

f6(x) = x[1] - x[2]
g6(x) = [1.0, -1.0]

f7(x) = x[1] + x[2] + x[3]
g7(x) = [1.0, 1.0, 1.0]
