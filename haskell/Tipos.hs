module Tipos where

type Ciudad = String
type Minutos = Int
type Precio = Int
type CodigoVuelo = String
type TMC = Int

data Dia = L | M | Mi | J | V | S | D | Diario
    deriving (Show, Eq, Read)

data Vuelo = Vuelo
    { origen      :: Ciudad
    , destino     :: Ciudad
    , salida      :: Minutos
    , llegada     :: Minutos
    , precio      :: Precio
    , codigoVuelo :: CodigoVuelo
    , dias        :: [Dia]
    } deriving (Show, Eq)

type Grafo = [Vuelo]
type Ruta  = [Vuelo]

tmcPorDefecto :: TMC
tmcPorDefecto = 45

horaAMinutos :: String -> Minutos
horaAMinutos str =
    let (hhStr, resto) = break (== ':') str
        mmStr = drop 1 resto
        hh = read hhStr :: Int
        mm = read mmStr :: Int
    in hh * 60 + mm

minutosAHora :: Minutos -> String
minutosAHora mins =
    let hh = mins `div` 60
        mm = mins `mod` 60
        pad n = if n < 10 then '0' : show n else show n
    in pad hh ++ ":" ++ pad mm

