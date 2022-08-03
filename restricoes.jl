"""

    restricoes!(lista_raios_circ, lista_vertices_pol, L, W)

Calcula a matriz A e o vetor b, correspondentes as restrições
lineares do problema de corte e empacotamento: Ax ≤ b.
    
    - 'lista_raios_circ': lista contendo os raios dos círculos;
    - 'lista_vertices_pol': lista com as listas de vértices de 
    cada polígono convexo;
    - 'L': comprimento do envelope retangular;
    - 'W': largura do envelope retangular.

Retorna a matriz A e o vetor b, modifica o argumento lista_vertices_pol.

"""
function restricoes!(lista_raios_circ, lista_vertices_pol, L, W)

    # Realiza a translação do polígono para a origem.
    translacao_poligono!(lista_vertices_pol)

    # Calcula o número de círculos.
    nc = length(lista_raios_circ)

    # Calcula o número de polígonos.
    np = length(lista_vertices_pol)

    # Calcula o número de retas de separação.
    n = nc + np
    if ( np == 0 ) || ( nc == 0 && np == 1 )

        nr = 0

    else
        
        nr = Int(factorial(n) / (2 * factorial(n - 2)))

        if nc > 1

            nr -= Int(factorial(nc) / (2 * factorial(nc - 2)))

        end

    end

    # Cria a matriz e o vetor de restrições preenchidos com zeros.
    A = zeros(4 * n, 2 * n + 3 * nr)
    b = zeros(4 * n)

    # Constrói as restrições relativas aos círculos.
    for i = 1:nc

        j = 4 * (i - 1) + 1
        k = 2 * (i - 1) + 1

        A[j, k] = 1.0
        A[j + 1, k] = - 1.0
        A[j + 2, k + 1] = 1.0
        A[j + 3, k + 1] = - 1.0

        b[j] = W - lista_raios_circ[i]
        b[j + 1] = - lista_raios_circ[i]
        b[j + 2] = L - lista_raios_circ[i]
        b[j + 3] = - lista_raios_circ[i]

    end

    # Constrói as restrições relativas aos polígonos.
    des_A_linha = 4 * nc
    des_A_coluna = 2 * nc
    for i = 1:np

        j = des_A_linha + 4 * (i - 1) + 1
        k = des_A_coluna + 2 * (i - 1) + 1

        min_x, max_x = min_max_x(lista_vertices_pol, i)
        min_y, max_y = min_max_y(lista_vertices_pol, i)

        A[j, k] = 1.0
        A[j + 1, k] = - 1.0
        A[j + 2, k + 1] = 1.0
        A[j + 3, k + 1] = - 1.0

        b[j] = W - max_x
        b[j + 1] = min_x
        b[j + 2] = L - max_y
        b[j + 3] = min_y

    end

    return A, b

end


"""

    translacao_poligono!(lista_vertices_pol)

Realiza a translação do polígono para a origem.

    - 'lista_vertices_pol': lista com as listas de vértices de 
    cada polígono convexo.

Modifica o argumento da função.

"""
function translacao_poligono!(lista_vertices_pol)

    # Calcula o número de polígonos
    np = length(lista_vertices_pol)

    for i = 1:np

        # Calcula o número de vértices do polígono i
        nvert = Int(length(lista_vertices_pol[i]) / 2)

        # Subtrai as coordenadas do primeiro vértice dos demais.
        for j = nvert:-1:1

            k = 2 * j
            lista_vertices_pol[i][(k - 1): k] -= lista_vertices_pol[i][1:2]
        
        end

    end

end


"""

    min_max_x(lista_vertices_pol, indice_pol)

Calcula o valor da menor e da maior abcissa (eixo x) entre os vértices do polígono.

    - 'lista_vertices_pol': lista com as listas de vértices de 
    cada polígono convexo;
    - 'indice_pol': índice do polígono na lista.

Retorna o valor da menor e da maior abcissa.

"""
function min_max_x(lista_vertices_pol, indice_pol)

    min_x = minimum(@view lista_vertices_pol[indice_pol][1:2:end])
    max_x = maximum(@view lista_vertices_pol[indice_pol][1:2:end])

    return min_x, max_x

end


"""

    min_max_y(lista_vertices_pol, indice_pol)

Calcula o valor da menor e da maior ordenada (eixo y) entre os vértices do polígono.

    - 'lista_vertices_pol': lista com as listas de vértices de 
    cada polígono convexo;
    - 'indice_pol': índice do polígono na lista.

Retorna o valor da menor e da maior ordenada.

"""
function min_max_y(lista_vertices_pol, indice_pol)

    min_y = minimum(@view lista_vertices_pol[indice_pol][2:2:end])
    max_y = maximum(@view lista_vertices_pol[indice_pol][2:2:end])

    return min_y, max_y

end