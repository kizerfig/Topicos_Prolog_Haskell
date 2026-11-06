%Modulo 2: Motor de Busqueda de Rutas con Restricciones
:- ensure_loaded('parser.pl').

%Verifica si el vuelo opera el dia solicitado (Diario aplica siempre)
dia_compatible(['Diario'], _) :- !.

dia_compatible(Lista_Dias, Dia_Buscado) :-
    member(Dia_Buscado, Lista_Dias).

%Validación de Escala: Verifica que Salida(V2) >= Llegada(V1) + TMC
cumple_tmc(Salida_V2, Llegada_V1, TMC) :-
    Salida_V2 >= Llegada_V1 + TMC.


%Búsqueda de ruta Recursiva

% ¿Cómo va la búsqueda recursiva?
%!  buscar_ruta_dfs(Ciudad_Actual, Destino, Dia, Ciudades_Visitadas, TMC,
%!                  Escalas_Restantes, Ultima_Llegada, Ruta) 
%
%   Busca recursivamente rutas desde Ciudad_Actual hasta Destino aplicando
%   4 restricciones simultaneas:

%     1 Compatibilidad de dia (dia_compatible/2)
%     2. Ventana de conexion   (cumple_tmc/3)
%     3. Control de ciclos     (Siguiente no debe estar en Ciudades_Visitadas)
%     4. Limite de escalas     (Escalas_Restantes > 0)


%Caso base: si ya llegamos al destino, la ruta termina
buscar_ruta_dfs(Destino, Destino, _, _, _, _, _, []) :- !.

%Caso recursivo: se elige un vuelo valido y sigue el recorrido
buscar_ruta_dfs(Ciudad_Actual, Destino, Dia, Ciudades_Visitadas, TMC, Escalas_Restantes, Ultima_Llegada,
                [vuelo(Ciudad_Actual, Ciudad_Siguiente, Salida, Llegada, Precio, ID, Dias_Vuelo) | Resto_Ruta]) :-
    Escalas_Restantes > 0,
    vuelo(Ciudad_Actual, Ciudad_Siguiente, Salida, Llegada, Precio, ID, Dias_Vuelo),
    \+ member(Ciudad_Siguiente, Ciudades_Visitadas),
    dia_compatible(Dias_Vuelo, Dia),
    cumple_tmc(Salida, Ultima_Llegada, TMC),
    Nuevas_Escalas is Escalas_Restantes - 1,
    buscar_ruta_dfs(Ciudad_Siguiente, Destino, Dia,
                    [Ciudad_Siguiente | Ciudades_Visitadas], TMC, Nuevas_Escalas, Llegada, Resto_Ruta).

%Recolecta todas las rutas validas entre Origen y Destino con findall
buscar_rutas(Origen, Destino, Dia, Max_Escalas, Todas_Las_Rutas) :-
    obtener_tmc(TMC),
    Limite_Saltos is Max_Escalas + 1,
    findall(
        Ruta,
        buscar_ruta_dfs(Origen, Destino, Dia, [Origen], TMC, Limite_Saltos, 0, Ruta),
        Todas_Las_Rutas
    ).


%Pruebas manuales (cargar primero: ?- cargar_vuelos_defecto.)

% 1: Vuelo directo disponible
% ?- buscar_rutas('Pto Ordaz', 'Maiquetia', 'L', 2, Rs), length(Rs, N).  
% N >= 1

% 2: Ruta con escala, lunes
% ?- buscar_rutas('Pto Ordaz', 'Porlamar', 'L', 3, Rs), length(Rs, N).   
% N = 3

% 3: Sin rutas por restriccion de dia
% ?- buscar_rutas('Valencia', 'Porlamar', 'Mi', 2, Rs).                   
% Rs = []

% 4: Solo vuelo directo (Max_Escalas = 0)
% ?- buscar_rutas('Pto Ordaz', 'Maiquetia', 'L', 0, Rs), length(Rs, N).  
% N = 1

% 5: Control de ciclos (no debe ciclar aunque haya vuelos de ida/vuelta)
% ?- buscar_rutas('Pto Ordaz', 'Maracaibo', 'L', 5, Rs), length(Rs, N).  
% N finito

