% Modulo 2: Motor de Busqueda de Rutas con Restricciones

:- ensure_loaded('parser.pl').

% Auxiliar 1: Compatibilidad de Dia
%!  dia_compatible(+Lista_Dias, +Dia_Buscado) -> Tiene exito si el vuelo opera el dia solicitado.

dia_compatible(['Diario'], _) :- !.

dia_compatible(Lista_Dias, Dia_Buscado) :-
    member(Dia_Buscado, Lista_Dias).

% dia_compatible(['Diario'], 'L')      -> Verdadero
% dia_compatible(['L','M','V'], 'L')   -> Verdadero
% dia_compatible(['L','M','V'], 'Mi')  -> Falso


% Auxiliar 2: Verificacion de Ventana de Conexion (TMC)

%!  cumple_tmc(+Salida_V2, +Llegada_V1, +TMC) -> Tiene exito si el tiempo entre vuelos es suficiente.
%   Para dos vuelos consecutivos V1 y V2 debe cumplirse: Salida(V2) >= Llegada(V1) + TMC

cumple_tmc(Salida_V2, Llegada_V1, TMC) :-
    Salida_V2 >= Llegada_V1 + TMC.

% cumple_tmc(540, 480, 45)  -> Verdadero  (09:00 >= 08:00 + 45min)
% cumple_tmc(510, 480, 45)  -> Falso      (08:30 <  08:00 + 45min)


% Motor DFS: Busqueda Recursiva con Backtracking

%!  buscar_ruta_dfs(+Ciudad_Actual, +Destino, +Dia, +Visitados, +TMC,
%!                  +Escalas_Restantes, +Ultima_Llegada, -Ruta)
%
%   Busca recursivamente rutas desde Ciudad_Actual hasta Destino aplicando
%   cuatro restricciones simultaneas:
%     1. Compatibilidad de dia (dia_compatible/2)
%     2. Ventana de conexion   (cumple_tmc/3)
%     3. Control de ciclos     (Siguiente no debe estar en Visitados)
%     4. Limite de escalas     (Escalas_Restantes > 0)
%
%   Parametros:
%     Visitados      -> lista acumuladora de ciudades ya recorridas (evita ciclos)
%     Ultima_Llegada -> hora de llegada del vuelo anterior en minutos (0 para el primero)

% Caso base: ya estamos en el destino, la ruta termina aqui
buscar_ruta_dfs(Destino, Destino, _, _, _, _, _, []) :- !.

% Caso recursivo: tomamos un vuelo desde Ciudad_Actual hacia alguna Ciudad_Siguiente
buscar_ruta_dfs(Ciudad_Actual, Destino, Dia, Visitados, TMC, Escalas_Restantes, Ultima_Llegada,
                [vuelo(Ciudad_Actual, Ciudad_Siguiente, Salida, Llegada, Precio, ID, Dias_Vuelo) | Resto_Ruta]) :-
    Escalas_Restantes > 0,
    vuelo(Ciudad_Actual, Ciudad_Siguiente, Salida, Llegada, Precio, ID, Dias_Vuelo),
    \+ member(Ciudad_Siguiente, Visitados),
    dia_compatible(Dias_Vuelo, Dia),
    cumple_tmc(Salida, Ultima_Llegada, TMC),
    Nuevas_Escalas is Escalas_Restantes - 1,
    buscar_ruta_dfs(Ciudad_Siguiente, Destino, Dia,
                    [Ciudad_Siguiente | Visitados], TMC, Nuevas_Escalas, Llegada, Resto_Ruta).


% Predicado Publico: Recoleccion de Todas las Rutas

%!  buscar_rutas(+Origen, +Destino, +Dia, +Max_Escalas, -Todas_Las_Rutas)
%   Recolecta con findall/3 todas las rutas validas entre Origen y Destino.
%   Max_Escalas indica el maximo de ciudades intermedias permitidas (0 = solo vuelo directo).

buscar_rutas(Origen, Destino, Dia, Max_Escalas, Todas_Las_Rutas) :-
    obtener_tmc(TMC),
    Limite_Saltos is Max_Escalas + 1,
    findall(
        Ruta,
        buscar_ruta_dfs(Origen, Destino, Dia, [Origen], TMC, Limite_Saltos, 0, Ruta),
        Todas_Las_Rutas
    ).

% buscar_rutas('Pto Ordaz', 'Porlamar', 'L', 3, Rs)  -> lista de rutas validas el lunes
% buscar_rutas('Valencia', 'Porlamar', 'Mi', 2, Rs)  -> Rs = [] (Vlo#9 no opera miercoles)
