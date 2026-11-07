module Rutas where

import Tipos

--Modulo 2: Busqueda de rutas con restricciones de dia, TMC, ciclos y escalas

--Verifica si el vuelo opera el dia solicitado (Diario aplica siempre)
diaCompatible :: Dia -> Vuelo -> Bool
diaCompatible _   v | Diario `elem` dias v = True
diaCompatible dia v = dia `elem` dias v

--Validación de Escala: Verifica que Salida(V2) >= Llegada(V1) + TMC
cumpleTMC :: TMC -> Minutos -> Vuelo -> Bool
cumpleTMC tmc ultimaLlegada v = salida v >= ultimaLlegada + tmc


--Ciudades Acumuladas - DFS recursivo, acumula ciudades visitadas para evitar ciclos
--ultimaLlegada = 0 para el primer vuelo
dfs :: Grafo -> Ciudad -> Dia -> TMC -> Int -> [Ciudad] -> Minutos -> [Ruta]
dfs _ dst _ _ _ (actual:_) _ | actual == dst = [[]]
dfs _ _ _ _ 0 _ _            = []
dfs grafo dst dia tmc escalas (actual:visitados) ultimaLlegada =
    [ v : resto
    | v <- grafo
    , origen v == actual
    , destino v `notElem` (actual:visitados) || destino v == dst
    , diaCompatible dia v
    , cumpleTMC tmc ultimaLlegada v
    , resto <- dfs grafo dst dia tmc
                   (escalas - 1)
                   (destino v : actual : visitados)
                   (llegada v)
    ]
dfs _ _ _ _ _ [] _ = []

--Recolecta todas las rutas validas entre org y dst
--maxEscalas = Nothing para sin limite, Just k para maximo k escalas intermedias
buscarRutas :: Grafo -> Ciudad -> Ciudad -> Dia -> Maybe Int -> TMC -> [Ruta]
buscarRutas grafo org dst dia maxEscalas tmc =
    let limite = case maxEscalas of
                    Nothing -> length grafo
                    Just k  -> k + 1
    in dfs grafo dst dia tmc limite [org] 0
