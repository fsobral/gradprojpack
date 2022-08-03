"""

    funcao_objetivo(lista_raios_circ, lista_vertices_pol, x)

Calcula o valor da função objetivo para o problema de corte e empacotamento.

    - 'lista_raios_circ': lista contendo os raios dos círculos;
    - 'lista_vertices_pol': lista com as listas de vértices de 
    cada polígono convexo;
    - 'x': vetor de variáveis. As variáveis são ordenadas da seguinte forma:
        (1) pontos de referência para cada círculo (xC, yC);
        (2) pontos de referência para cada polígono (xP, yP);
        (3) pontos de referência e ângulo de rotação para as retas de separação 
            entre polígonos (xR, yR, αR);
        (4) pontos de referência e ângulo de rotação para as retas de separação 
            entre círculos e polígonos (xR, yR, αR).

Retorna o valor da função objetivo.

"""
function funcao_objetivo(lista_raios_circ, lista_vertices_pol, x)

    # Calcula o número de círculos.
    nc = length(lista_raios_circ)

    # Calcula o número de polígonos.
    np = length(lista_vertices_pol)

    obj_1 = contribuicao_circulos(lista_raios_circ, nc, x)

    obj_2 = contribuicao_poligonos(lista_vertices_pol, nc, np, x)

    obj_3 = contribuicao_circulos_poligonos(lista_raios_circ, lista_vertices_pol, nc, np, x)

    return obj_1 + obj_2 + obj_3

end


"""

    cij(α_r, lista_pontos_reta)

Calcula o coeficiente angular da reta de separação entre os objetos 'i' e 'j'.

    - 'α_r': ângulo de rotação da reta de separação;
    - 'lista_pontos_reta': lista de pontos que determina a reta de separação inicial.

Retorna o coeficiente angular.

"""
function cij(α_r, lista_pontos_reta)

    return ((lista_pontos_reta[3] - lista_pontos_reta[1]) * sind(α_r) + (lista_pontos_reta[4] - lista_pontos_reta[2]) * cosd(α_r)) / ((lista_pontos_reta[3] - lista_pontos_reta[1]) * cosd(α_r) + (lista_pontos_reta[2] - lista_pontos_reta[4]) * sind(α_r))

end


"""

    dij(x_r, y_r, coef_angular)

Calcula o coeficiente linear da reta de separação entre os objetos 'i' e 'j'.

    - 'x_r': abscissa de referência da reta de separação;
    - 'y_r': ordenada de referência da reta de separação;
    - 'coef_angular': coeficiente angular da reta de separação;

Retorna o coeficiente linear.

"""
function dij(x_r, y_r, coef_angular)

    return y_r - coef_angular * x_r

end


"""

    Δij_square(x_c, y_c, coef_angular, coef_linear)

Calcula o quadrado da distância entre o centro da circulo 'C_i' e
a reta de separação que separa o círculo 'C_i' e o polígono 'P_j'.

    - 'x_c': abscissa de referência do círculo;
    - 'y_c': ordenada de referência do círculo;
    - 'coef_angular': coeficiente angular da reta de separação;
    - 'coef_linear': coeficiente linear da reta de separação.
    
Retorna o quadrado da distância.

"""
function Δij_square(x_c, y_c, coef_angular, coef_linear)

    return (coef_angular * x_c - y_c + coef_linear) ^ 2.0 / (coef_angular ^ 2.0 + 1.0)

end


"""

    contribuicao_circulos(lista_raios_circ, nc, x)

Calcula a contribuição da sobreposição entre círculos para a função objetivo.

    - 'lista_raios_circ': lista contendo os raios dos círculos;
    - 'nc': número de círculos;
    - 'x': vetor de variáveis.

Retorna o valor da contribuição dos círculos.

"""
function contribuicao_circulos(lista_raios_circ, nc, x)

    # Inicializa a soma dos valores da função objetivo.
    obj = 0.0
    
    # Contribuição das restrições de não-sobreposição entre círculos.
    for i = 1:(nc-1)

        # Abcissa e ordenada do centro do círculo C_i
        cx_i = x[2 * i - 1]
        cy_i = x[2 * i]

        for j = (i+1):(nc)
            
            # Abcissa e ordenada do centro do círculo C_j
            cx_j = x[2 * j - 1]
            cy_j = x[2 * j]

            obj += max(0.0, (lista_raios_circ[i] + lista_raios_circ[j]) ^ 2.0 - (cx_i - cx_j) ^ 2.0 - (cy_i - cy_j) ^ 2.0) ^ 2.0

        end

    end

    return obj

end


"""

    contribuicao_poligonos(lista_vertices_pol, nc, np, x)

Calcula a contribuição da sobreposição entre polígonos para a função objetivo.

    - 'lista_vertices_pol': lista com as listas de vértices de cada polígono;
    - 'nc': número de círculos;
    - 'np': número de polígonos;
    - 'x': vetor de variáveis.

Retorna o valor da contribuição dos polígonos.

"""
function contribuicao_poligonos(lista_vertices_pol, nc, np, x)

    # Inicializa a soma dos valores da função objetivo.
    obj = 0.0

    # Contador auxiliar
    s = 0

    # Deslocamento no vetor x até as variáveis relativas aos polígonos e as retas de separação entre polígonos
    des_p = 2 * nc
    des_r = 2 * (nc + np)

    # Contribuição das restrições de não-sobreposição entre polígonos.
    for i = 1:(np-1)

        # Abcissa e ordenada da referência do polígono P_i
        px_i = x[des_p + 2 * i - 1]
        py_i = x[des_p + 2 * i]

        # Número de vértices do polígono P_i
        nv_pi = Int(length(lista_vertices_pol[i]) / 2)

        # Pontos que determinam a reta de separação inicial
        lista_pontos_reta = @view lista_vertices_pol[i][1:4]

        for j = (i+1):np

            # Abcissa e ordenada da referência do polígono P_j
            px_j = x[des_p + 2 * j - 1]
            py_j = x[des_p + 2 * j]

            # Abcissa, ordenada e ângulo da reta de separação R_ij
            rx_ij = x[des_r + 3 * (s + j - i) - 2]
            ry_ij = x[des_r + 3 * (s + j - i) - 1]
            rα_ij = x[des_r + 3 * (s + j - i)]

            # Número de vértices do polígono P_j
            nv_pj = Int(length(lista_vertices_pol[j]) / 2)

            # Valores auxiliares
            c = cij(rα_ij, lista_pontos_reta)
            d = dij(rx_ij, ry_ij, c)
           
            # Contribuições do polígono P_i
            for k = 1:nv_pi

                vx_k = lista_vertices_pol[i][2 * k - 1]
                vy_k = lista_vertices_pol[i][2 * k]

                obj += max(0.0, vy_k + py_i - c * (vx_k + px_i) - d) ^ 2.0

            end

            # Contribuições do polígono P_j
            for k = 1:nv_pj

                vx_k = lista_vertices_pol[j][2 * k - 1]
                vy_k = lista_vertices_pol[j][2 * k]

                obj += max(0.0, - vy_k - py_j + c * (vx_k + px_j) + d) ^ 2.0

            end

        end

        s += (np - 1)

    end

    return obj

end


"""

    contribuicao_circulos_poligonos(lista_raios_circ, lista_vertices_pol, nc, np, x)

Calcula a contribuição da sobreposição entre círculos e polígonos para a função objetivo.

    - 'lista_raios_circ': lista contendo os raios dos círculos;
    - 'lista_vertices_pol': lista com as listas de vértices de cada polígono;
    - 'nc': número de círculos;
    - 'np': número de polígonos;
    - 'x': vetor de variáveis.

Retorna o valor da contribuição dos círculos e polígonos.

"""
function contribuicao_circulos_poligonos(lista_raios_circ, lista_vertices_pol, nc, np, x)

    # Inicializa a soma dos valores da função objetivo.
    obj = 0.0

    if ( np == 0 ) || ( nc == 0 && np == 1 )

        return obj

    else

        # Deslocamento no vetor x até as variáveis relativas aos polígonos e as retas de separação entre polígonos
        des_p = 2 * nc
        des_r = 2 * (nc + np)
        
        if np > 1
        
            des_r += Int(factorial(np) / (2 * factorial(np - 2)))

        end

        # Contribuição das restrições de não-sobreposição entre polígonos e círculos.
        for i=1:nc

            # Abcissa e ordenada do centro do círculo C_i
            cx_i = x[2 * i - 1]
            cy_i = x[2 * i]

            for j=1:np

                # Abcissa e ordenada da referência do polígono P_j
                px_j = x[des_p + 2 * j - 1]
                py_j = x[des_p + 2 * j]

                # Abcissa, ordenada e ângulo da reta de separação R_ij
                rx_ij = x[des_r + 3 * (np * (i - 1) + j) - 2]
                ry_ij = x[des_r + 3 * (np * (i - 1) + j) - 1]
                rα_ij = x[des_r + 3 * (np * (i - 1) + j)]

                # Número de vértices do polígono P_j
                nv_pj = Int(length(lista_vertices_pol[j]) / 2)

                # Pontos que determinam a reta de separação inicial
                lista_pontos_reta = @view lista_vertices_pol[j][1:4]

                # Valores auxiliares
                c = cij(rα_ij, lista_pontos_reta)
                d = dij(rx_ij, ry_ij, c)
                Δ2 = Δij_square(cx_i, cy_i, c, d)

                # Contribuições do círculo C_i
                obj += max(0.0, lista_raios_circ[i] ^ 2.0 - Δ2) ^ 2.0 + max(0.0, cy_i - c * cx_i - d) ^ 2.0

                # Contribuições do polígono P_j
                for k = 1:nv_pj

                    vx_k = lista_vertices_pol[j][2 * k - 1]
                    vy_k = lista_vertices_pol[j][2 * k]

                    obj += max(0.0, - vy_k - py_j + c * (vx_k + px_j) + d) ^ 2.0

                end

            end

        end

        return obj

    end

end