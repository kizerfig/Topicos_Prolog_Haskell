% ============================================================================
% Modulo 1: Parser, Carga Dinamica y Consultas Basicas (parser.pl)
% LogiExpress - Paradigma Logico (SWI-Prolog)
% ============================================================================

% Declaracion de hechos dinamicos en la base de conocimientos
:- dynamic vuelo/7.
% vuelo(Origen, Destino, SalidaMinutos, LlegadaMinutos, Precio, CodigoVuelo, ListaDias)

:- dynamic tmc_config/1.
% tmc_config(Minutos) - Tiempo Minimo de Conexion global (por defecto: 45 min)
tmc_config(45).

% ----------------------------------------------------------------------------
% Gestion del Tiempo Minimo de Conexion (TMC)
% ----------------------------------------------------------------------------

%!  obtener_tmc(-Minutos)
%   Obtiene el valor actual configurado para el TMC.
obtener_tmc(Minutos) :-
    tmc_config(Minutos), !.
obtener_tmc(45).

%!  establecer_tmc(+Minutos)
%   Actualiza el TMC global en la base de conocimientos.
establecer_tmc(Minutos) :-
    integer(Minutos),
    Minutos >= 0,
    retractall(tmc_config(_)),
    assertz(tmc_config(Minutos)).

% ----------------------------------------------------------------------------
% Utilidades de Tiempo: Conversion HH:MM a Minutos y viceversa
% ----------------------------------------------------------------------------

%!  hora_a_minutos(+StringHora, -MinutosTotales)
%   Convierte una representacion 'HH:MM' a minutos desde el inicio del dia (00:00).
hora_a_minutos(HoraStr, MinutosTotales) :-
    atom_string(HoraAtom, HoraStr),
    atomic_list_concat([HHStr, MMStr], ':', HoraAtom),
    atom_number(HHStr, HH),
    atom_number(MMStr, MM),
    HH >= 0, HH =< 23,
    MM >= 0, MM =< 59,
    MinutosTotales is (HH * 60) + MM.

%!  minutos_a_hora(+MinutosTotales, -StringHora)
%   Convierte minutos desde el inicio del dia a formato militar 'HH:MM'.
minutos_a_hora(MinutosTotales, HoraStr) :-
    HH is MinutosTotales // 60,
    MM is MinutosTotales mod 60,
    format(atom(HoraStr), '~|~`0t~d~2+:~|~`0t~d~2+', [HH, MM]).

% ----------------------------------------------------------------------------
% Parseo y Carga Dinamica desde Archivo Plano (vuelos.txt)
% ----------------------------------------------------------------------------

%!  cargar_vuelos_defecto
%   Intenta cargar vuelos.txt desde la ruta relativa esperada (../vuelos.txt o vuelos.txt).
cargar_vuelos_defecto :-
    (   exists_file('../vuelos.txt')
    ->  cargar_vuelos('../vuelos.txt')
    ;   exists_file('vuelos.txt')
    ->  cargar_vuelos('vuelos.txt')
    ;   throw(error(archivo_no_encontrado, 'No se encontro el archivo vuelos.txt'))
    ).

%!  cargar_vuelos(+RutaArchivo)
%   Lee el archivo delimitado por '|' e inserta los hechos vuelo/7 en la BD.
cargar_vuelos(RutaArchivo) :-
    retractall(vuelo(_, _, _, _, _, _, _)),
    open(RutaArchivo, read, Stream, [encoding(utf8)]),
    leer_lineas(Stream, 0, TotalCargados),
    close(Stream),
    format('~N[OK] Base de datos cargada exitosamente: ~w vuelos registrados.~n', [TotalCargados]).

%!  leer_lineas(+Stream, +ContadorActual, -Total)
%   Lee iterativamente las lineas del stream hasta EOF.
leer_lineas(Stream, Acc, Total) :-
    read_line_to_string(Stream, Linea),
    (   Linea == end_of_file
    ->  Total = Acc
    ;   normalize_space(string(Limpia), Linea),
        (   Limpia = ""
        ->  leer_lineas(Stream, Acc, Total)
        ;   procesar_linea(Limpia),
            NuevoAcc is Acc + 1,
            leer_lineas(Stream, NuevoAcc, Total)
        )
    ).

%!  procesar_linea(+LineaString)
%   Parsea una linea con formato: Origen|Destino|Salida|Llegada|Precio|ID|Dias
procesar_linea(LineaString) :-
    split_string(LineaString, "|", " \t\r\n", Partes),
    Partes = [OrigStr, DestStr, SalidaStr, LlegadaStr, PrecioStr, IdStr, DiasStr],
    atom_string(Origen, OrigStr),
    atom_string(Destino, DestStr),
    hora_a_minutos(SalidaStr, SalidaMin),
    hora_a_minutos(LlegadaStr, LlegadaMin),
    number_string(Precio, PrecioStr),
    atom_string(IDVuelo, IdStr),
    parsear_dias(DiasStr, ListaDias),
    assertz(vuelo(Origen, Destino, SalidaMin, LlegadaMin, Precio, IDVuelo, ListaDias)).

%!  parsear_dias(+DiasStr, -ListaDias)
%   Descompone la especificacion de dias en una lista de atomos.
%   Ej: "Diario" -> ['Diario'], "L-M-Mi-J-V" -> ['L', 'M', 'Mi', 'J', 'V']
parsear_dias("Diario", ['Diario']) :- !.
parsear_dias(DiasStr, ListaDias) :-
    split_string(DiasStr, "-", " \t\r\n", Tokens),
    maplist(atom_string, ListaDias, Tokens).

% ----------------------------------------------------------------------------
% Consultas Basicas de Partidas y Llegadas
% ----------------------------------------------------------------------------

%!  vuelos_salen_de(+Ciudad, -ListaVuelos)
%   Retorna todos los vuelos que tienen como origen a Ciudad.
vuelos_salen_de(Ciudad, ListaVuelos) :-
    findall(
        vuelo(Ciudad, Destino, Salida, Llegada, Precio, ID, Dias),
        vuelo(Ciudad, Destino, Salida, Llegada, Precio, ID, Dias),
        ListaVuelos
    ).

%!  vuelos_llegan_a(+Ciudad, -ListaVuelos)
%   Retorna todos los vuelos que tienen como destino a Ciudad.
vuelos_llegan_a(Ciudad, ListaVuelos) :-
    findall(
        vuelo(Origen, Ciudad, Salida, Llegada, Precio, ID, Dias),
        vuelo(Origen, Ciudad, Salida, Llegada, Precio, ID, Dias),
        ListaVuelos
    ).
