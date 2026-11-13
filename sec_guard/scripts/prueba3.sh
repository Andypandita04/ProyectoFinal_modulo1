#!/bin/bash

RUTA_MED="sec_guard/preparados"
ARCHIVO="mediciones_sec.txt"
SCRIPT="sec_guard/fuentes/sec_engine"
SALIDA="sec_guard/resultados/informe_seguridad.txt"

# Verificamos que existan el archivo y el ejecutable
if [ ! -f "$RUTA_MED/$ARCHIVO" ]; then
    echo "No existe $RUTA_MED/$ARCHIVO"
    exit 1
fi
if [ ! -x "$SCRIPT" ]; then
    echo "No existe o no tiene permisos de ejecución $SCRIPT"
    exit 1
fi

echo -e "----------------------\n Iniciando Prueba 3"

# Caso A : Eliminar todos los registros de la categoría PERMISOS y ejecutar sec_engine
echo -e "\n---Caso A: Eliminando registros de PERMISOS..."

#Quito el espacio entre PERMISOS y su valor para juntarlos 
sed -i 's/^PERMISOS /PERMISOS/' "$RUTA_MED/$ARCHIVO"

#borro las líneas que contienen PERMISOS
sed -i '/^PERMISOS/d' "$RUTA_MED/$ARCHIVO"

# Actualizar la línea 2 con la cantidad real de registros que quedaron
# muestro desde la linea 3  (+3) y cuento las lineas con wc -l
total_restante=$(tail -n +3 "$RUTA_MED/$ARCHIVO" | wc -l)
sed -i "2s/[0-9]*/$total_restante/" "$RUTA_MED/$ARCHIVO"

echo "------Archivo modificado para Caso A:---------"
cat "$RUTA_MED/$ARCHIVO"
echo "------Archivo modificado para Caso A.---------"


# Ejecutar sec_engine para Caso A
echo "Ejecutando sec_engine con categoría PERMISOS vacía (registros: $total_restante)..."
"$SCRIPT" "$RUTA_MED/$ARCHIVO" "$SALIDA"
cat "$SALIDA"

#Caso B: Dejar el archivo con 0 registros y ejecutar sec_engine
echo -e "\n\n\n---Caso B Dejando archivo con 0 registros..."

# Obtener las 2 primeras líneas con head y guardarlas en mediciones_sec.txt
head -n 2 "$RUTA_MED/$ARCHIVO" >> "$RUTA_MED/vacio.txt"

# Cambiar la línea 2 a 0
sed -i '2s/[0-9]*/0/' "$RUTA_MED/vacio.txt"

echo "------Archivo modificado para Caso B:---------"
cat "$RUTA_MED/vacio.txt"
echo "------Archivo modificado para Caso B .---------"

# Ejecutar sec_engine para Caso B
echo "Ejecutando sec_engine con 0 registros..."
"$SCRIPT" "$RUTA_MED/vacio.txt" "$SALIDA"
cat "$SALIDA"

echo -e "\nPrueba 3 finalizada."