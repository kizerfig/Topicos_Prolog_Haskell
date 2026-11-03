%% Modulo 3: Metricas, Ordenamiento y Optimos
%% Formato del hecho (definido en parser.pl, Modulo 1):
%% Vuelo(Origen, Destino, SalidaMin, LlegadaMin, Precio, Codigo, Dias)
%% Una Ruta es una lista de hechos vuelo/7 consecutivos.
%% Horas en minutos desde 00:00 (07:00 = 420).

:- ensure_loaded('parser.pl').
% rutas.pl es del Modulo 2. Se carga con catch para poder
% probar este modulo de forma aislada mientras ese archivo no exista.
:- catch(ensure_loaded('rutas.pl'), _, true).

%% METRICAS DE UNA RUTA
%! costo_total_ruta(+Ruta, -CostoTotal)
%  Suma recursiva (con acumulador) del precio de cada vuelo.

costo_total_ruta(Ruta, CostoTotal) :-
    costo_acum(Ruta, 0, CostoTotal).

costo_acum([], Acum, Acum).
costo_acum([vuelo(_, _, _, _, Precio, _, _) | Resto], Acum, Costo) :-
    Acum1 is Acum + Precio,
    costo_acum(Resto, Acum1, Costo).

%! tiempo_total_viaje(+Ruta, -DuracionMinutos)
% Llegada del ultimo vuelo - salida del primero. Incluye las esperas
% en escala. Falla si la ruta es vacia.
tiempo_total_viaje(Ruta, DuracionMinutos) :-
    Ruta = [vuelo(_, _, Salida, _, _, _, _) | _],
    ultimo_vuelo(Ruta, vuelo(_, _, _, Llegada, _, _, _)),
    DuracionMinutos is Llegada - Salida.

ultimo_vuelo([X], X) :- !.
ultimo_vuelo([_ | Resto], U) :- ultimo_vuelo(Resto, U).

%% QUICKSORT 
%%     quicksort(+Criterio, +Lista, -Ordenada)   ascendente
%%     Criterio es costo_total_ruta o tiempo_total_viaje (se llama con
%%     call/3). Los empates van a la derecha del pivote => estable.

%! quicksort_por_costo(+ListaRutas, -RutasOrdenadas)
quicksort_por_costo(ListaRutas, RutasOrdenadas) :-
    quicksort(costo_total_ruta, ListaRutas, RutasOrdenadas).

%! quicksort_por_tiempo(+ListaRutas, -RutasOrdenadas)
quicksort_por_tiempo(ListaRutas, RutasOrdenadas) :-
    quicksort(tiempo_total_viaje, ListaRutas, RutasOrdenadas).

quicksort(_, [], []).
quicksort(Criterio, [Pivote | Resto], Ordenada) :-
    call(Criterio, Pivote, VP),
    particion(Criterio, Resto, VP, Menores, Mayores),
    quicksort(Criterio, Menores, OrdMenores),
    quicksort(Criterio, Mayores, OrdMayores),
    concatenar(OrdMenores, [Pivote | OrdMayores], Ordenada).

% particion(+Criterio, +Lista, +ValorPivote, -Menores, -MayoresOIguales)
particion(_, [], _, [], []).
particion(Criterio, [X | Xs], VP, [X | Menores], Mayores) :-
    call(Criterio, X, VX),
    VX < VP, !,
    particion(Criterio, Xs, VP, Menores, Mayores).
particion(Criterio, [X | Xs], VP, Menores, [X | Mayores]) :-
    particion(Criterio, Xs, VP, Menores, Mayores).

concatenar([], L, L).
concatenar([X | Xs], L, [X | R]) :- concatenar(Xs, L, R).

%% DETERMINACION DE OPTIMOS
%%    Recorrido con acumulador (mejor ruta y valor hasta el momento).
%%    En empate se conserva la primera encontrada. Falla si la lista
%%    es vacia (main.pl ya valida Rutas == [] antes de llamar).

%! mejor_ruta_costo(+ListaRutas, -MejorRuta, -CostoMinimo)
mejor_ruta_costo(ListaRutas, MejorRuta, CostoMinimo) :-
    mejor_ruta(costo_total_ruta, ListaRutas, MejorRuta, CostoMinimo).

%! mejor_ruta_tiempo(+ListaRutas, -MejorRuta, -TiempoMinimo)
mejor_ruta_tiempo(ListaRutas, MejorRuta, TiempoMinimo) :-
    mejor_ruta(tiempo_total_viaje, ListaRutas, MejorRuta, TiempoMinimo).

mejor_ruta(Criterio, [R | Rs], Mejor, Valor) :-
    call(Criterio, R, V),
    mejor_aux(Criterio, Rs, R, V, Mejor, Valor).

mejor_aux(_, [], Mejor, Valor, Mejor, Valor).
mejor_aux(Criterio, [R | Rs], MejorAct, ValAct, Mejor, Valor) :-
    call(Criterio, R, V),
    (   V < ValAct
    ->  mejor_aux(Criterio, Rs, R, V, Mejor, Valor)
    ;   mejor_aux(Criterio, Rs, MejorAct, ValAct, Mejor, Valor)
    ).
