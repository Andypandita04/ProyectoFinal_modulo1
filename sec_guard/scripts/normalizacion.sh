#!/bin/bash

RAW_LOG="sec_guard/capturas/telemetria_raw.log"
ARCH_MEDICIONES="sec_guard/preparados/mediciones_sec.txt"

    echo "Vamos crear el archivo mediciones_sec.txt en sec_guard/preparados"
# Vamos a hacer el encabezado de mediciones 
    echo "AuditoriaCursoC" > "$ARCH_MEDICIONES"
    echo "total" >> "$ARCH_MEDICIONES"

# Vamos a pasar los registros a mediciones
# eliminiamos lineas que comienzan con "-" o "Fecha" del .log y anexar al .txt con >>
    sed -e '/^-/d' -e '/^Fecha/d' "$RAW_LOG" >> "$ARCH_MEDICIONES"

# Vamos a contar el total de registros 
    lineas=$(wc -l < "$ARCH_MEDICIONES")
    registros=$(expr "$lineas" - 2)

# Sustituimos total por no de registros
    sed -i "s/^total$/$registros/" "$ARCH_MEDICIONES"

    echo "Se creo correctamente mediciones_sec.txt, vease su contenido" 
    cat "$ARCH_MEDICIONES"