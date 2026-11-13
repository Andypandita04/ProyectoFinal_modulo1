#!/bin/bash
rm link_record.txt 
echo "Copiando metadatos de archivos a link_record.txt"
for archivo in ./*;do
	# verifico si es un si es un archivo
	if [ -f $archivo ];then
		echo "Copiando . . ."
                echo "              ------------------------------  
                --Archivo: $archivo   
                Dueño: $(stat -c %U  $archivo)   
                Permisos : $(ls -li $archivo  | awk '{print $2}')  
                Tamaño : $(du -h  $archivo  | awk '{print $1}')  
                Inodo: $(stat -c %i  $archivo)   
                Marcas de tiempo:                                    
                Creacion : $(stat -c %w  $archivo)
                Acceso : $(stat -c %x  $archivo)
                Modificacion: $(stat -c %y  $archivo)
                Modificacion de metadatos: $(stat -c %z  $archivo)  
              ------------------------------ " >> link_record.txt
	fi
done;
echo "Todo los datos copiados, CHECANDO ARCHIVO link_record.txt"
cat link_record.txt





