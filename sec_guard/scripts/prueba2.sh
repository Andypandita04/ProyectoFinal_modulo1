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

echo -e "----------------------\n Iniciando Prueba 2"

#Obtengo el valor original de la línea 2
var=$(sed -n '2p' "$RUTA_MED/$ARCHIVO")
echo "Valor original en línea 2: $var"

# Aumento el valor y lo remplazp en la linea 2
mayor=$(expr "$var" + 10)
echo "Cambiando valor  linea 2 --->$mayor "
sed -i "2s/[0-9]*/$mayor/" "$RUTA_MED/$ARCHIVO"

# Ejecuto sec_engine
echo "Ejecutando sec_engine con valor mayor..."
"$SCRIPT" "$RUTA_MED/$ARCHIVO" "$SALIDA"

# Disminuyo el valor de la linea 2 
menor=3
echo "Cambiando valor de la linea 2 --->$menor"
sed -i "2s/[0-9]*/$menor/" "$RUTA_MED/$ARCHIVO"

echo "Ejecutando sec_engine con valor menor..."
"$SCRIPT" "$RUTA_MED/$ARCHIVO" "$SALIDA"

echo "Prueba 2 finalizada."