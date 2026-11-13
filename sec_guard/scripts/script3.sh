#!/bin/bash
RUTA_FUENTES="sec_guard/fuentes"
RUTA_ENTRADA="sec_guard/preparados/mediciones_sec.txt"
RUTA_SALIDA="sec_guard/resultados/informe_seguridad.txt"


    cd $RUTA_FUENTES
	echo "Vamos a generar el reporte de las mediciones"
#Compilamos	
	gcc -Wall -Wextra -Werror sec_engine.c -o sec_engine
	if [ $? -ne 0 ]; then
    	echo "ERROR CRÍTICO: Falló la compilacion de sec_engine.c" >&2
    	exit 1
	else 
		echo "Se compilo con exito sec_engine.c"
	fi

	cd - &> /dev/null
# Ejecutamos	
	./$RUTA_FUENTES/sec_engine $RUTA_ENTRADA $RUTA_SALIDA
	if [ $? -ne 0 ]; then
    	echo "ERROR CRÍTICO: Falló la ejecución de sec_engine." >&2
    	exit 1
	else 
		echo "Se ejecuto con exito sec_engine"
	fi
# Veamos lo resultados
	echo "VEAMOS EL INFORME DE SEGURIDAD REALIZADO"
	
	cat sec_guard/resultados/informe_seguridad.txt
	

