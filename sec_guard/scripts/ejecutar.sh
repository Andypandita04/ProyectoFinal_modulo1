#!/bin/bash

RUTA_B="sec_guard"
RUTA_CAPTURAS="$RUTA_B/capturas"
RUTA_EST="$RUTA_B/capturas/estaticos"
RUTA_PREP="$RUTA_B/preparados"
RUTA_RESULTADOS="$RUTA_B/resultados"
RUTA_SCRIPTS="$RUTA_B/scripts"
# Limpieza 
#
	echo -e "---------------------------\n---------------------------"
    echo "Comienza ejecución, primero vamos a limpiar archivo residuales de ejecuaciones  anteriores"
	if  rm -rf "$RUTA_CAPTURAS"/* ;then
	       echo -e "Se vacio directorio  $RUTA_CAPTURAS \
		   \nVereficando que no existan archivos residuales con ls"
		   ls "$RUTA_CAPTURAS"
	else
		echo "No se pudo vaciar el directorio $RUTA_CAPTURAS"
		exit 1
	fi
	if  rm -rf "$RUTA_PREP"/* ;then
		echo "Se vacio directorio  "$RUTA_PREP""
		ls "$RUTA_PREP"
	else
		echo "No se pudo vaciar el directorio "$RUTA_PREP""
		exit 1
	fi
	if  rm -rf "$RUTA_RESULTADOS"/* ;then
		echo "Se vacio directorio  "$RUTA_RESULTADOS""
		ls "$RUTA_RESULTADOS"
	else
		echo "No se pudo vaciar el directorio "$RUTA_RESULTADOS""
		exit 1
	fi


	## Comienza ejecucion de los scripts 
	echo -e "---------------------------\n---------------------------"
	echo " Se limpio con exito, ahora vamos a ejecutar el scrip2 
	que extrae y procesa los archivos"
	# Scrip Etapa 2 
	bash "$RUTA_SCRIPTS/script2.sh"

	# Verifico si el script2.sh se ejecuto correctamente
	if [ $? -ne 0 ]; then
    	echo "ERROR CRÍTICO: Falló la ejecución de script2.sh. Abortando flujo." >&2
    	exit 1
	fi
	echo -e "---------------------------\n---------------------------"
	echo "Vamos a ejecutar el scrip3 que nos ayuda a generar los resultados finales"
	
	# Scrip Etapa 3
	bash "$RUTA_SCRIPTS/script3.sh"

	# Verifico si el script3.sh se ejecuto correctamente
	if [ $? -ne 0 ]; then
    	echo "ERROR CRÍTICO: Falló la ejecución de script3.sh. Abortando flujo." >&2
    	exit 1
	fi

    echo "Se finalizo con exito la ejecución de los scripts, los resultados finales se encuentran en $RUTA_RESULTADOS"
	echo -e "---------------------------\n---------------------------"
