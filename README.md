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

El proyecto está implementado bajo dos paradigmas de programación complementarios:
1. **Paradigma Lógico (Prolog):** Basado en cláusulas de Horn, unificación, motor de resolución SLD, backtracking cronológico, acumuladores para detección de ciclos y meta-predicados de recopilación de soluciones (`findall/3`, `bagof/3`, `setof/3`).
2. **Paradigma Funcional (Haskell):** Basado en inmutabilidad de datos, evaluación perezosa (*lazy evaluation*), tipos algebraicos fuertemente tipados, funciones de alto orden (`map`, `filter`, `foldl`/`foldr`), *list comprehensions* y composición pura de funciones sobre estructuras de grafos inmutables.

---

## 2. Estructura del Repositorio

El proyecto mantiene una estructura modular y limpia conforme a las directrices de la cátedra:

```ascii
LogiExpressGrupoXX/
├── README.md              # Documentación central, instrucciones de compilación y estado
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

1. Abrir la terminal y posicionarse en el directorio del proyecto o dentro de `/prolog`:
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
4. *(Opcional)* Ejecución directa en una sola línea desde la terminal del sistema operativo:
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

#### Modo Compilado (Binario de Alto Desempeño)
1. Compilar el ejecutable optimizado con GHC:
   ```bash
   cd haskell
   ghc -O2 --make Main.hs -o LogiExpressCLI
   ```
2. Ejecutar el binario generado:
   - **En Linux / macOS:**
     ```bash
     ./LogiExpressCLI
     ```
   - **En Windows:**
     ```powershell
     .\LogiExpressCLI.exe
     ```

---

## 5. Resumen de Módulos Funcionales

| Módulo | Denominación | Funcionalidades Principales | Desafíos Técnicos Implementados |
| :---: | :--- | :--- | :--- |
| **Módulo 1** | **Carga Dinámica, Configuración TMC y Consultas Básicas** | • Lectura y parseo del archivo `vuelos.txt` (delimitado por `\|`).<br>• Asignación global de la ventana TMC en minutos (ej. 45 min).<br>• Consultas elementales de partidas y llegadas por ciudad $C$. | • **Prolog:** Aserción dinámica de hechos (`assertz/1`), manipulación de streams y conversión de cadenas de hora `HH:MM` a minutos absolutos.<br>• **Haskell:** Modelado de tipos algebraicos de datos (`data Vuelo`, `type Grafo`), manejo de I/O puro/impuro y procesamiento de texto con `lines` y `splitOn`. |
| **Módulo 2** | **Búsqueda Avanzada de Rutas con Restricciones** | • Generación de rutas directas y con escalas entre Ciudad Origen y Ciudad Destino.<br>• Validación de compatibilidad con el día de la semana solicitado.<br>• Verificación de conexión: $\text{HoraSalida}(V_2) \ge \text{HoraLlegada}(V_1) + \text{TMC}$.<br>• Prevención de ciclos en el itinerario.<br>• Acotamiento opcional de escalas máximas ($K$). | • **Prolog:** Algoritmo DFS mediante reglas recursivas de backtracking, listas acumuladoras `[Cabeza\|Cola]` para nodos visitados y meta-predicados de recolección (`findall/3`, `setof/3`).<br>• **Haskell:** Algoritmo recursivo sobre grafos inmutables, *list comprehensions*, funciones de alto orden (`filter`, `foldr`) y composición modular de predicados de validación. |
| **Módulo 3** | **Optimización y Filtrado de Itinerarios** | • **Ruta de Costo Mínimo:** Selección del itinerario con la menor suma de tarifas de boletos.<br>• **Ruta de Menor Tiempo Total:** Selección de la ruta con la menor duración integral (diferencia entre hora de llegada a destino y salida de origen, sumando esperas en tránsito).<br>• Reporte consolidado y ordenamiento de itinerarios por costo o duración. | • **Prolog:** Implementación nativa de algoritmos de ordenamiento sobre listas (`quicksort/3` o `mergesort/3`) y agregaciones aritméticas.<br>• **Haskell:** Uso de `Data.List.sortBy`, funciones de reducción (`foldl'`), funciones lambda de comparación y ordenamiento declarativo. |

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

## 7. Integrantes del Equipo y Contribuciones

> **Nota:** En estricto cumplimiento de las normas de auditoría y trazabilidad del proyecto, cada miembro del equipo mantiene una actividad constante reflejada a través de commits formales e individuales en el repositorio.

| Nombre y Apellido | Cédula de Identidad | Usuario de GitHub | Correo Electrónico | Responsabilidad Principal |
| :--- | :---: | :---: | :--- | :--- |
| *Kizer Ellioth* | *31912473* | https://github.com/kizerfig | *kizerelliooth@gmail.com* | Módulo 1 (Carga y Parseo) / CLI |
| *Garcia Barbara* | *67* | bardxx | *@gmail.com* | Módulo 2 (Motor de Rutas y Restricciones) |
| *Rivas Eduardo* | *31384817* | https://github.com/Mox2kk | *ejrd1705@gmail.com* | Módulo 3 (Optimización y Ordenamiento) / Informe |

---

## 8. Directrices de Auditoría y Entrega Final

- **Desarrollo Progresivo:** Queda prohibida la entrega en commits masivos de última hora. El historial del proyecto refleja un ciclo de vida evolutivo a lo largo de las 3 semanas de desarrollo.
- **Convenio de Commits:** Mensajes con estándar formal descriptivo (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`).
- **Colaboradora Docente:**
  - Prof. Jannelly Bello (`jbelloch@gmail.com`)
- **Hito de Entrega Final:**
  - **Fecha Límite:** `08/11/2026`
  - **Mecanismo de Cierre:** Congelamiento de la rama `main` y emisión del tag formal de versión:
    ```bash
    git tag -a v1.0-final -m "Versión final auditada y lista para evaluación - 08/11/2026"
    git push origin v1.0-final
    ```
  - **Informe Técnico:** Documento PDF con rigor formal de ingeniería cargado obligatoriamente en la ruta `/docs/Informe_Tecnico_Comparativo.pdf`.
