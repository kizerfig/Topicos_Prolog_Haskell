module Parser where

import Tipos
import System.IO

splitOn :: Char -> String -> [String]
splitOn delim str = case break (== delim) str of
    (elem, [])      -> [elem]
    (elem, _:resto) -> elem : splitOn delim resto

parsearDia :: String -> Dia
parsearDia "L"      = L
parsearDia "M"      = M
parsearDia "Mi"     = Mi
parsearDia "J"      = J
parsearDia "V"      = V
parsearDia "S"      = S
parsearDia "D"      = D
parsearDia "Diario" = Diario
parsearDia d        = error ("Dia desconocido: " ++ d)

parsearDias :: String -> [Dia]
parsearDias "Diario" = [Diario]
parsearDias str      = map parsearDia (splitOn '-' str)

parsearLinea :: String -> Vuelo
parsearLinea linea = case splitOn '|' linea of
    [orig, dest, salStr, llegStr, precStr, idV, diasStr] ->
        Vuelo
            { origen      = orig
            , destino     = dest
            , salida      = horaAMinutos salStr
            , llegada     = horaAMinutos llegStr
            , precio      = read precStr
            , codigoVuelo = idV
            , dias        = parsearDias diasStr
            }
    _ -> error "Formato de linea invalido"

cargarVuelos :: FilePath -> IO Grafo
cargarVuelos ruta = do
    contenido <- readFile ruta
    let lineas = filter (not . null) (lines contenido)
    return (map parsearLinea lineas)

vuelosSalenDe :: Ciudad -> Grafo -> [Vuelo]
vuelosSalenDe c grafo = filter (\v -> origen v == c) grafo

vuelosLleganA :: Ciudad -> Grafo -> [Vuelo]
vuelosLleganA c grafo = filter (\v -> destino v == c) grafo
