#!/bin/bash


	echo "Vamos a generar el reporte de las mecionciones"
#Compilamos	
	gcc -Wall -Wextra -Werror sec_engine.c -o sec_engine

# Ejecutamos	
	./sec_engine sec_guard/preparados/mediciones_sec.txt sec_guard/resultados/informe_seguridad.txt
	
# Veamos lo resultados
	echo "VEAMOS EL INFORME DE SEGURIDAD REALIZADO"
	cat sec_guard/resultados/informe_seguridad.txt

