using LinearAlgebra

# problema:
# min f(x)
# sa: Ax <= b

#proj_dykstra = false

function escalonar(A, tol = 1.0e-8)
	(m, n) = size(A)
	l = 1
	j = 1
	p = 0 # posto da matriz A
	p_r = 0 # posto da matriz A sem a última coluna
	v = [i for i=1:m] # indices das linhas L.I's

		while (j <= n) && (l <= m)
			ind_max = l
			for i=(l+1):m
				if abs(A[i, j]) > abs(A[ind_max, j])
					ind_max = i
				end
			end
			if abs(A[ind_max, j]) >= tol
				if j < n # calcular o posto
					p += 1
					p_r += 1
					#push!(v, l) # Guarda o indice da coluna que contem o primeiro elemento não nulo
				else
					p += 1
				end
				A[l, :], A[ind_max, :] = A[ind_max,:], A[l, :] # Troca de linhas
				v[l], v[ind_max] = v[ind_max], v[l]
				for i=(l+1):m
					A[i, :] -= (A[i, j]/A[l, j])*A[l, :] # Zerar primeiros elementos
					for k=1:n
						if abs(A[i, k]) < tol
							A[i, k] = 0.0
						end
					end
				end
				l += 1
			end
			j += 1
		end
		return (A, p, p_r, v[1:p])
end

function verif_ativ(A, b, x0, tol = 1.0e-8)
	(m, n) = size(A)
	I_k = []
	for i=1:m
		if abs(A[i, :]'*x0 - b[i]) < tol
			push!(I_k, i)
		end
	end
	r_k = length(I_k)
	return (I_k, r_k)
end

function resolver_sist_lin(A, b, unica = true)

	(m, n) = size(A)

	(r, pAb, pA, v) = escalonar(hcat(A,b))

	A = r[1:end, 1:n]
	b = r[1:end, n+1]

	if (pA != pAb)
		return nothing
	else
		if (unica == true) && (pA != n) # mais variáveis que equações
			return nothing # manda os indices das linhas L.I's de A
		end
		return A\b
	end
end

function calc_alpha_sup(A, b, d, x, tol = 1.0e-8)
	(m, n) = size(A)
	lista = []
	for i=1:m
		den = A[i, :]'*d
		if den > tol
			al = (b[i] - A[i, :]'*x)/den
			push!(lista, al)
		end
	end

	if length(lista) == 0 # Não há restrições que se ativam na direção de d
		alpha = 1.0
	else
		alpha = lista[1]
		for i=2:length(lista)
			if 0<=lista[i]<alpha
				alpha = lista[i]
			end
		end
	end
	println("x: ", x)
	println("Alpha: ", alpha)
	return alpha
end

function dir_desc_fact_nuc(A, grad, use_dykstra)

	# P*d = (I - A'(A*A')^(-1)A)*d
	# ou equivalentemente
	# se M = A*A' e y = A*d, então
	# P*d = d - A'*M^(-1)*y

	if use_dykstra == true
		return dykstra(A, grad)
	end

	(m, n) = size(A)
	d = -grad

	M = A*A'
	y = A*d

#	z = M\y

#	display(M)
#	display(y)

	C = cholesky(M)
	
	w = C.L \ y
	z = C.U \ w

#	if z == nothing
#		error("Não foi possível calcular a projeção, pois M não é inversível!")
#	end

	return d - A'*z # vetor d projetado no núcleo de A
end

function projecao(n, x)
		return x - ((n'*x)/(n'*n))*n
end

function dykstra(A, grad) # dykstra

	(m, n) = size(A)
	Y = zeros(length(grad), m)
	# acima está sendo tomado -grad, pois queremos
	# obter uma direção de descida
	x0 = - grad
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
			x = projecao(A[i, :], delta) # projeção em omega_i
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

function dir_desc_fact(grad)
	return -grad
end

function busca_linear(f, grad, x, d, alpha_sup, c = 1.0e-4)
	alpha = alpha_sup
	while f(x + alpha * d) > f(x) + c * alpha * grad' * d
		alpha *= 0.5
	end
	return x + alpha * d
end

function minimizar(f, A, b, g, x0, use_dykstra = false, tol = 1.0e-8)

	(m, n) = size(A)
	
	it = 0
	x0_ant = copy(x0)

	while true
		it += 1
		println("Iteração ", it)

		erro = norm(x0 - x0_ant)
		x0_ant = copy(x0)

		if (it == 100) || (it >= 2 && erro < tol)
			if it < 100
				println("A sequência de pontos convergiu.")
			end
			break
		end
		(I_k, r_k) = verif_ativ(A, b, x0)
		grad = g(x0)
		# Passo 1
		if r_k == 0
			if norm(grad) < tol
				println("Não temos restrições ativas e o gradiente se anulou! Parando por aqui.")
				break
			end
			d_k = dir_desc_fact(grad) # direção de descida factível em x_k
			println("d_k: ", d_k)
			println("")
		else
			lambda = resolver_sist_lin(A[I_k, :]', grad, false) # Resolver sistema linear A_{I_K}^T lambda
			I_k_li = escalonar(A[I_k, :])[4] # pega o número de linhas L.I's
			I_k_li = I_k[I_k_li] # Pega os indices correspondentes na matriz A original
			if lambda == nothing # o sistema não possui solução
				d_k = dir_desc_fact_nuc(A[I_k_li, :], grad, use_dykstra) # direção de descida no nuc(a_{I_K}^T)
				println("d_k (projetado): ", d_k)
				println("")
			else
				ind_neg = []
				no_positive = true
				println("Infos:")
				println("lambdas:", lambda)
				println("restricoes ativas: ", I_k)
				println("restrições ativas li's: ",I_k_li)
				for i=1:r_k
					if (lambda[i] < 0) 
						push!(ind_neg, I_k[i])
					end
					if (lambda[i] > 0)
						no_positive = false
					end
				end
				println("ind_neg: ", ind_neg)
				if no_positive
					println("Não há lambda's positivos! Parando por aqui.")
					break
				end
#				println(ind_neg)
#				println(I_k_li)
				if length(ind_neg) == 0
					d_k = - grad
				else
					d_k = dir_desc_fact_nuc(A[ind_neg, :], grad, use_dykstra) #dir_desc_fact(grad) # direção de descida factível em x_k
				end
				println("d_k (projetado, mas apenas sobre os lambdas negativos): ", d_k)
				println("")
			end
		end
		# Passo 5
		alpha_sup = calc_alpha_sup(A, b, d_k, x0) # determinar o valor do limitante superior pra alpha
		# Busca linear
		x0 = busca_linear(f, grad, x0, d_k, alpha_sup)
	end

	println("x0: ", x0)
	println("f(x0): ", f(x0))
	println("grad f(x0): ", g(x0))

	#return (x0, f(x0), g(x0))	
end

