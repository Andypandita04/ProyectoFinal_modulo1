# Proyecto integrador: monitoreo y análisis de recursos en Linux

Proyecto DGTIC

Este proyecto captura mediciones del entorno Linux, preparar los datos con
utilerías y Shell, analizarlos con C y generar un informe reproducible.

## Árbol del proyecto

```text
ProyectoFinal_modulo1/
├── README.md
└── sec_guard/
    ├── capturas/
    │   ├── estaticos/
    │   │   ├── paquete_auditoria.tar.gz
    │   │   ├── net_traffic.log
    │   │   ├── secure.log
    │   │   └── sshd_config
    │   └── telemetria_raw.log
    ├── evidencias/
    │   ├── permissions.txt
    │   ├── prueba1.sh
    │   ├── prueba2.sh
    │   ├── prueba3.sh
    │   ├── prueba4.sh
    │   ├── prueba5.sh
    │   └── pruebas/
    │       ├── hardlink.txt
    │       ├── link_record.txt
    │       ├── prueba_doc_version1.txt
    │       └── symlink_pruebas -> symlink_pruebas
    ├── smylink_pruebas -> evidencias/pruebas
    ├── fuentes/
    │   ├── sec_engine
    │   └── sec_engine.c
    ├── preparados/
    │   ├── conexiones_syn.txt
    │   ├── mediciones_sec.txt
    │   ├── sshd_activo.txt
    │   └── usuarios_creados.txt
    ├── resultados/
    │   └── informe_seguridad.txt
    └── scripts/
        ├── capturas.sh
        ├── ejecutar.sh
        ├── metadatos.sh
        ├── normalizacion.sh
        ├── prueba1.sh
        ├── prueba2.sh
        ├── prueba3.sh
        ├── prueba4.sh
        ├── prueba5.sh
        ├── script1.sh
        ├── script2.sh
        └── script3.sh
```

## Propósito de las carpetas

- `capturas/`: registros originales y archivos estáticos de auditoría.
- `preparados/`: datos transformados para el programa en C.
- `fuentes/`: código fuente y binario compilado.
- `scripts/`: captura, normalización, procesamiento e integración.
- `resultados/`: informe generado por el analizador.
- `evidencias/`: permisos, metadatos, enlaces y pruebas.

## Requisitos

- Linux, Bash, `tar`, `grep`, `sed`, `awk`, `find`, `df`, `ps`, `paste`
- GCC con soporte para C estándar.
- Permisos de lectura, escritura y ejecución dentro del directorio del proyecto.

## Reproducción

Desde la raíz del repositorio:

```bash
cd sec_guard
chmod +x scripts/*.sh
cd ..
./sec_guard/cripts/ejecutar.sh
```

El flujo limpia resultados anteriores, valida y extrae el paquete estático,
prepara los archivos, captura la telemetría, normaliza las mediciones, compila
el analizador con `-Wall -Wextra -Werror` y genera
`resultados/informe_seguridad.txt`.

Para ejecutar solo el analizador:

```bash
./sec_guard/fuentes/sec_engine \
  sec_guard/preparados/mediciones_sec.txt \
  sec_guard/resultados/informe_seguridad.txt
```

El formato de `mediciones_sec.txt` es:

```text
AuditoriaCursoC
9
DISCO 62
PROCESOS 8
PERMISOS 0
DISCO 82
PROCESOS 11
PERMISOS 1
DISCO 78
PROCESOS 10
PERMISOS 0
```

## Decisiones de diseño

- Se conservan las capturas originales y se generan archivos separados para
  los datos preparados; así se pueden auditar las transformaciones.
- Los permisos se asignan con prioridad al propietario. Los directorios
  necesitan ejecución para poder acceder a su contenido, mientras que los
  archivos de datos normalmente solo necesitan lectura y escritura.
- En C se usan estructuras para representar mediciones y resúmenes; cada
  categoría mantiene sus valores, cantidad, suma, extremos, promedio y
  alertas.
- La memoria dinámica se reserva solo si existen registros y se libera en
  las rutas de error y al terminar.
- `sed` elimina comentarios y líneas vacías después de habilitar las
  directivas necesarias. `grep` y `awk` aíslan los registros y campos de los
  logs; las expresiones regulares separan las IP de los puertos.
- El script orquestador comprueba los códigos de salida para evitar que un
  informe anterior se interprete como resultado de una ejecución fallida.

## Preguntas y respuestas por etapa

### Etapa 1: organización y archivos

1. **¿Por qué los permisos adecuados para un directorio pueden ser distintos de los necesarios para un archivo de datos?**
   Porque `r`, `w` y `x` significan cosas distintas según el objeto. En un directorio, `r` permite listar sus entradas, `w` crear, borrar o renombrar entradas (junto con `x`) y `x` atravesarlo para acceder a lo que contiene. En un archivo, `r` permite leer, `w` modificar y `x` ejecutar. Por eso un directorio necesita `x` para ser utilizable (por ejemplo `755`), mientras que un archivo de datos normalmente no lo necesita (por ejemplo `644`).

2. **¿Qué diferencia existe entre el archivo original y su enlace duro?**
   Ninguna en la práctica: ambos son nombres que apuntan al mismo inodo, por lo que comparten contenido, permisos y propietario. No es una copia y no hay un "original"; los datos solo se liberan cuando el contador de enlaces llega a 0. No puede cruzar sistemas de archivos ni apuntar a directorios.

3. **¿Cuál es la utilidad de establecer enlaces simbólicos en el desarrollo de un sistema?**
   Permiten acceder a un archivo o directorio mediante una ruta alternativa sin duplicar datos, y pueden cruzar sistemas de archivos. Son útiles para versionar (`current -> release_1.4`), mantener compatibilidad de rutas y compartir recursos o configuraciones. Si el destino se elimina, el enlace queda roto.

4. **¿Qué información de los metadatos permite reconocer cambios en un archivo?**
   El tamaño (`st_size`), la fecha de modificación del contenido (`mtime`), la fecha de cambio de metadatos (`ctime`), los permisos y propietario, y el número de inodo (que detecta si el archivo fue reemplazado). Como los metadatos pueden alterarse, para mayor certeza se complementan con un hash del contenido (`sha256sum`).

### Etapa 2: captura y preparación
1. **¿Qué transformación necesita la salida de cada utilería para convertirse en un registro del archivo normalizado?**
  **df (disco)**
- `df -P "$HOME" 2>/dev/null`
- `awk 'NR==2 {gsub("%", "", $5); print $5}'`
- `echo -e "$fecha_hora\nDISCO ${disco}" >> "$RUTA_LOG"`

**ps (procesos)**
- `ps -u "$USER" --no-headers 2>/dev/null`
- `wc -l`
- `echo -e "$fecha_hora\nPROCESOS $procesos" >> "$RUTA_LOG"`

**find (permisos)**
- `find "$RUTA_SEC" -type f \( -perm /g+w -o -perm /o+w \) 2>/dev/null`
- `[ -z "$salida_find" ]` → si la salida está vacía, `permisos=0`
- `echo "$salida_find" | wc -l`
- `echo -e "$fecha_hora\nPERMISOS $permisos" >> "$RUTA_LOG"`

2. **¿Por qué un valor cero puede ser válido y no debe confundirse con una captura fallida?**
   Porque cero es un resultado legítimo: 0 % de ocupación, 0 procesos o 0 archivos con permisos que  significa que no hay hallazgos. Una captura fallida, en cambio, no produce un registro (salida vacía o código de retorno distinto de 0), por lo que debe detener el flujo o informar el error y nunca registrarse como 0.

3. **¿Cómo comprobarán que la cantidad del encabezado corresponde a los registros conservados?**
   Se cuentan los registros normalizados (`wc -l`) y se compara ese total con la cantidad declarada en el encabezado. Si no coinciden, el programa en C rechaza el archivo por tener registros faltantes o adicionales.

4. **¿Por qué el orden de las instrucciones dentro del flujo de sed es estrictamente determinante al habilitar directivas y eliminar comentarios?**
   Porque las directivas están comentadas (`#Port`, `#HostKey`) y primero deben habilitarse (`s/#Port/Port/`, `s/#HostKey/HostKey/`). Si antes se eliminan las líneas con `#` (`/#/d`), esas directivas desaparecen y ya no pueden transformarse. Solo después se eliminan los comentarios restantes y las líneas vacías (`/^$/d`).

5. **¿Qué estrategia se empleó para aislar el puerto sin limitar obtener correctamente los cuatro octetos de la IP?**
   Con `awk` se separa el campo `IP.puerto` (por ejemplo `192.168.1.5.54321`). La IP se extrae con `grep -o` tomando exactamente cuatro octetos, y el puerto se obtiene de la última parte numérica, después del último punto. Cada valor se conserva en un campo independiente (`Origen: IP`, `Puerto: N`) y se unen con `paste`, de modo que no se pierda ningún octeto.


### Etapa 3: análisis en C

1. **¿Qué diferencia existe entre almacenar una medición y almacenar el resumen de una categoría?**
   Una medición conserva los datos obtenidos y su categoría (son datos crudos) . El
   resumen agrupa varias observaciones y calcula cantidad, suma, mínimo,
   máximo, promedio y alertas; este utiliza los datos para transformarlo en información.
2. **¿Cómo evitarán una división entre cero o utilizar un mínimo que todavía no se ha inicializado?**
   Se comprueba la cantidad antes de calcular. Si una categoría no tiene
   datos, el informe muestra `Sin datos`; de lo contrario, los extremos se
   inicializan con la primera medición válida.
3. ** Si ocurre un error después de reservar memoria y abrir un archivo, ¿qué recursos deben liberar o cerrar?**
   Deben cerrarse los archivos abiertos y liberarse todos los bloques de
   memoria reservados. También se deben verificar los errores de escritura y
   cierre del archivo de salida.

### Etapa 4: integración y pruebas

1. **¿Cómo decide el script si puede continuar después del programa C?**
   Revisa el código de salida inmediatamente después de cada script,
   compilación o ejecución. Un valor distinto de cero muestra el error y
   termina el flujo.
2. **¿Cómo se distingue un informe nuevo de uno anterior?**
   Dado que se eliminan los resultados residuales antes de iniciar, y se crea
   un archivo nuevo, no se puede, pero, podemos corroborar que se esta generando
   un nuevo informe en cada ejecución por la Prueba 4.
3. **¿Qué evidencia demuestra que se usó el flujo completo?**
   La salida del orquestador(ejecutar.sh), va imprimiendo que paso esta realizando.
   Si se realiza con exito, se verá en pantalla. 
   La evidencia se encuentran en 
   `evidencias/pruebas/admin_process.txt`.



## Registros de pruebas 
1. Paquete `.tar.gz` corrupto: el orquestador debe detenerse antes de extraer.
2. Cantidad de registros mayor o menor que las líneas reales: C debe rechazar
   la entrada.
3. Categoría sin observaciones y archivo con cero registros: no debe ocurrir
   división entre cero y debe aparecer `Sin datos`.
4. Falla en una etapa intermedia: no debe conservarse un informe obsoleto.
5. Error de compilación: no debe ejecutarse un binario anterior.

Cada prueba debe conserva un ejemplo de su procedimiento, salida y resultado en
`evidencias/` o `evidencias/pruebas/`.
Las pruebas no se guardan en el sistema por si solo.

Para ejecutar alguna prueba, en terminal desde la carpeta raíz:
```bash
./scripts/prueba1.sh
```

