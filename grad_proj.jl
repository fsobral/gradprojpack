function projecao(n, b, x0) # projeção em n'*x <= b
	lamb = (b - n'*x0) / (n'*n)
	if lamb >= 1.0e-8 # x0 já está no semi plano
		return x0
	else
		return x0 + lamb * n
	end
end

function dykstra2(A, b, x0) # dykstra simplificado
	(m, n) = size(A)

	lim = 10000
	it = 1
	println("\tDykstra simplificado está sendo executado!")
	println("\tIteração: ", it)
	println("\t\tx0 original: ", x0)
	while it <= lim
	erro = copy(x0)
	for i=1:m
		x0 = projecao(A[i, :], b[i], x0)
	end
	println("\t\tprojeção de x0: ", x0)
	it +=1
	erro = x0 - erro
	erro = erro'*erro
	if erro <= 1.0e-8
		println("\tA sequência convergiu pelo critério fraco.")
		break
	end
	end
	if it > lim
		println("\tO limite de iterações foi atingido!")
	end
	println("\tDykstra simplificado finalizou!")
	return x0
end

function dykstra(A, b, x0) # dykstra

	(m, n) = size(A)
	Y = zeros(n, m)
	x = copy(x0)

	println("Dykstra executou :D")

	it = 0
	c_I_ant = 0
	while true && it < 10000
		it += 1
		c_I_it = 0
		for i=1:m
			
			ind = mod((i-1) - 1, m) + 1 # pega o indice do antecessor

			delta = x0 - Y[:, i]
			x = projecao(A[i, :],b[i], delta) # projeção em omega_i
			Y_i_ant = copy(Y[:, i])
			Y[:, i] = x - delta
			Y_i_ant = Y[:, i] - Y_i_ant
			c_I_it += Y_i_ant'*Y_i_ant
		end
		if abs(c_I_it - c_I_ant) < 1.0e-8 # a sequência convergiu para a projeção em omega pelo critério de parada robusto
			println("O algoritmo de Dykstra convergiu para a projeção em ",it, " iterações!")
			break
		end
		x0 = x
		c_I_ant = c_I_it
	end
	if it == 10000
		println("A sequência não convergiu para a projeção no limite de iterações!")
	end
	return x

end

function solve(f, A, b, g, x0, tol = 1.0e-8)
	(m, n) = size(A)
	alpha = 0.5
	sig_min = 1.0e-8
	sig_max = 1.0
	sig = 1.0
	it = 1
	while true
		g_ant = g(x0)
		x0_ant = x0
		println("Iteração: ", it)
		println("grad: ", g(x0))
		println("x0:", x0)
		println("sig: ", sig)
		println("x0 - 1/sig * grad(x0): ", x0 - (1.0/sig)*g(x0))
		d = dykstra2(A, b, x0 - (1.0/sig)*g(x0)) - x0 # direção
		println("Gradiente projetado (d) foi calculado!")
		println("d = ", d)
		if (d'*d <= tol)
			println("O gradiente projetado zerou!")
			println("||d||^2 = ", d'*d)
			break
		end
		t = 1.0
		for i=1:m
			if A[i, :]'*d > 1.0e-4
				t = minimum([t, maximum([(b[i] - A[i, :]'*x0)/(A[i, :]'*d), 0])]) # tamanho máximo de passo antes de ser bloqueado por alguma restrição
			end
			if t < tol # se um tamanho de passo der nulo, pare de procurar
				break
			end
		end
		println("Tamanho máximo (t) de passo da busca linear determinado!")
		println("t= ", t)
		while f(x0+t*d) > f(x0) + alpha*t*g(x0)'*d
			t *= 0.5
		end
		x0 = x0 + t*d
		println("Passo escolhido pela busca linear: ", t)
		println("x_{k+1} = ", x0)
		y = g_ant - g(x0)
		s = x0_ant - x0
		if s'*s > 1.0e-8
			sig = maximum([sig_min, minimum([sig_max, (s'*y) / (s'*s)])])
		else
			if s'*y < 0
				sig = sig_min
			else
				sig = sig_max
			end
		end
		it += 1
		if it >= 1000
			println("O limite de iterações foi atingido!")
			break
		end
	end
	println("Solução final: ", x0)
	return x0
end
