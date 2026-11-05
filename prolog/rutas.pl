% Modulo 2: Motor de Busqueda de Rutas con Restricciones

:- ensure_loaded('parser.pl').

% Auxiliar 1: Compatibilidad de Dia
%!  dia_compatible(+ListaDias, +DiaBuscado) -> Tiene exito si el vuelo opera el dia solicitado.

dia_compatible(['Diario'], _) :- !.
dia_compatible(ListaDias, Dia) :-
    member(Dia, ListaDias).

% dia_compatible(['Diario'], 'L')      -> Verdadero
% dia_compatible(['L','M','V'], 'L')   -> Verdadero
% dia_compatible(['L','M','V'], 'Mi')  -> Falso
