

# Creacion de directorios
	mkdir -p  sec_guard/{capturas,preparados,fuentes,scripts,resultados,evidencias}

# Creacion de archivo donde indican los permisos de directorios y archivos:
	touch evidencias/permissions.txt

# Modificacion de permisos por directorio
# para que ningun grupo pueda hacer modificaciones 
	chmod g-w {capturas,fuentes,resultados,scripts,evidencias,preparados}

# Creacion direcorio pruebas
  	mkdir -p evidencias/pruebas

# Creacion de enlace simbolico a direcotrio pruebas 
 	ln -s symlink_pruebas evidencias/pruebas

# Creacion de archivo "prueba_doc.txt"
 	cd evidencias/pruebas
	 touch prueba_doc.txt
 
	echo "## Informacion del sistema: $(uname -a) ">> prueba_doc.txt
-e
# Creacion de enlace duro a prueba_doc.txt
	 ln prueba_doc.txt hardlink.txt
-e
 # Cambio de nombre de archivo prueba a prueba_doc_version1.txt
	 mv prueba_doc.txt prueba_doc_version1.txt 
