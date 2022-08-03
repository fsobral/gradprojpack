using Test

include("restricoes.jl")

@testset "restricoes" begin
    
    @testset "translacao_poligono" begin

        lista_vertice = [[7.0 2.0 11.0 0.0 13.0 7.0 9.0 5.0], [11.0 3.0 17.0 0.0 13.0 7.0]]
        lista_transladada = [[0.0 0.0 4.0 -2.0 6.0 5.0 2.0 3.0], [0.0 0.0 6.0 -3.0 2.0 4.0]]
    
        translacao_poligono!(lista_vertice)
    
        @test( lista_transladada[1] == lista_vertice[1] )
        @test( lista_transladada[2] == lista_vertice[2] )
    
    end

    @testset "min_max_x" begin
    
        lista_vertice = [[7.0 2.0 11.0 0.0 13.0 7.0 9.0 5.0], [11.0 3.0 17.0 0.0 13.0 7.0]]
        min_x_1 = 7.0
        max_x_1 = 13.0
        min_x_2 = 11.0
        max_x_2 = 17.0
    
        a_1, b_1 = min_max_x(lista_vertice, 1)
        a_2, b_2 = min_max_x(lista_vertice, 2)
    
        @test( min_x_1 == a_1 )
        @test( max_x_1 == b_1 )
        @test( min_x_2 == a_2 )
        @test( max_x_2 == b_2 )
    
    end

    @testset "min_max_y" begin
    
        lista_vertice = [[7.0 2.0 11.0 0.0 13.0 7.0 9.0 5.0], [11.0 3.0 17.0 0.0 13.0 7.0]]
        min_y_1 = 0.0
        max_y_1 = 7.0
        min_y_2 = 0.0
        max_y_2 = 7.0
    
        a_1, b_1 = min_max_y(lista_vertice, 1)
        a_2, b_2 = min_max_y(lista_vertice, 2)
    
        @test( min_y_1 == a_1 )
        @test( max_y_1 == b_1 )
        @test( min_y_2 == a_2 )
        @test( max_y_2 == b_2 )
    
    end

    @testset "restricoes" begin

        # --------------------------------------------------------------------------------
        # Teste 01 - 2 círculos e 2 polígonos (quadrilátero e triângulo)
        # --------------------------------------------------------------------------------
        
        lista_circ = [2.0, 3.0]
        lista_vertice = [[7.0 2.0 11.0 0.0 13.0 7.0 9.0 5.0], [11.0 3.0 17.0 0.0 13.0 7.0]]
        L = 10.0
        W = 12.0
    
        A_sol = zeros(16, 23)
        A_sol[1, 1] = 1.0
        A_sol[3, 2] = 1.0
        A_sol[5, 3] = 1.0
        A_sol[7, 4] = 1.0
        A_sol[9, 5] = 1.0
        A_sol[11, 6] = 1.0
        A_sol[13, 7] = 1.0
        A_sol[15, 8] = 1.0
        A_sol[2, 1] = -1.0
        A_sol[4, 2] = -1.0
        A_sol[6, 3] = -1.0
        A_sol[8, 4] = -1.0
        A_sol[10, 5] = -1.0
        A_sol[12, 6] = -1.0
        A_sol[14, 7] = -1.0
        A_sol[16, 8] = -1.0
    
        min_x_1 = 0.0
        max_x_1 = 6.0
        min_y_1 = -2.0
        max_y_1 = 5.0
        min_x_2 = 0.0
        max_x_2 = 6.0
        min_y_2 = -3.0
        max_y_2 = 4.0
    
        b_sol = [
                    W - lista_circ[1], - lista_circ[1], L - lista_circ[1], - lista_circ[1], 
                    W - lista_circ[2], - lista_circ[2], L - lista_circ[2], - lista_circ[2],
                    W - max_x_1, min_x_1, L - max_y_1, min_y_1,
                    W - max_x_2, min_x_2, L - max_y_2, min_y_2,
                ]
    
        A, b = restricoes!(lista_circ, lista_vertice, L, W)
    
        @test(A_sol == A)
        @test(b_sol == b)
    
        # --------------------------------------------------------------------------------
        # Teste 02 - 2 círculos
        # --------------------------------------------------------------------------------
    
        lista_circ = [2.0, 1.0]
        lista_vertice = []
        L = 8.0
        W = 10.0
    
        A_sol = zeros(8, 4)
        A_sol[1, 1] = 1.0
        A_sol[3, 2] = 1.0
        A_sol[5, 3] = 1.0
        A_sol[7, 4] = 1.0
        A_sol[2, 1] = -1.0
        A_sol[4, 2] = -1.0
        A_sol[6, 3] = -1.0
        A_sol[8, 4] = -1.0
    
        b_sol = [
                    W - lista_circ[1], - lista_circ[1], L - lista_circ[1], - lista_circ[1],
                    W - lista_circ[2], - lista_circ[2], L - lista_circ[2], - lista_circ[2]
                ]
    
        A, b = restricoes!(lista_circ, lista_vertice, L, W)
    
        @test(A_sol == A)
        @test(b_sol == b)
    
        # --------------------------------------------------------------------------------
        # Teste 03 - 2 polígonos (triâgulos)
        # --------------------------------------------------------------------------------
    
        lista_circ = []
        lista_vertice = [[0.0 0.0 3.5 2.0 5.2 4.7], [1.5 2.5 -5.0 -2.0 3.5 5.0]]
        L = 20.0
        W = 30.0
    
        A_sol = zeros(8, 7)
        A_sol[1, 1] = 1.0
        A_sol[3, 2] = 1.0
        A_sol[5, 3] = 1.0
        A_sol[7, 4] = 1.0
        A_sol[2, 1] = -1.0
        A_sol[4, 2] = -1.0
        A_sol[6, 3] = -1.0
        A_sol[8, 4] = -1.0
    
        min_x_1 = 0.0
        max_x_1 = 5.2
        min_y_1 = 0.0
        max_y_1 = 4.7
        min_x_2 = -6.5
        max_x_2 = 2.0
        min_y_2 = -4.5
        max_y_2 = 2.5
    
        b_sol = [
                    W - max_x_1, min_x_1, L - max_y_1, min_y_1,
                    W - max_x_2, min_x_2, L - max_y_2, min_y_2
                ]
    
        A, b = restricoes!(lista_circ, lista_vertice, L, W)
    
        @test(A_sol == A)
        @test(b_sol == b)
    
    end

end