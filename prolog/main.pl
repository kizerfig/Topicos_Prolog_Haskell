:- ensure_loaded('parser.pl').

:- catch(ensure_loaded('rutas.pl'), _, true).
:- catch(ensure_loaded('optimizacion.pl'), _, true).

iniciar :-
    inicializar_sistema,
    bucle_menu.

menu :-
    iniciar.

inicializar_sistema :-
    (   vuelo(_, _, _, _, _, _, _)
    ->  true
    ;   catch(cargar_vuelos_defecto, _,
              format('~N[AVISO] Inicie cargando la base de datos de vuelos (Opcion 1).~n', []))
    ).

bucle_menu :-
    repeat,
    obtener_tmc(TMC),
    nl,
    writeln('===================================================================='),
    writeln('            LOGIEXPRESS - SISTEMA ANALITICO DE VUELOS               '),
    writeln('                       (Paradigma Logico)                           '),
    writeln('===================================================================='),
    format(' [Tiempo Minimo de Conexion (TMC) Global: ~w min]~n', [TMC]),
    writeln('--------------------------------------------------------------------'),
    writeln('  1. Cargar / Recargar base de datos (vuelos.txt)'),
    writeln('  2. Configurar Tiempo Minimo de Conexion (TMC)'),
    writeln('  3. Consultar vuelos que salen de una ciudad'),
    writeln('  4. Consultar vuelos que llegan a una ciudad'),
    writeln('  5. Buscar todas las rutas validas (Origen -> Destino)'),
    writeln('  6. Determinar Ruta de Costo Economico Minimo'),
    writeln('  7. Determinar Ruta de Menor Tiempo Total de Viaje'),
    writeln('  8. Reporte ordenado de itinerarios (por Costo o por Tiempo)'),
    writeln('  9. Salir del sistema'),
    writeln('===================================================================='),
    write('Seleccione una opcion [1-9]: '),
    leer_linea_texto(OpcionStr),
    ejecutar_opcion(OpcionStr),
    OpcionStr == "9", !.

ejecutar_opcion("1") :- !,
    nl,
    writeln('--- CARGA DE BASE DE DATOS DE VUELOS ---'),
    write('Ingrese la ruta del archivo [Enter para usar vuelos.txt por defecto]: '),
    leer_linea_texto(RutaStr),
    (   RutaStr == ""
    ->  catch(cargar_vuelos_defecto, Err, format('~N[ERROR] No se pudo cargar: ~w~n', [Err]))
    ;   atom_string(RutaAtom, RutaStr),
        catch(cargar_vuelos(RutaAtom), Err, format('~N[ERROR] No se pudo cargar: ~w~n', [Err]))
    ),
    pausar.

ejecutar_opcion("2") :- !,
    nl,
    writeln('--- CONFIGURACION DE TIEMPO MINIMO DE CONEXION (TMC) ---'),
    obtener_tmc(TMCActual),
    format('TMC actual: ~w minutos.~n', [TMCActual]),
    write('Ingrese nuevo TMC en minutos (ej. 45): '),
    leer_linea_texto(InputStr),
    (   number_string(NuevoTMC, InputStr), integer(NuevoTMC), NuevoTMC >= 0
    ->  establecer_tmc(NuevoTMC),
        format('~N[EXITO] TMC global actualizado a ~w minutos.~n', [NuevoTMC])
    ;   writeln('[ERROR] Valor invalido. Debe suministrar un numero entero no negativo.')
    ),
    pausar.

ejecutar_opcion("3") :- !,
    nl,
    writeln('--- VUELOS SALIENTES POR CIUDAD ---'),
    write('Ingrese nombre de la ciudad de origen (ej. Maiquetia, Pto Ordaz): '),
    leer_linea_texto(CiudadStr),
    (   CiudadStr == ""
    ->  writeln('[AVISO] No ingreso una ciudad.')
    ;   atom_string(Ciudad, CiudadStr),
        vuelos_salen_de(Ciudad, Vuelos),
        mostrar_tabla_vuelos(Vuelos, 'salen de', Ciudad)
    ),
    pausar.

ejecutar_opcion("4") :- !,
    nl,
    writeln('--- VUELOS ENTRANTES POR CIUDAD ---'),
    write('Ingrese nombre de la ciudad de destino (ej. Porlamar, Valencia): '),
    leer_linea_texto(CiudadStr),
    (   CiudadStr == ""
    ->  writeln('[AVISO] No ingreso una ciudad.')
    ;   atom_string(Ciudad, CiudadStr),
        vuelos_llegan_a(Ciudad, Vuelos),
        mostrar_tabla_vuelos(Vuelos, 'llegan a', Ciudad)
    ),
    pausar.

ejecutar_opcion("5") :- !,
    nl,
    writeln('--- BUSQUEDA AVANZADA DE RUTAS VALIDAS ---'),
    (   current_predicate(buscar_rutas/5)
    ->  capturar_parametros_busqueda(Origen, Destino, Dia, MaxEscalas),
        buscar_rutas(Origen, Destino, Dia, MaxEscalas, Rutas),
        length(Rutas, Total),
        format('~NSe encontraron ~w rutas validas de "~w" a "~w" para el dia ~w:~n',
               [Total, Origen, Destino, Dia]),
        mostrar_reporte_rutas(Rutas)
    ;   modulo_no_disponible('Modulo 2: Busqueda Avanzada de Rutas (rutas.pl)', 'Barbara Garcia')
    ),
    pausar.

ejecutar_opcion("6") :- !,
    nl,
    writeln('--- DETERMINACION DE RUTA DE COSTO MINIMO ---'),
    (   (current_predicate(buscar_rutas/5), current_predicate(mejor_ruta_costo/3))
    ->  capturar_parametros_busqueda(Origen, Destino, Dia, MaxEscalas),
        buscar_rutas(Origen, Destino, Dia, MaxEscalas, Rutas),
        (   Rutas == []
        ->  writeln('[AVISO] No se encontraron rutas validas con los criterios suministrados.')
        ;   mejor_ruta_costo(Rutas, MejorRuta, CostoMin),
            writeln('--------------------------------------------------------------------'),
            format('>>> RUTA OPTIMA EN COSTO ECONOMICO (Total: $~w) <<<~n', [CostoMin]),
            writeln('--------------------------------------------------------------------'),
            mostrar_detalle_ruta(1, MejorRuta)
        )
    ;   modulo_no_disponible('Modulo 3: Optimizacion de Costo (optimizacion.pl)', 'Eduardo Rivas')
    ),
    pausar.

ejecutar_opcion("7") :- !,
    nl,
    writeln('--- DETERMINACION DE RUTA DE MENOR TIEMPO DE VIAJE ---'),
    (   (current_predicate(buscar_rutas/5), current_predicate(mejor_ruta_tiempo/3))
    ->  capturar_parametros_busqueda(Origen, Destino, Dia, MaxEscalas),
        buscar_rutas(Origen, Destino, Dia, MaxEscalas, Rutas),
        (   Rutas == []
        ->  writeln('[AVISO] No se encontraron rutas validas con los criterios suministrados.')
        ;   mejor_ruta_tiempo(Rutas, MejorRuta, TiempoMin),
            Horas is TiempoMin // 60, Minutos is TiempoMin mod 60,
            writeln('--------------------------------------------------------------------'),
            format('>>> RUTA OPTIMA EN TIEMPO (Duracion: ~w min [~wh ~wm]) <<<~n', [TiempoMin, Horas, Minutos]),
            writeln('--------------------------------------------------------------------'),
            mostrar_detalle_ruta(1, MejorRuta)
        )
    ;   modulo_no_disponible('Modulo 3: Optimizacion de Tiempo (optimizacion.pl)', 'Eduardo Rivas')
    ),
    pausar.

ejecutar_opcion("8") :- !,
    nl,
    writeln('--- REPORTE ORDENADO DE ITINERARIOS ---'),
    (   (current_predicate(buscar_rutas/5),
         current_predicate(quicksort_por_costo/2),
         current_predicate(quicksort_por_tiempo/2))
    ->  capturar_parametros_busqueda(Origen, Destino, Dia, MaxEscalas),
        buscar_rutas(Origen, Destino, Dia, MaxEscalas, Rutas),
        (   Rutas == []
        ->  writeln('[AVISO] No se encontraron rutas validas.')
        ;   writeln('Seleccione el criterio de ordenamiento:'),
            writeln('  1. Ordenar por Costo Economico (Ascendente)'),
            writeln('  2. Ordenar por Tiempo Total de Viaje (Ascendente)'),
            write('Criterio [1-2]: '),
            leer_linea_texto(CritStr),
            (   CritStr == "1"
            ->  quicksort_por_costo(Rutas, Ordenadas),
                writeln('>>> ITINERARIOS ORDENADOS POR MENOR COSTO: <<<'),
                mostrar_reporte_rutas(Ordenadas)
            ;   CritStr == "2"
            ->  quicksort_por_tiempo(Rutas, Ordenadas),
                writeln('>>> ITINERARIOS ORDENADOS POR MENOR TIEMPO TOTAL: <<<'),
                mostrar_reporte_rutas(Ordenadas)
            ;   writeln('[ERROR] Criterio invalido.')
            )
        )
    ;   modulo_no_disponible('Modulo 3: Algoritmos de Ordenamiento (optimizacion.pl)', 'Eduardo Rivas')
    ),
    pausar.

ejecutar_opcion("9") :- !,
    nl,
    writeln('===================================================================='),
    writeln(' Gracias por utilizar LogiExpress. Finalizando sesion...           '),
    writeln('====================================================================').

ejecutar_opcion(_) :-
    writeln('[ERROR] Opcion no valida. Por favor ingrese un numero del 1 al 9.'),
    pausar.

modulo_no_disponible(NombreModulo, Responsable) :-
    writeln('--------------------------------------------------------------------'),
    format(' [EN DESARROLLO / PENDIENTE]~n', []),
    format(' La funcionalidad solicitada requiere el archivo:~n', []),
    format('  * ~w~n', [NombreModulo]),
    format('  * Asignado a: ~w~n', [Responsable]),
    writeln(' Cuando el archivo este en la carpeta, se activara automaticamente.'),
    writeln('--------------------------------------------------------------------').

capturar_parametros_busqueda(Origen, Destino, Dia, MaxEscalas) :-
    write('Ciudad de Origen: '),
    leer_linea_texto(OrigStr),
    atom_string(Origen, OrigStr),
    write('Ciudad de Destino: '),
    leer_linea_texto(DestStr),
    atom_string(Destino, DestStr),
    write('Dia de la semana (ej. Lunes, Martes o L, M, Mi, J, V, S, D): '),
    leer_linea_texto(DiaStr),
    atom_string(Dia, DiaStr),
    write('Maximo numero de escalas [Presione Enter para sin limite]: '),
    leer_linea_texto(EscStr),
    (   EscStr == ""
    ->  MaxEscalas = -1
    ;   (number_string(MaxEscalas, EscStr) -> true ; MaxEscalas = -1)
    ).

leer_linea_texto(TextoLimpio) :-
    read_line_to_string(user_input, Linea),
    (   Linea == end_of_file
    ->  TextoLimpio = "9"
    ;   normalize_space(string(TextoLimpio), Linea)
    ).

pausar :-
    nl,
    write('Presione Enter para continuar...'),
    read_line_to_string(user_input, _).

mostrar_tabla_vuelos([], Verbo, Ciudad) :-
    format('~NNo existen vuelos registrados que ~w "~w".~n', [Verbo, Ciudad]).
mostrar_tabla_vuelos(Vuelos, Verbo, Ciudad) :-
    length(Vuelos, Total),
    format('~NTotal de vuelos que ~w "~w": ~w~n', [Verbo, Ciudad, Total]),
    writeln('----------------------------------------------------------------------------------'),
    writeln(' Codigo |      Origen      |     Destino      | Salida | Llegada |  Precio | Dias'),
    writeln('----------------------------------------------------------------------------------'),
    forall(member(V, Vuelos), imprimir_fila_vuelo(V)),
    writeln('----------------------------------------------------------------------------------').

imprimir_fila_vuelo(vuelo(O, D, SMin, LMin, Precio, ID, Dias)) :-
    minutos_a_hora(SMin, SStr),
    minutos_a_hora(LMin, LStr),
    atomic_list_concat(Dias, '-', DiasAtom),
    format(' ~|~w~6+ | ~|~w~16+ | ~|~w~16+ | ~|~w~6+ | ~|~w~7+ | $~|~w~6+ | ~w~n',
           [ID, O, D, SStr, LStr, Precio, DiasAtom]).

mostrar_reporte_rutas([]) :-
    writeln('  (No se encontro ninguna ruta que cumpla los criterios)').
mostrar_reporte_rutas(Rutas) :-
    mostrar_reporte_rutas_aux(Rutas, 1).

mostrar_reporte_rutas_aux([], _).
mostrar_reporte_rutas_aux([Ruta | Resto], Indice) :-
    mostrar_detalle_ruta(Indice, Ruta),
    NuevoIndice is Indice + 1,
    mostrar_reporte_rutas_aux(Resto, NuevoIndice).

mostrar_detalle_ruta(Numero, Ruta) :-
    (   current_predicate(costo_total_ruta/2)
    ->  costo_total_ruta(Ruta, Costo)
    ;   Costo = 'N/D'
    ),
    (   current_predicate(tiempo_total_viaje/2)
    ->  tiempo_total_viaje(Ruta, DuracionMin),
        Horas is DuracionMin // 60, Minutos is DuracionMin mod 60,
        format(atom(DurStr), '~w min (~wh ~wm)', [DuracionMin, Horas, Minutos])
    ;   DurStr = 'N/D'
    ),
    length(Ruta, NumVuelos),
    Escalas is NumVuelos - 1,
    format('~N[Ruta #~w] Escalas: ~w | Costo Total: $~w | Tiempo Total: ~w~n',
           [Numero, Escalas, Costo, DurStr]),
    writeln('  Segmentos del Itinerario:'),
    imprimir_segmentos_ruta(Ruta, 1),
    writeln('--------------------------------------------------------------------').

imprimir_segmentos_ruta([], _).
imprimir_segmentos_ruta([Vuelo], Num) :- !,
    Vuelo = vuelo(Orig, Dest, SMin, LMin, Precio, ID, _),
    minutos_a_hora(SMin, SStr),
    minutos_a_hora(LMin, LStr),
    Dur is LMin - SMin,
    format('    (~w) [~w] ~w -> ~w | ~w - ~w (~w min) | $~w~n',
           [Num, ID, Orig, Dest, SStr, LStr, Dur, Precio]).
imprimir_segmentos_ruta([Vuelo1, Vuelo2 | Resto], Num) :-
    Vuelo1 = vuelo(Orig, Dest, SMin1, LMin1, Precio1, ID1, _),
    Vuelo2 = vuelo(_, _, SMin2, _, _, _, _),
    minutos_a_hora(SMin1, SStr1),
    minutos_a_hora(LMin1, LStr1),
    Dur1 is LMin1 - SMin1,
    Espera is SMin2 - LMin1,
    format('    (~w) [~w] ~w -> ~w | ~w - ~w (~w min) | $~w~n',
           [Num, ID1, Orig, Dest, SStr1, LStr1, Dur1, Precio1]),
    format('        * Conexion en ~w: espera de ~w minutos.~n', [Dest, Espera]),
    SiguienteNum is Num + 1,
    imprimir_segmentos_ruta([Vuelo2 | Resto], SiguienteNum).
