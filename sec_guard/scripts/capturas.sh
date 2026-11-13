#!/bin/bash
RUTA_SEC="sec_guard"
fecha_hora=$(date '+Fecha: %Y-%m-%d Hora: %H:%M:%S')
RUTA_LOG="$RUTA_SEC/capturas/telemetria_raw.log" 

    echo "Vamos a empezar a capturar telemetria del sistema"
    echo "-------------------------------" >> "$RUTA_LOG"
# Vamos a sacar el porcentaje de uso del disco  del usuario actual 
if disco=$(df -P "$HOME" 2>/dev/null | awk 'NR==2 {gsub("%", "", $5); print $5}'); then
    echo "Se obtuvo el porcentaje de uso del disco: ${disco}%"
    echo -e "$fecha_hora\nDISCO ${disco}" >> "$RUTA_LOG"
else 
    echo "Error al obtener el porcentaje de uso del disco"
    exit 1
fi

# Vamos a sacar el numero de procesos del usuario actual
if procesos=$(ps -u "$USER" --no-headers 2>/dev/null | wc -l); then
    echo "Se obtuvo el numero de procesos del usuario actual: $procesos"
    echo -e "$fecha_hora\nPROCESOS $procesos" >> "$RUTA_LOG"
else
    echo "Error al obtener el numero de procesos del usuario actual"
    exit 1
fi

# Vamos a sacar el numero de archivos con permisos
# g+w o o+w en el directorio sec_guard
if salida_find=$(find "$RUTA_SEC" -type f \( -perm /g+w -o -perm /o+w \) 2>/dev/null); then
    # Aqui verifico si la salida es vacia 
    if [ -z "$salida_find" ]; then
        permisos=0
    else
        permisos=$(echo "$salida_find" | wc -l)
    fi

    echo "Se obtuvo el numero de archivos con permisos g+w o o+w en el directorio $RUTA_SEC: $permisos"
        echo -e "$fecha_hora\nPERMISOS $permisos" >> "$RUTA_LOG"
else
    echo "Error al obtener el numero de archivos con permisos g+w o o+w en el directorio $RUTA_SEC"
    exit 1
fi

    echo "Se acaba de obtener toda la telemetria, vease los datos"
    cat "$RUTA_LOG" 
