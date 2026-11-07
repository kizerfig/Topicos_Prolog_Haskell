# Motor Analítico de Gestión de Vuelos e Itinerarios Interurbanos (LogiExpress)

**Asignatura:** Tópicos Especiales de Programación  
**Profesora:** Jannelly Bello  
**Institución / Cátedra:** Tópicos Especiales de Programación  

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
LogiExpress-Grupo4/
├── README.md              # Documentación central, estado del proyecto y asignación de tareas
├── vuelos.txt             # Base de datos plana delimitada por '|' con la información de vuelos
├── .gitignore             # Exclusión de binarios y artefactos intermedios (.o, .hi, etc.)
├── /haskell               # Solución en Paradigma Funcional (Módulo Main + CLI interactivo)
│   ├── Main.hs            # Punto de entrada y menú de consola interactivo
│   ├── Tipos.hs           # Definición de tipos de datos algebraicos (Vuelo, Grafo, Ruta)
│   ├── Parser.hs          # Lectura y parseo del archivo vuelos.txt (I/O)
│   ├── Rutas.hs           # Algoritmos de búsqueda DFS, restricciones y filtros (Módulo 2)
│   └── Optimizacion.hs    # Algoritmos de ordenamiento y selección de rutas óptimas (Módulo 3)
├── /prolog                # Solución en Paradigma Lógico (Módulo Main + CLI interactivo)
│   ├── main.pl            # Punto de entrada y menú de consola interactivo
│   ├── parser.pl          # Carga dinámica y aserción de hechos en la base de conocimientos (Módulo 1)
│   ├── rutas.pl           # Motor de búsqueda de rutas con backtracking y control de ciclos (Módulo 2)
│   └── optimizacion.pl    # Predicados de ordenamiento (quicksort) y cálculo de óptimos (Módulo 3)
└── /docs                  # Documentación académica formal
    └── Informe_Tecnico_Comparativo.pdf  # Informe Técnico Comparativo
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
- **Descarga oficial:** [https://www.swi-prolog.org/download/stable](https://www.swi-prolog.org/download/stable)

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

Ambas soluciones proveen interfaces de consola ejecutables desde la terminal:

### 4.1. Ejecución en Prolog (Paradigma Lógico)

1. Posicionarse dentro de la carpeta `/prolog`:
   ```bash
   cd prolog
   ```
2. Iniciar la sesión de SWI-Prolog con el archivo principal:
   ```bash
   swipl main.pl
   ```
3. Ejecutar el predicado de inicio:
   ```prolog
   ?- iniciar.
   ```
   *(También se puede invocar con `?- menu.`)*

4. **Ejecución directa en una sola línea desde la terminal:**
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
   ghci main.hs
   ```
3. Invocar la función principal:
   ```haskell
   ghci> main
   ```

#### Modo Compilado (Binario Optimizado)
1. Compilar el ejecutable con GHC:
   ```bash
   cd haskell
   ghc -O2 --make main.hs -o LogiExpressCLI
   ```
2. Ejecutar el binario generado:
   - **En Windows:** `.\LogiExpressCLI.exe`
   - **En Linux / macOS:** `./LogiExpressCLI`

---

## 5. Resumen de Módulos Funcionales

| Módulo | Denominación | Funcionalidades Principales | Desafíos Técnicos Implementados |
| :---: | :--- | :--- | :--- |
| **Módulo 1** | **Carga Dinámica, Configuración TMC y Consultas Básicas** | • Lectura y parseo del archivo `vuelos.txt` (delimitado por `\|`).<br>• Asignación global de la ventana TMC en minutos (ej. 45 min).<br>• Consultas elementales de partidas y llegadas por ciudad. | • **Prolog:** Aserción dinámica de hechos (`assertz/1`), manipulación de streams y conversión de horas `HH:MM` a minutos absolutos.<br>• **Haskell:** Modelado de tipos algebraicos (`data Vuelo`, `type Grafo`), I/O puro/impuro y procesamiento funcional de cadenas. |
| **Módulo 2** | **Búsqueda Avanzada de Rutas con Restricciones** | • Generación de rutas directas y con escalas (Origen $\rightarrow$ Destino).<br>• Compatibilidad con el día solicitado o vuelos diarios.<br>• Validación de conexión: $\text{Salida}(V_2) \ge \text{Llegada}(V_1) + \text{TMC}$.<br>• Control estricto de aciclicidad (sin repetir ciudades).<br>• Límite opcional de escalas intermedias ($K$). | • **Prolog:** Algoritmo DFS recursivo con backtracking, listas acumuladoras `[Cabeza\|Cola]` para visitados y meta-predicado `findall/3`.<br>• **Haskell:** DFS sobre grafos inmutables, *list comprehensions*, funciones de alto orden (`filter`, `foldr`) y composición modular de predicados puros. |
| **Módulo 3** | **Optimización y Filtrado de Itinerarios** | • **Ruta de Costo Mínimo:** Selección de la ruta con la menor suma de boletos.<br>• **Ruta de Menor Tiempo Total:** Selección de la ruta con menor duración total (llegada final menos salida inicial, incluyendo esperas).<br>• Reporte consolidado y ordenamiento de itinerarios. | • **Prolog:** Implementación nativa y recursiva de Quicksort puro sobre listas de rutas, sin librerías externas.<br>• **Haskell:** Quicksort funcional, funciones de agregación y ordenamiento ascendente por métricas. |

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
| **Kizer Ellioth** | **Módulo 1:** Carga, Parseo, TMC y Consultas Básicas + Menú CLI Base | `Completado` ✅ |
| **Garcia Barbara** | **Módulo 2:** Motor de Búsqueda Avanzada de Rutas y Restricciones | `Completado` ✅ |
| **Rivas Eduardo** | **Módulo 3:** Optimización, Ordenamiento e Informe Técnico | `En progreso` ⏳ |

---

## 8. Estado Actual del Desarrollo (Implementado en el Repositorio)

### 8.1. Implementado en Prolog (Paradigma Lógico)

- **`prolog/parser.pl` (Kizer Ellioth - Módulo 1):**
  - Hechos dinámicos `vuelo/7` y `tmc_config/1`.
  - Conversión bidireccional entre horas `HH:MM` y minutos absolutos (`hora_a_minutos/2`, `minutos_a_hora/2`).
  - Configuración y consulta global del TMC (`obtener_tmc/1`, `establecer_tmc/1`).
  - Carga dinámica desde archivo con delimitador `|` (`cargar_vuelos/1`, `cargar_vuelos_defecto/0`).
  - Consultas elementales de salidas (`vuelos_salen_de/2`) y llegadas (`vuelos_llegan_a/2`).

- **`prolog/rutas.pl` (Garcia Barbara - Módulo 2):**
  - Validación de frecuencias y días (`dia_compatible/2`) para días específicos y vuelos diarios.
  - Validación rigurosa de ventana temporal de conexión TMC (`cumple_tmc/3`).
  - Motor recursivo de búsqueda DFS con acumulador de visitados para aciclicidad y decremento de escalas (`buscar_ruta_dfs/8`).
  - Predicado público `buscar_rutas/5` con recopilación exhaustiva vía `findall/3` y soporte de escalas ilimitadas (`MaxEscalas = -1`).
  - Integrado y probado con `main.pl` (opción 5 del menú) y habilitando el cálculo de métricas en opciones 6, 7 y 8.

- **`prolog/optimizacion.pl` (Rivas Eduardo - Módulo 3):**
  - Métricas de ruta: `costo_total_ruta/2` y `tiempo_total_viaje/2` (diferencia llegada final y salida inicial).
  - Implementación recursiva de **Quicksort puro** sobre listas de rutas (`quicksort_por_costo/2`, `quicksort_por_tiempo/2`).
  - Selección de óptimos: `mejor_ruta_costo/3` y `mejor_ruta_tiempo/3`.
  - Integración completada con `rutas.pl`: opciones 6, 7 y 8 operativas en consola.

- **`prolog/main.pl` (Kizer Ellioth - CLI):**
  - Menú interactivo CLI con 9 opciones y puntos de entrada `iniciar/0` y `menu/0`.
  - Formateo detallado de itinerarios y reportes de conexiones intermedias con tiempos de espera.

---

### 8.2. Implementado en Haskell (Paradigma Funcional)

- **`haskell/Tipos.hs` (Kizer Ellioth - Módulo 1):**
  - Tipos algebraicos `Dia` (`L | M | Mi | J | V | S | D | Diario`) y registro `Vuelo` (*record syntax*).
  - Sinónimos de tipos: `Ciudad`, `Minutos`, `Precio`, `CodigoVuelo`, `TMC`, `Grafo`, `Ruta`.
  - Funciones puras de tiempo: `horaAMinutos`, `minutosAHora` y constante `tmcPorDefecto = 45`.

- **`haskell/Parser.hs` (Kizer Ellioth - Módulo 1):**
  - Algoritmo puro de tokenización `splitOn :: Char -> String -> [String]`.
  - Parseo funcional de líneas y frecuencias a tipos algebraicos (`parsearLinea`, `parsearDias`, `parsearDia`).
  - Carga con I/O a estructura inmutable (`cargarVuelos :: FilePath -> IO Grafo`).
  - Consultas sobre listas con funciones de orden superior: `vuelosSalenDe` y `vuelosLleganA`.

- **`haskell/Rutas.hs` (Garcia Barbara - Módulo 2):**
  - Verificación funcional de calendario de vuelo (`diaCompatible :: Dia -> Vuelo -> Bool`).
  - Validación pura de ventana temporal TMC (`cumpleTMC :: TMC -> Minutos -> Vuelo -> Bool`).
  - Algoritmo DFS funcional sobre grafos inmutables con *list comprehensions*, prevención de ciclos y límite de saltos (`dfs`).
  - Función pública exportada: `buscarRutas :: Grafo -> Ciudad -> Ciudad -> Dia -> Maybe Int -> TMC -> [Ruta]`.

- **`haskell/main.hs` (Integración de Módulo 2):**
  - Funciones de presentación: `mostrarVuelo` y `mostrarRutas`.
  - Función de ejecución pura de búsqueda: `ejecutarBusqueda`.
  - Punto de entrada ejecutable `main` validado y compilado exitosamente con GHC (`LogiExpressCLI.exe`).

---

## 9. Hoja de Ruta y Próximos Pasos

### Barbara Garcia (Módulo 2: Motor de Rutas y Restricciones) — COMPLETADO
- **Prolog (`prolog/rutas.pl`):**  Completado
- **Haskell (`haskell/Rutas.hs`):**  Completado
- **Pendientes:** Ninguno.

---

### Eduardo Rivas (Módulo 3: Optimización, Ordenamiento e Informe) — EN PROGRESO
- **Prolog (`prolog/optimizacion.pl`):**  Implementado y probado con `rutas.pl`.
- **Haskell (`haskell/Optimizacion.hs`):**  Pendiente (creación de métricas, ordenamiento y óptimos).
- **Informe Técnico Comparativo (`/docs/Informe_Tecnico_Comparativo.pdf`):** Pendiente (documento formal de 8 a 10 páginas comparando evaluación perezosa/inmutabilidad vs. backtracking/unificación).

---

### ⏳ Cierre del Equipo (Todos)
- **`haskell/main.hs`:** Integrar el menú interactivo completo con las opciones del Módulo 3 una vez completado `Optimizacion.hs`.
- **Etiqueta Final:** Congelar rama principal y crear tag `v1.0-final` antes de la fecha límite (08/11/2026).
