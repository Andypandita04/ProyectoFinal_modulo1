#!/bin/bash
RUTA_SCRIPTS="sec_guard/scripts"
echo "---Prueba 4"

# Ejecucion inicial exitosa
echo  " Vamos a ejecutar  ejecutar.sh "
    bash "$RUTA_SCRIPTS/ejecutar.sh" > /dev/null 

# Vamos quitar permisos 
echo  "Vamos a quitar permisos de ejecución y lectura a capturas.sh (chmod 000)..."
chmod 000 $RUTA_SCRIPTS/capturas.sh
ls -l $RUTA_SCRIPTS/capturas.sh

echo  " Vamos a ejecutar  ejecutar.sh  otra vez "
    bash "$RUTA_SCRIPTS/ejecutar.sh" 

# Aqui veo si informe_seguridad.txt exite 
echo  "\Veamos su resultados/informe_seguridad.txt existe"
if [ ! -f "resultados/informe_seguridad.txt" ]; then
    echo " El informe anterior fue eliminado correctamente. No se entregan datos obsoletos."
else
    echo " -> Error:El archivo resultados/informe_seguridad.txt sigue existiendo."
fi

echo -e "Vamos a restaurar permisos a capturas.sh"
chmod 755 $RUTA_SCRIPTS/capturas.sh
ls -l $RUTA_SCRIPTS/capturas.sh

echo "---- Fin prueba 4"