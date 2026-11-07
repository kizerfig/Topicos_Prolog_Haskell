module Main where

import Tipos
import Parser (cargarVuelos)
import Rutas  (buscarRutas)

--Modulo 2: Integracion de busqueda de rutas con Main
--Pendiente: menu CLI por Kizer, Optimizacion.hs por Eduardo

--Formatea un vuelo individual para mostrar en consola
mostrarVuelo :: Vuelo -> String
mostrarVuelo v =
    "  " ++ codigoVuelo v
    ++ "  " ++ origen v ++ " -> " ++ destino v
    ++ "  Salida: " ++ minutosAHora (salida v)
    ++ "  Llegada: " ++ minutosAHora (llegada v)
    ++ "  $" ++ show (precio v)

--Imprime todas las rutas encontradas con su numero
mostrarRutas :: [Ruta] -> IO ()
mostrarRutas [] = putStrLn "No se encontraron rutas con esas restricciones."
mostrarRutas rutas = do
    putStrLn $ "Se encontraron " ++ show (length rutas) ++ " ruta(s):\n"
    mapM_ (\(i, r) -> do
        putStrLn $ "--- Ruta " ++ show i ++ " ---"
        mapM_ (putStrLn . mostrarVuelo) r
        ) (zip [1..] rutas)

--Carga el grafo y ejecuta buscarRutas con los parametros dados
ejecutarBusqueda :: FilePath -> Ciudad -> Ciudad -> Dia -> Maybe Int -> TMC -> IO ()
ejecutarBusqueda archivo org dst dia maxEscalas tmc = do
    grafo <- cargarVuelos archivo
    let rutas = buscarRutas grafo org dst dia maxEscalas tmc
    mostrarRutas rutas

main :: IO ()
main = do
    grafo <- cargarVuelos "../vuelos.txt"
    putStrLn "=== LogiExpress - Prueba Modulo 2: Busqueda de Rutas ===\n"
    -- Ejemplo: Pto Ordaz -> Porlamar, Lunes, max 3 escalas, TMC 45 min
    ejecutarBusqueda grafo "Pto Ordaz" "Porlamar" L (Just 3) tmcPorDefecto
