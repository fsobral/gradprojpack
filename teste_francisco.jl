using ForwardDiff

include("funcao_objetivo.jl")
include("plotar_solucao.jl")
include("restricoes.jl")
include("grad_proj.jl")

pol_1 = [[2.0, 9.0, 1.0, 8.0, 2.0, 7.0, 3.0, 8.0], [2.0, 9.0, 1.0, 8.0, 2.0, 7.0, 3.0, 8.0]]
r = [3.85]

L = 10.0
W = 10.0

A, b = restricoes!(r, pol_1, L, W)

m, n = size(A)

f(x) = funcao_objetivo(r, pol_1, x)

∇f(x) = ForwardDiff.gradient(f, x)

# Gera ponto aleatorio viavel
xini = dykstra2(A, b, 10 * rand(n))

# Resolve
xsol, nit = solve(f, A, b, ∇f, xini)

# Desenha
plota_solucao(r, pol_1, 10, 10, xsol)    
