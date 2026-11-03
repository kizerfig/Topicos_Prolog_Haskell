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
