#!/bin/bash
RUTA_BASE="sec_guard"
RUTA_SCRIPTS="$RUTA_BASE/scripts"
ARCHIVO_C="$RUTA_BASE/fuentes/sec_engine.c"
RESPALDO_C="$RUTA_BASE/fuentes/sec_engine.c.bak"

echo "--- Prueba 5"

# Ejecucion inicial exitosa
echo  " Vamos a ejecutar  ejecutar.sh "
    bash "$RUTA_SCRIPTS/ejecutar.sh" > /dev/null 

echo "Veamos  que el binario compilado exista:"
if [ -f "$RUTA_BASE/bin/sec_engine" ]; then
    echo "El binario sec_engine existe"
else
    echo "El binario sec_engine no existe"
fi



#Creo copia de respaldo de sec_engine.c
echo "Vamos a crear una copia de respaldo de sec_engine.c "
cp "$ARCHIVO_C" "$RESPALDO_C"

# Elimino la primera linea con sed -i
echo "Elimino la primera linea de sec_engine.c para simular un error de compilación..."
sed -i '1d' "$ARCHIVO_C"
echo "Primeras líneas actuales de sec_engine.c tras modificarlo:"
head -n 5 "$ARCHIVO_C"

# Ejecucion 2
echo  " Vamos a ejecutar  ejecutar.sh "
    bash "$RUTA_SCRIPTS/ejecutar.sh" > /dev/null 



# Vamos a resturar sec_engine.c a
echo "Vamos a restaurar sec_engine.c"
mv "$RESPALDO_C" "$ARCHIVO_C"
echo "Primeras líneas restauradas de sec_engine.c:"
head -n 3 "$ARCHIVO_C"

echo "---- Fin prueba 5"