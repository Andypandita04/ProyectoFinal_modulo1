----------------------
 Iniciando Prueba 3

---Caso A: Eliminando registros de PERMISOS...
------Archivo modificado para Caso A:---------
AuditoriaCursoC
2
DISCO 28
PROCESOS 85
------Archivo modificado para Caso A.---------
Ejecutando sec_engine con categoría PERMISOS vacía (registros: 2)...
INFORME DE MONITOREO
Etiqueta: AuditoriaCursoC
Registros: 2

Categoría DISCO
Cantidad: 1
Suma: 28
Mínimo: 28
Máximo: 28
Promedio: 28.00
Alertas: 0

Categoría PROCESOS
Cantidad: 1
Suma: 85
Mínimo: 85
Máximo: 85
Promedio: 85.00
Alertas: 1

Categoría PERMISOS
Sin datos

Observaciones que cumplen condiciones de alerta: 1.



---Caso B Dejando archivo con 0 registros...
------Archivo modificado para Caso B:---------
AuditoriaCursoC
0
AuditoriaCursoC
2
AuditoriaCursoC
2
------Archivo modificado para Caso B .---------
Ejecutando sec_engine con 0 registros...
Error: Existen registros adicionales a los 0 declarados
INFORME DE MONITOREO
Etiqueta: AuditoriaCursoC
Registros: 2

Categoría DISCO
Cantidad: 1
Suma: 28
Mínimo: 28
Máximo: 28
Promedio: 28.00
Alertas: 0

Categoría PROCESOS
Cantidad: 1
Suma: 85
Mínimo: 85
Máximo: 85
Promedio: 85.00
Alertas: 1

Categoría PERMISOS
Sin datos

Observaciones que cumplen condiciones de alerta: 1.

Prueba 3 finalizada.
