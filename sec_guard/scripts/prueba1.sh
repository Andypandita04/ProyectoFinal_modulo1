#!/bin/bash

RUTA="sec_guard/capturas/estaticos"
ARCHIVO="paquete_auditoria.tar.gz"
RESGUARDO="$RUTA/resguardo"
ARCHIVO_EJECUTAR="sec_guard/scripts/ejecutar.sh"

# Verificar que el archivo original exista antes de empezar
if [ ! -f "$RUTA/$ARCHIVO" ]; then
    echo " No existe  $RUTA/$ARCHIVO"
    exit 1
fi

echo -e "----------------------\n Iniciando Prueba 1"

# crear carpeta resguardo muevo auditoria ahi
echo "Creando $RESGUARDO y moviendo $ARCHIVO..."
mkdir -p "$RESGUARDO"
mv "$RUTA/$ARCHIVO" "$RESGUARDO/"

# Hago  una copia de auditoria en r
echo "Copiando $ARCHIVO en $RUTA..."
cp "$RESGUARDO/$ARCHIVO" "$RUTA/$ARCHIVO"

# Modifico  el peso con truncate para corromper el archivo
echo "Corrompiendo el archivo con truncate..."
truncate -s 10 "$RUTA/$ARCHIVO"

echo "Vamos a ejecutar el script ejecutar.sh"
bash "$ARCHIVO_EJECUTAR"

# Restauro auditoria en estaticos y borro resguardo
echo "Restaurando $ARCHIVO original..."
mv -f "$RESGUARDO/$ARCHIVO" "$RUTA/$ARCHIVO"
rmdir "$RESGUARDO" 2>/dev/null
echo "Veamos el contenido de $RUTA:"
ls -l "$RUTA"

echo "Prueba 1 finalizada y archivo restaurado."