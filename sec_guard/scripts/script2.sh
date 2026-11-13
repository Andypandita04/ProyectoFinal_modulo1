#!/bin/bash
arch_tar="paquete_auditoria.tar.gz"
RUTA_SEC="sec_guard"
RUTA_CAPTURAS="capturas/estaticos"
RUTA_SCRIPTS="sec_guard/scripts"
# Creo capturas/estatico
	mkdir -p "$RUTA_SEC"/capturas/estaticos
	#tree "$RUTA_SEC"/capturas


# Checo su existencia
if [ ! -f "$arch_tar" ];then
	echo "Error: no existe el archivo tar :$arch_tar"
	exit 1
fi

# veirfico su integridad (que no esten corruptos)

if tar -tf  "$arch_tar" &> /dev/null   ;then
	echo "El archivo .tar  no esta corrupto"
else
	echo "El archivo .tar  esta corrupto, interrumpiendo extracción"
	exit 1
fi

#pwd

# Extraigo los el contenido en /capturas/estaticos

	echo "Vamos a extraer los documento del tar en /sec_guard/capturas/estaticos:"
	tar -xzvf "$arch_tar" -C "$RUTA_SEC/$RUTA_CAPTURAS"

	echo "Se entrajeron con exito!!" 

RUTA_EST="sec_guard/capturas/estaticos"
RUTA_PREP="$RUTA_SEC/preparados"

# Vamos a procesar lo archivos

echo -e  "\n Vamos a procesar lo archivos"

# Aqui habilito el puerto 20
# habilito directivas Hostkey
# elimino todas las lineas comentadas y las vacias
# Y envio a directoio "Preparados"

echo "Procesando sshd_config"

	 sed -e 's/#Port 22/Port 8080/' \
	 -e 's/#HostKey/Hostkey/' \
	 -e '/#/d'  \
	 -e '/^$/d' \
	 "$RUTA_EST"/sshd_config > "$RUTA_PREP/sshd_activo.txt"

# Vamos a procesar secure.log
	echo "Procesando secure.log"

	sed -n '/new user/p' "$RUTA_EST"/secure.log \
       	| awk '{print $9 $10}' \
	> "$RUTA_PREP/usuarios_creados.txt"

# Vamos a procesar conexiones_syn.txt
	echo "Procesando net_traffic.log"
	cd "$RUTA_EST"

# Capturo ip origen y puerto:
# desde net_traffic.log filtro el trafico tcp
# e imprimo la columan donde se encuentra la ip.puerto del origen 
	cat net_traffic.log \
	| grep -i  "Flags \[S\]" \
       	| awk ' {print "Origen:  "$2}' \
       	> origenYpuerto.txt

# Capturo puerto
	cat origenYpuerto.txt \
	| grep -o '.\([0-9][0-9][0-9][0-9][0-9]*\)'\
       	| sed 's/\./Puerto:  /'\
       	> puertoOrigen.txt

# Capturo solo ip origen
	cat origenYpuerto.txt \
	| grep -o '[a-zA-Z]*:  \([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)'\
       	> origen.txt 


# Capturo ip destino y puerto 
	cat net_traffic.log \
	| grep -i  "Flags \[S\]" \
       	| awk ' {print "Destino:  "$4}' \
       	> destinoYpuerto.txt

# Capturo puerto
	cat destinoYpuerto.txt  | grep -o '\.\([0-9]*\):' | sed -e 's/\./Puerto:  /' -e 's/\://g' -e 's/Puerto/Puerto: /'  > puertoDestino.txt

# Capturo solo ip destino
	cat destinoYpuerto.txt  | grep -o '[a-zA-Z]*: *\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\|[a-z0-19]*::[0-9]*\)' > destino.txt

# Junto todo en un archivp
	paste origen.txt puertoOrigen.txt destino.txt puertoDestino.txt > conexiones_syn.txt

# Borro los archivos
 	rm origen* destino* puerto*

# Mando archivo a 
	cd - &> /dev/null
	#pwd
	mv "$RUTA_EST"/conexiones_syn.txt "$RUTA_PREP" 
	#tree "$RUTA_SEC"

	echo "Los archivos procesados ya se encuentras en $RUTA_PREP"

	bash "$RUTA_SCRIPTS/capturas.sh"
	if [ $? -ne 0 ]; then
    	echo "ERROR CRÍTICO: Falló la ejecución de $RUTA_SCRIPTS/capturas.sh. Abortando flujo." >&2
    	exit 1
	fi

	bash "$RUTA_SCRIPTS/normalizacion.sh"
	if [ $? -ne 0 ]; then
    	echo "ERROR CRÍTICO: Falló la ejecución de $RUTA_SCRIPTS/normalizacion.sh. Abortando flujo." >&2
    	exit 1
	fi




