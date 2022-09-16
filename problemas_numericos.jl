# ------------------------------------------------------------------------------
# Pacotes e funções
# ------------------------------------------------------------------------------

using ForwardDiff
using Random
using DelimitedFiles
using Printf
using LinearAlgebra

include("funcao_objetivo.jl")
include("plotar_solucao.jl")
include("restricoes.jl")
include("grad_proj.jl")

# ------------------------------------------------------------------------------
# Definição do conjunto de problemas teste
# ------------------------------------------------------------------------------

function testset(i)

    if i == 1

        lista_circulos = [3.85]
        lista_poligonos = [
                            [2.0, 9.0, 1.0, 8.0, 2.0, 7.0, 3.0, 8.0]
                            ]
        L = 9.0
        W = 8.0

    elseif i == 2

        lista_circulos = [3.85]
        lista_poligonos = [
                            [0.0, 0.0, 1.0, 2.0, 4.0, 2.0, 4.0, 0.0], 
                            [2.0, 9.0, 1.0, 8.0, 2.0, 7.0, 3.0, 8.0]
                            ]
        L = 9.0
        W = 10.0

    elseif i == 3

        lista_circulos = [3.85, 2.0]
        lista_poligonos = [
                            [0.0, 0.0, 1.0, 2.0, 4.0, 2.0, 4.0, 0.0], 
                            [2.0, 9.0, 1.0, 8.0, 2.0, 7.0, 3.0, 8.0]
                            ]
        L = 16.0
        W = 8.0

    elseif i == 4

        lista_circulos = [3.85, 2.0]
        lista_poligonos = [
                            [0.0, 0.0, 1.0, 2.0, 4.0, 2.0, 4.0, 0.0], 
                            [2.0, 9.0, 1.0, 8.0, 2.0, 7.0, 3.0, 8.0], 
                            [5.0, 2.0, 6.0, 5.0, 7.0, 2.0]
                            ]
        L = 10.0
        W = 10.0

    elseif i == 5

        lista_circulos = [3.85, 2.0]
        lista_poligonos = [
                            [0.0, 0.0, 1.0, 2.0, 4.0, 2.0, 4.0, 0.0], 
                            [2.0, 9.0, 1.0, 8.0, 2.0, 7.0, 3.0, 8.0], 
                            [5.0, 2.0, 6.0, 5.0, 7.0, 2.0],
                            [5.0, 9.0, 5.0, 7.0, 7.0, 7.0, 7.0, 9.0]
                            ]
        L = 10.0
        W = 10.0

    end

    return lista_circulos, lista_poligonos, L, W

end

# ------------------------------------------------------------------------------
# Definição da chamada do solucionador
# ------------------------------------------------------------------------------

function executar_teste(nome_arquivo; salvar_fig = false)

    Random.seed!(0)
    np = 5
    arquivo = open( "testes/" * nome_arquivo * ".tex", "w" )

    for i=1:np

        println("Executando problema $(i) de $(np) .... ")

        try
            
            # Gera os dados do problema
            lista_circulos, lista_poligonos, L, W = testset(i)
            
            # Calcula a matrix e o vetor das restrições lineares de desigualdade
            A, b = restricoes!(lista_circulos, lista_poligonos, L, W)

            # Calcula a dimensão 'n' do problema (número de variáveis) e o 
            # número de restrições 'm'
            m, n = size(A)

            # Calcula a função objetivo
            f(x) = funcao_objetivo(lista_circulos, lista_poligonos, x)

            # Calcula o gradiente da função objetivo
            ∇f(x) = ForwardDiff.gradient(f, x)

            # Gera ponto aleatorio viável
            xini = dykstra2(A, b, 10.0 * rand(n))

            # Resolve or problema
            xsol, nit = solve(f, A, b, ∇f, xini)

            # Salva informações importantes
            fsol = f(xsol)
            gsol = norm(∇f(xsol))
            texto = @sprintf("%2d & %3d & %3d & %5d & %.4e & %.4e", i, n, m, nit, fsol, gsol)
            println(arquivo, texto)

            println("sucesso!")

            # Gera e salva a figura da solução
            plota_solucao(lista_circulos, lista_poligonos, L, W, xsol; salvar_figura = salvar_fig, num_problema = i)

        catch

            # Salva informações importantes
            texto = @sprintf("%2d & - & - & - & - & -", i)
            println(arquivo, texto)

            println("falhou!")

        end

    end

    close(arquivo)

    println("Teste completo!")

end

# ------------------------------------------------------------------------------
# Chama o solucionador
# ------------------------------------------------------------------------------

executar_teste("dados_execucao"; salvar_fig = true)