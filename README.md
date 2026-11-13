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

1. **¿Por qué los permisos de un directorio pueden ser distintos a los de un
   archivo?**
   En un directorio, `x` permite recorrerlo y `w` modificar sus entradas;
   en un archivo, `r` permite leer el contenido y `w` modificarlo. Por eso
   un directorio requiere ejecución para ser utilizable, mientras que un
   archivo de datos puede ser solo de lectura.
2. **¿Qué diferencia existe entre el archivo original y su enlace duro?**
   Ambos nombres apuntan al mismo inodo y al mismo contenido. El enlace duro
   no es una copia; es otro acceso al archivo.
3. **¿Para qué sirven los enlaces simbólicos?**
   Permiten acceder a un archivo o directorio mediante una ruta alternativa
   sin duplicar datos. Son útiles para integrar rutas, versiones o recursos
   compartidos.
4. **¿Qué metadatos permiten reconocer cambios?**
   Principalmente el tamaño, la fecha de modificación, la fecha de cambio de
   metadatos.

### Etapa 2: captura y preparación

1. **¿Qué transformación necesita cada utilería?**
   La salida de `df`, `ps` y `find` debe reducirse a un valor entero con su
   categoría; los logs deben filtrarse, extraerse por campos y normalizarse
   al formato `CATEGORIA valor`.
2. **¿Por qué cero puede ser válido?**
   Cero puede representar ocupación, procesos o archivos con permisos
   riesgosos igual a cero. Una captura fallida, en cambio, no produce un
   registro válido y debe detener o informar el flujo.
3. **¿Cómo se comprueba el encabezado?**
   Se cuentan los registros normalizados y se compara ese total con la
   cantidad declarada; el programa en C también rechaza registros faltantes
   o adicionales.
4. **¿Por qué el orden de `sed` es determinante?**
   Primero deben habilitarse las directivas comentadas. Si se eliminan los
   comentarios antes, esas líneas desaparecen y ya no pueden transformarse.
   Después se eliminan comentarios restantes y líneas vacías.
5. **¿Cómo se aísla el puerto sin perder la IP?**
   Se separa el campo que contiene `IP.puerto`, se extrae la IP con cuatro
   octetos y se obtiene el puerto desde la última parte numérica, conservando
   ambos valores como campos independientes.

### Etapa 3: análisis en C

1. **¿Qué diferencia hay entre una medición y el resumen?**
   Una medición conserva los datos obtenidos y su categoría (son datos crudos) . El
   resumen agrupa varias observaciones y calcula cantidad, suma, mínimo,
   máximo, promedio y alertas, este utiliza los datos para transformarlo en información.
2. **¿Cómo se evita dividir entre cero o usar un mínimo inválido?**
   Se comprueba la cantidad antes de calcular. Si una categoría no tiene
   datos, el informe muestra `Sin datos`; de lo contrario, los extremos se
   inicializan con la primera medición válida.
3. **¿Qué se libera ante un error?**
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

