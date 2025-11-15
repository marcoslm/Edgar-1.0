# Edgar 1.0 – chatbot retro en BASIC (Rebirth Edition 2011)

**Edgar 1.0** es un chatbot clásico, de la vieja escuela, basado en palabras clave y una pequeña base de datos de conocimiento. No usa IA moderna ni modelos de lenguaje: es puro BASIC noventero llevado un poco más allá.

Esta versión es la **“Rebirth Edition” (2011)**, un port y actualización a **FreeBASIC para Windows** de un proyecto que viene de muy atrás:

- Origen en un **ejemplo de GWBASIC** de una revista ochentera.

- Port y ampliación a **QBASIC** en PC.

- Reescritura y evolución en **VB-DOS** dentro de un **HP 200LX** (palmtop DOS a pilas).

- Y finalmente, en 2011, port a **FreeBASIC + modo VGA 320×200 / 256 colores** en PC, con gráficos, cara de robot y más funciones.

Se publica aquí como proyecto de **conservación / arqueología personal**.

- **Nombre:** Edgar 1.0 – Rebirth Edition

- **Autor:** Marcos López Merayo

- **Plataformas históricas:** GWBASIC, QBASIC, MS-DOS / HP 200LX (VB-DOS), FreeBASIC para Windows

- **Versión actual:** Rebirth Edition (2011)

---

## ¿Qué es Edgar?

Edgar es un **programa de conversación** que intenta simular cierta “inteligencia” a base de:

- Búsqueda de **palabras clave** en lo que escribes.

- Una base de datos de frases y respuestas.

- Capacidades sencillas de **aprendizaje y deducción**.

No es un modelo estadístico ni semántico: su comportamiento se basa en reglas y texto preprogramado, con un montón de apaños acumulados desde los tiempos del GWBASIC.

La Rebirth Edition añade, respecto a las versiones DOS anteriores:

- **Modo gráfico VGA** en vez de pantalla de texto.

- Una **cara de robot** con distintas expresiones y “humor”.

- Base de datos ampliada y funciones de búsqueda/comparación mejoradas.

- Soporte para **síntesis de voz** usando un programa externo (eSpeak).

- Varios bugs corregidos respecto a la versión para HP 200LX.

---

## Línea temporal del proyecto

A grandes rasgos, Edgar ha pasado por estas fases:

1. **Finales de los 80 / principios de los 90**  
   Ejemplo sencillo de chatbot en **GWBASIC** en una revista, muy limitado.

2. **Años 90**  
   Port a **QBASIC**, ampliando base de datos, añadiendo funciones y empezando a convertir números de línea y `GOSUB` en `SUB`/`FUNCTION`.

3. **Alrededor de 2004 – HP 200LX**  
   Port a **Visual Basic para DOS (VB-DOS)** en un **HP 200LX**, programando directamente en la mini pantalla LCD:
   
   - Se añaden más funciones.
   
   - Se refactoriza parte del código viejo.
   
   - Se le da “personalidad” y humor en ASCII en modo texto.
   
   - Se añade soporte de **síntesis de voz** apoyándose en un programa externo.

4. **2011 – Rebirth Edition**  
   Port a **FreeBASIC** para Windows:
   
   - Interfaz VGA 320×200, 256 colores, con cara de robot animada.
   
   - Base de datos ampliada.
   
   - 90% del código convertido por fin a código sin números de línea ni `GOSUB`.
   
   - Se mantiene el espíritu y muchas tripas heredadas.

---

## Cómo hablar con Edgar

Hay que tener en cuenta que Edgar **no es humano** y sus capacidades son limitadas. Para sacar lo mejor de él:

- Usa **frases completas** y claras.  
  Las respuestas tipo “yo también”, “yo no”, “también” sin contexto lo descolocan.

- Intenta escribir bien las frases con **“por qué” / “porque”**:
  
  - *“por qué”* (separado) para preguntar.
  
  - *“porque”* (junto) para explicar.  
    Si lo usas al revés, es fácil que Edgar lo interprete mal.

- Para cerrar el programa, puedes despedirte con algo como:  
  `adios`, `hasta otra`, `apágate`, etc.

> **Importante:** esta versión no soporta correctamente tildes ni caracteres especiales (ñ, á, é...).  
> Lo más seguro es escribir **sin acentos ni caracteres fuera del ASCII básico**.

---

## Edgar aprende y deduce

Edgar tiene un sistema de **aprendizaje simbólico** muy sencillo basado en frases del tipo:

- `X ES Y`

- `X SON Y`

Por ejemplo:

- `vehiculo es una maquina para transportar personas o cosas`

- `automovil es vehiculo`

Más tarde puedes preguntarle:

- `que es un vehiculo?`

- `que es un automovil?`

También puedes jugar con personas y adjetivos:

- `juan es un poco tonto`

- `tontico es un poco tonto`

Luego puedes preguntar:

- `quien es tontico?`

y Edgar intentará atar cabos a partir de lo aprendido.  
Las relaciones pueden ser **recursivas**, así que a veces las deducciones son curiosas… y otras, directamente disparatadas.

Si la cosa se le va de las manos y empieza a responder barbaridades todo el rato, puedes pedirle que **olvide**:

- `olvida todo`

- `olvidalo todo`

Eso resetea su base de datos de lo aprendido y vuelve al estado inicial.

---

## Otras funciones curiosas

Algunos comportamientos remarcables de Edgar:

- **Sigue el “hilo” de la conversación** durante un rato:  
  entiende preguntas como `el que?`, `quien?`, `por que?` referidas a su última respuesta.

- Tiene un **estado de humor** interno:
  
  - Si le tratas bien, se anima.
  
  - Si le insultas o eres muy pesado, se va enfadando.
  
  - Si el humor baja demasiado, puede **cerrarse** él solito.

- Tiene noción simple del **tiempo**:
  
  - Puede decir la hora.
  
  - Según la hora del día, cambia algún comentario de contexto.

- Si lo dejas mucho rato sin escribirle, puede que se **aburra** y termine cerrándose.

- Puede **repetir texto literal**:
  
  - Si le dices: `DI ERES MUY GUAPA`  
    responderá literalmente: `ERES MUY GUAPA`.

La gracia está en experimentar y ver qué hace; hay respuestas y comportamientos que solo salen trasteando.

---

## Contenido del repositorio

> Ajusta esta sección a la estructura real que uses en el repo.  
> Un ejemplo razonable podría ser:

```text
/edgar-rebirth-2011/      ← versión principal FreeBASIC (esta)
/legacy-2004-hp200lx/     ← versión anterior para HP 200LX (VB-DOS)
/Bases de datos especializadas/ ← bases de datos alternativas
/docs/                    ← capturas, etc.
README.md
```

En la parte de **Rebirth Edition (2011)** se incluye:

- Código fuente de **Edgar 1.0 Rebirth Edition** en FreeBASIC  
  (archivo `.bas` principal y, como mínimo, `datos_internos.bi` para la base de datos interna).

- Ejecutable para **Windows**  
  Listo para ejecutarse en modo gráfico **VGA 320×200, 256 colores**.

- Recursos gráficos  
  (cara del robot, expresiones, fondos, etc.).

- Archivos de datos
  
  - Base de conocimiento “fija”.
  
  - Ficheros donde Edgar guarda lo que va aprendiendo (`EDGAR1DB.DAT` y derivados).

En la carpeta de **versiones históricas** (`legacy-2004-hp200lx`) se pueden encontrar:

- Fuentes originales de **Edgar 1.0 para HP 200LX** en VB-DOS (cara ASCII).

- Ejecutables para DOS/200LX.

Estas versiones **no están pensadas para ser compiladas hoy tal cual**, se conservan como **arqueología digital**.

---

## Bases de datos especializadas

Además de la base de datos estándar, es posible usar **bases de datos alternativas** para Edgar, centradas en temas concretos. Por ejemplo:

- `Bases de datos especializadas/Sinónimos/EDGAR1DB.DAT`

- `Bases de datos especializadas/Términos informáticos/EDGAR1DB.DAT`

El mecanismo es muy simple:

1. Haz una copia de seguridad del archivo `EDGAR1DB.DAT` que tengas en la carpeta raíz donde está el ejecutable de Edgar.

2. Elige una de las bases especializadas (por ejemplo la de sinónimos).

3. Copia el `EDGAR1DB.DAT` de esa carpeta especializada y **sustitúyelo** en la raíz del ejecutable.

4. Lanza Edgar normalmente.

De esta forma, Edgar utilizará esa base de datos alternativa como **conocimiento principal**, lo que modifica el tipo de asociaciones, ejemplos y deducciones que hace.

Si quieres volver al comportamiento estándar, basta con restaurar el `EDGAR1DB.DAT` original desde la copia de seguridad.

---

## Detalles técnicos frikis

Para quien tenga curiosidad por las tripas:

- Edgar utiliza una **base de datos de conocimiento** basada en un gran array:
  
  ```basic
  items = 400000
  Dim Shared DBASE(items, 2) As String
  ```
  
  Hasta 400.000 posibles entradas de tipo `CLAVE -> DATO`, usadas para el sistema `X ES Y`, preguntas `QUE ES...`, `QUIEN ES...`, etc.

- El **estado emocional** está modelado explícitamente:
  
  ```basic
  Dim Shared humor  As Integer ' HUMOR ACTUAL
  Dim Shared OHUMOR As Integer ' HUMOR ANTERIOR
  ```
  
  Y una rutina, `PROCHUMOR`, se encarga de subir/bajar el humor según lo que le dices, y de tomar decisiones (por ejemplo, apagarse si está demasiado quemado).

- El port a FreeBASIC tuvo que recrear manualmente cosas como `ON TIMER`, usando el valor de `Timer` y comprobaciones periódicas en el bucle principal.

- La **síntesis de voz** se realiza llamando a `espeak.exe` en modo consola (con parámetros como `-ves` y ruta de datos propia), desde un subproceso lanzado por el programa.

- El sonido (WAV) se reproduce usando la API de Windows (`PlaySound` vía `win\mmsystem.bi` y wrappers en BASIC).

- Existe un **modo debug** (`MDEBUG`) que muestra por pantalla la carga de bases de datos, número de ítems, conjunciones, etc., útil para ver qué está haciendo por dentro.

---

## Sobre el código

El código de Edgar es el resultado de **muchos años de remiendos y migraciones**:

- Nació en **GWBASIC** con números de línea y `GOSUB`.

- Pasó por **QBASIC** y **VB-DOS** en un HP 200LX.

- Finalmente se portó a **FreeBASIC** en 2011, convirtiendo la gran mayoría de `GOSUB` y números de línea en `SUB`/`FUNCTION`, pero arrastrando la filosofía original.

Muchos nombres de variables y textos están en **MAYÚSCULAS** por dos motivos:

1. Herencia directa de GWBASIC/QBASIC, donde era muy habitual escribir todo así.

2. En la pequeña pantalla LCD monocroma del **HP 200LX** se leían mejor las mayúsculas compactas.

> El código no está pensado como ejemplo de buenas prácticas modernas.  
> Es un experimento personal que se fue ampliando a ratos durante años, arrastrando trozos muy viejos y mucha “chapuza histórica”.  
> Lo conservo **tal cual** se escribió y se fue adaptando en su momento, con todos sus defectos, como parte del valor nostálgico y arqueológico del proyecto.

Si algún día existe un **Edgar 2.0**, sería un proyecto nuevo, desde cero, con una base sólida y seguramente con enfoque multiplataforma retro. Esta repo es el **fósil** de la versión 1.x.

---

## Estado del proyecto

- **Estado:** congelado. No se planean nuevas funciones ni refactorización.

- **Objetivo actual:** preservar el código y el comportamiento de Edgar 1.0 Rebirth Edition tal y como estaban en 2011.

- Cualquier evolución futura sería en forma de **nuevo proyecto**, no una continuación directa de éste.

## Descargas

Las distintas versiones ejecutables de Edgar 1.0 (Rebirth Edition para Windows, versiones LX/LX Plus para HP 200LX y sus equivalentes con DOSBox para Windows) están disponibles en la sección de *releases* del repositorio:

➡️ [Descargar Edgar 1.0 – paquetes y ejecutables](https://github.com/marcoslm/Edgar-1.0/releases/tag/edgar10)

---

## Short version in English

**Edgar 1.0** is a retro-style chatbot written in various BASIC dialects over the years (GWBASIC, QBASIC, VB-DOS on a HP 200LX, and finally FreeBASIC for Windows in 2011).

It uses keyword matching and a hand-made knowledge base (`X IS Y`, `X ARE Y`, questions like `WHAT IS X?`, `WHO IS Y?`) plus a simple **mood system** to simulate some conversational behaviour. The 2011 **Rebirth Edition** adds VGA graphics (320×200, 256 colors), a robot face with expressions, a larger database, debug mode and optional speech synthesis via eSpeak.

There are also **specialized databases** (e.g. synonyms, computing terms) that can be used by replacing `EDGAR1DB.DAT` in the executable folder with one of the alternative `.DAT` files.

The code is preserved **as-is**, full of historical hacks, uppercase identifiers and spaghetti inherited from GWBASIC and old DOS machines. It is published here purely for archival and nostalgic purposes.
