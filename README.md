# Motor Analítico de Gestión de Vuelos e Itinerarios Interurbanos (LogiExpress)

**Asignatura:** Tópicos Especiales de Programación  
**Profesora:** Jannelly Bello  
**Institución / Cátedra:** Cátedra de Tópicos Especiales de Programación  

---

## 1. Descripción Ejecutiva del Proyecto

El **Motor Analítico LogiExpress** es una solución computacional avanzada diseñada para modelar, validar y optimizar redes de transporte aéreo e itinerarios interurbanos a escala nacional. El sistema procesa bases de conocimiento representadas como grafos dirigidos ponderados donde los nodos corresponden a ciudades/aeropuertos y las aristas a conexiones aéreas con atributos multidimensionales (horarios de salida y llegada en formato militar de 24 horas, costo monetario, identificador de vuelo y frecuencias semanales).

El núcleo del motor resuelve de manera exhaustiva el problema de determinación de rutas factibles evaluando de forma simultánea:
- **Restricciones de frecuencia y calendario:** Disponibilidad operativa de vuelos según días específicos de la semana (Lunes a Domingo o Diario).
- **Ventanas de conexión (TMC):** Validación rigurosa de tiempos de escala entre vuelos consecutivos ($V_1$ y $V_2$), garantizando que $\text{HoraSalida}(V_2) \ge \text{HoraLlegada}(V_1) + \text{TMC}$.
- **Control estricto de aciclicidad:** Poda de ramas y prevención de ciclos en el recorrido para evitar revisitar ciudades en un mismo itinerario.
- **Topes operacionales:** Filtro y delimitación de número máximo de escalas ($K$).
- **Optimización multicriterio:** Determinación de rutas de costo económico mínimo y rutas de menor tiempo total de viaje (incluyendo tiempos de vuelo y esperas en escala), apoyándose en algoritmos de ordenamiento sobre listas.

El proyecto está implementado obligatoriamente bajo dos paradigmas de programación complementarios:
1. **Paradigma Lógico (Prolog):** Basado en cláusulas de Horn, unificación, motor de resolución SLD, backtracking cronológico, acumuladores para detección de ciclos y meta-predicados de recopilación de soluciones (`findall/3`, `bagof/3`, `setof/3`).
2. **Paradigma Funcional (Haskell):** Basado en inmutabilidad de datos, evaluación perezosa (*lazy evaluation*), tipos algebraicos fuertemente tipados, funciones de alto orden (`map`, `filter`, `foldl`/`foldr`), *list comprehensions* y composición pura de funciones sobre estructuras de grafos inmutables.

---

## 2. Estructura del Repositorio

El proyecto mantiene una estructura modular y limpia conforme a las directrices de la cátedra:

```ascii
LogiExpressGrupoXX/
├── README.md              # Documentación central, estado del proyecto y asignación de tareas
├── vuelos.txt             # Base de datos plana delimitada por '|' con la información de vuelos
├── .gitignore             # Exclusión de binarios y artefactos intermedios (.o, .hi, etc.)
├── /haskell               # Solución en Paradigma Funcional (Módulo Main + CLI interactivo)
│   ├── Main.hs            # Punto de entrada y menú de consola interactivo
│   ├── Tipos.hs           # Definición de tipos de datos algebraicos (Vuelo, Grafo, Ruta)
│   ├── Parser.hs          # Lectura y parseo del archivo vuelos.txt (I/O)
│   ├── Rutas.hs           # Algoritmos de búsqueda DFS, restricciones y filtros
│   └── Optimizacion.hs    # Algoritmos de ordenamiento y selección de rutas óptimas
├── /prolog                # Solución en Paradigma Lógico (Módulo Main + CLI interactivo)
│   ├── main.pl            # Punto de entrada y menú de consola interactivo
│   ├── parser.pl          # Carga dinámica y aserción de hechos en la base de conocimientos
│   ├── rutas.pl           # Motor de búsqueda de rutas con backtracking y control de ciclos
│   └── optimizacion.pl    # Predicados de ordenamiento (quicksort/mergesort) y cálculo de óptimos
└── /docs                  # Documentación académica formal
    └── Informe_Tecnico_Comparativo.pdf  # Informe Técnico Comparativo (8 a 10 páginas)
```

---

## 3. Requisitos de Entorno e Instalación

Para compilar y ejecutar ambas implementaciones se requieren las siguientes herramientas:

### 3.1. Paradigma Lógico: SWI-Prolog
- **Versión recomendada:** SWI-Prolog v8.4.x o v9.x en adelante.
- **Verificación de instalación:**
  ```bash
  swipl --version
  ```
- **Descarga:** [https://www.swi-prolog.org/download/stable](https://www.swi-prolog.org/download/stable)

### 3.2. Paradigma Funcional: Glasgow Haskell Compiler (GHC / Cabal / Stack)
- **Versión recomendada:** GHC 9.2.x o superior con la herramienta interactiva `ghci`.
- **Verificación de instalación:**
  ```bash
  ghc --version
  ghci --version
  ```
- **Instalación recomendada:** Vía [GHCup](https://www.haskell.org/ghcup/).

---

## 4. Instrucciones de Compilación y Ejecución

Ambas soluciones proveen un **Menú Interactivo en Consola (CLI)** que guía al usuario en la ejecución de cada consulta y algoritmo analítico.

### 4.1. Ejecución en Prolog (Paradigma Lógico)

1. Abrir la terminal y posicionarse dentro de `/prolog`:
   ```bash
   cd prolog
   ```
2. Iniciar la sesión interactiva de SWI-Prolog cargando el archivo principal:
   ```bash
   swipl main.pl
   ```
3. Ejecutar el predicado principal para iniciar el menú:
   ```prolog
   ?- iniciar.
   % O alternativamente:
   ?- menu.
   ```
4. *(Opcional)* Ejecución directa en una sola línea desde la terminal:
   ```bash
   swipl -s main.pl -g iniciar -t halt
   ```

### 4.2. Ejecución en Haskell (Paradigma Funcional)

#### Modo Interactivo (GHCi)
1. Posicionarse en el directorio `/haskell`:
   ```bash
   cd haskell
   ```
2. Cargar el entorno interactivo:
   ```bash
   ghci Main.hs
   ```
3. Invocar la función principal:
   ```haskell
   ghci> main
   ```

#### Modo Compilado (Binario)
1. Compilar el ejecutable optimizado con GHC:
   ```bash
   cd haskell
   ghc -O2 --make Main.hs -o LogiExpressCLI
   ```
2. Ejecutar el binario generado:
   - **En Linux / macOS:** `./LogiExpressCLI`
   - **En Windows:** `.\LogiExpressCLI.exe`

---

## 5. Resumen de Módulos Funcionales

| Módulo | Denominación | Funcionalidades Principales | Desafíos Técnicos Implementados |
| :---: | :--- | :--- | :--- |
| **Módulo 1** | **Carga Dinámica, Configuración TMC y Consultas Básicas** | • Lectura y parseo del archivo `vuelos.txt` (delimitado por `\|`).<br>• Asignación global de la ventana TMC en minutos (ej. 45 min).<br>• Consultas elementales de partidas y llegadas por ciudad $C$. | • **Prolog:** Aserción dinámica de hechos (`assertz/1`), manipulación de streams y conversión de cadenas de hora `HH:MM` a minutos absolutos.<br>• **Haskell:** Modelado de tipos algebraicos de datos (`data Vuelo`, `type Grafo`), manejo de I/O puro/impuro y procesamiento de texto con `lines` y `splitOn`. |
| **Módulo 2** | **Búsqueda Avanzada de Rutas con Restricciones** | • Generación de rutas directas y con escalas entre Ciudad Origen y Ciudad Destino.<br>• Validación de compatibilidad con el día de la semana solicitado.<br>• Verificación de conexión: $\text{HoraSalida}(V_2) \ge \text{HoraLlegada}(V_1) + \text{TMC}$.<br>• Prevención de ciclos en el itinerario.<br>• Acotamiento opcional de escalas máximas ($K$). | • **Prolog:** Algoritmo DFS mediante reglas recursivas de backtracking, listas acumuladoras `[Cabeza\|Cola]` para nodos visitados y meta-predicados de recolección (`findall/3`, `setof/3`).<br>• **Haskell:** Algoritmo recursivo sobre grafos inmutables, *list comprehensions*, funciones de alto orden (`filter`, `foldr`) y composición modular de predicados de validación. |
| **Módulo 3** | **Optimización y Filtrado de Itinerarios** | • **Ruta de Costo Mínimo:** Selección del itinerario con la menor suma de tarifas de boletos.<br>• **Ruta de Menor Tiempo Total:** Selección de la ruta con la menor duración integral (diferencia entre hora de llegada a destino y salida de origen, sumando esperas en tránsito).<br>• Reporte consolidado y ordenamiento de itinerarios por costo o duración. | • **Prolog:** Implementación nativa de algoritmos de ordenamiento sobre listas (`quicksort/3` o `mergesort/3`) y agregaciones aritméticas.<br>• **Haskell:** Algoritmo de ordenamiento funcional, reducción (`foldl'`), funciones lambda de comparación y selección de óptimos. |

---

## 6. Formato de la Base de Conocimiento (`vuelos.txt`)

Los vuelos se encuentran almacenados en texto plano utilizando el carácter `|` como delimitador de campos:
```text
Origen|Destino|HoraSalida|HoraLlegada|Precio|IDVuelo|Frecuencia
```

### Ejemplo de Registros:
```text
Pto Ordaz|Maiquetia|07:00|08:00|5600|Vlo#1|Diario
Maiquetia|Porlamar|09:00|10:00|4800|Vlo#2|L-M-Mi-J-V
Maiquetia|Pto Ordaz|15:00|16:00|5300|Vlo#3|L-M-V
Pto Ordaz|Maracaibo|13:00|15:00|9000|Vlo#4|Diario
Valencia|Porlamar|17:00|18:00|4300|Vlo#9|L-S-D
```

- **Horarios:** Formato militar de 24 horas (`HH:MM`).
- **Días:** Codificación de frecuencias: `L` (Lunes), `M` (Martes), `Mi` (Miércoles), `J` (Jueves), `V` (Viernes), `S` (Sábado), `D` (Domingo) o `Diario`.

---

## 7. Integrantes del Equipo y Estado de Responsabilidades

| Integrante | Rol y Módulo Asignado | Estado General |
| :--- | :--- | :---: |
| **Kizer Ellioth** | **Módulo 1:** Carga, Parseo, TMC y Consultas Básicas + Menú CLI | `Completado` (Prolog y Haskell base) |
| **Garcia Barbara** | **Módulo 2:** Motor de Búsqueda Avanzada de Rutas y Restricciones | `Pendiente` (Por iniciar) |
| **Rivas Eduardo** | **Módulo 3:** Optimización, Ordenamiento e Informe Técnico | `En progreso` (Prolog completado; Haskell e Informe pendientes) |

---

## 8. Estado Actual del Desarrollo (Lo que llevamos implementado)

### 8.1. Implementado en Prolog (Paradigma Lógico)
- **`prolog/parser.pl` (Kizer Ellioth):**
  - Declaración y manejo de hechos dinámicos `vuelo/7` y `tmc_config/1`.
  - Conversión bidireccional entre horas militares `HH:MM` y minutos absolutos del día (`hora_a_minutos/2`, `minutos_a_hora/2`).
  - Configuración y consulta global del TMC (`obtener_tmc/1`, `establecer_tmc/1`).
  - Carga dinámica desde archivo delimitado por `|` (`cargar_vuelos/1`, `cargar_vuelos_defecto/0`).
  - Consultas de salidas (`vuelos_salen_de/2`) y llegadas (`vuelos_llegan_a/2`) mediante `findall/3`.
- **`prolog/main.pl` (Kizer Ellioth):**
  - Menú interactivo CLI con 9 opciones y puntos de entrada oficiales `iniciar/0` y `menu/0`.
  - Opciones 1, 2, 3 y 4 completamente funcionales y vinculadas a `parser.pl`.
  - Arquitectura desacoplada: opciones 5 a 8 preparadas con detección dinámica de `rutas.pl` y `optimizacion.pl`.
- **`prolog/optimizacion.pl` (Rivas Eduardo):**
  - Métricas de ruta: `costo_total_ruta/2` (suma recursiva con acumulador) y `tiempo_total_viaje/2` (llegada del último vuelo − salida del primero, incluye esperas en escala).
  - **Quicksort** propio sobre listas de rutas, sin funciones de ordenamiento de la librería (`quicksort_por_costo/2`, `quicksort_por_tiempo/2`); ascendente y estable.
  - Selección de óptimos con acumulador: `mejor_ruta_costo/3` y `mejor_ruta_tiempo/3` (en empate conserva la primera ruta encontrada).
  - Probado con rutas armadas a mano sobre `vuelos.txt`. Las opciones 6, 7 y 8 del menú se activarán cuando `rutas.pl` (Módulo 2) esté disponible.

### 8.2. Implementado en Haskell (Paradigma Funcional)
- **`haskell/Tipos.hs` (Kizer Ellioth):**
  - Tipos algebraicos `Dia` (`L | M | Mi | J | V | S | D | Diario`) y `Vuelo` (con *record syntax*).
  - Sinónimos de tipos: `Ciudad`, `Minutos`, `Precio`, `CodigoVuelo`, `TMC`, `Grafo`, `Ruta`.
  - Funciones puras de tiempo: `horaAMinutos`, `minutosAHora` y constante `tmcPorDefecto = 45`.
- **`haskell/Parser.hs` (Kizer Ellioth):**
  - Algoritmo puro de tokenización `splitOn :: Char -> String -> [String]`.
  - Parseo funcional de líneas y frecuencias a tipos algebraicos (`parsearLinea`, `parsearDias`, `parsearDia`).
  - Carga con I/O impuro a estructura de grafo inmutable (`cargarVuelos :: FilePath -> IO Grafo`).
  - Consultas sobre listas mediante funciones de orden superior: `vuelosSalenDe` y `vuelosLleganA`.

---

## 9. Hoja de Ruta: Lo que falta por terminar por cada integrante

### 🔹 Para Bárbara García (Módulo 2: Motor de Rutas y Restricciones)

#### 1. En Prolog (`prolog/rutas.pl`):
- Crear `prolog/rutas.pl` e importar `parser.pl` (`:- ensure_loaded('parser.pl').`).
- Implementar el predicado principal:
  ```prolog
  buscar_rutas(+Origen, +Destino, +Dia, +MaxEscalas, -TodasLasRutas).
  ```
- Diseñar la búsqueda recursiva DFS con backtracking y recolección con `findall/3`.
- Cumplir las 4 restricciones simultáneas:
  1. **Compatibilidad de día:** Validar si el vuelo opera el día solicitado o es `Diario`.
  2. **Ventana de conexión temporal:** Para dos vuelos consecutivos $V_1$ y $V_2$, verificar $\text{Salida}(V_2) \ge \text{Llegada}(V_1) + \text{TMC}$.
  3. **Control de ciclos (Aciclicidad):** Acumulador de ciudades visitadas para no repetir ciudades en una ruta.
  4. **Límite de escalas:** Si $K \ge 0$, no superar $K$ escalas intermedias (longitud de ruta $\le K + 1$).

#### 2. En Haskell (`haskell/Rutas.hs`):
- Crear `haskell/Rutas.hs` importando `Tipos`.
- Implementar la función de búsqueda recursiva sobre grafos inmutables:
  ```haskell
  buscarRutas :: Grafo -> Ciudad -> Ciudad -> Dia -> Maybe Int -> TMC -> [Ruta]
  ```
- Utilizar *list comprehensions*, funciones de orden superior (`filter`, `foldr`) y prevención de ciclos en el camino acumulado.

---

### 🔹 Para Eduardo Rivas (Módulo 3: Optimización, Ordenamiento e Informe)

#### 1. En Prolog (`prolog/optimizacion.pl`):
- Pendiente: prueba de integración final con `rutas.pl` desde el menú (opciones 5 a 8) cuando el Módulo 2 esté listo.

#### 2. En Haskell (`haskell/Optimizacion.hs`):
- Crear `haskell/Optimizacion.hs` importando `Tipos`.
- Funciones puras de cálculo: `costoTotalRuta :: Ruta -> Precio` y `tiempoTotalViaje :: Ruta -> Minutos`.
- Implementación de ordenamiento funcional de listas de rutas por costo y tiempo.
- Funciones de óptimos: `mejorRutaCosto` y `mejorRutaTiempo`.

#### 3. Informe Técnico Comparativo (`/docs/Informe_Tecnico_Comparativo.pdf`):
- Elaborar documento académico formal (8 a 10 páginas) con:
  - Portada, Introducción y Modelado de Datos.
  - Funciones y predicados investigados en ambos paradigmas.
  - Análisis comparativo: **Evaluación perezosa / Inmutabilidad (Haskell)** frente a **Unificación / Backtracking (Prolog)**.
  - Resumen de actividades por integrante (coincidente con los commits).
  - Capturas de ejecución en consola y conclusiones.

---

### 🔹 Integración Final y Cierre (Todo el Equipo)
- **`haskell/Main.hs`:** Completar el menú interactivo en consola CLI conectando `Parser.hs`, `Rutas.hs` y `Optimizacion.hs`.
- **Auditoría Git:** Verificar que los 3 integrantes cuenten con commits significativos y descriptivos.
- **Tag Final:** Congelamiento de rama `main` y emisión de etiqueta `v1.0-final` antes de la fecha límite (08/11/2026).
