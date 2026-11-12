#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Estructura para guardar las mediciones por categoria (DISCO, PROCESOS, PERMISOS)
struct Mediciones {
    char categoria[16]; // nombre
    int *valores;       // arreglo dinamico
    int cantidad;       // cantidad de mediciones
};

// Estructura para el resumen por categoria
struct ResumenCategoria {
    char categoria[16];
    int cantidad;
    int suma;
    int minimo;
    int maximo;
    double promedio;
    int alertas;
};

// Prototipos de funciones
int calcular_suma(const int *valores, int cantidad);
int calcular_minimo(const int *valores, int cantidad);
int calcular_maximo(const int *valores, int cantidad);
double calcular_promedio(int suma, int cantidad);
int calcular_alertas(const char *categoria, const int *valores, int cantidad);
void Calculos(const int *valores, int cantidad, struct ResumenCategoria *res);
void liberar_todo(struct Mediciones *disco, struct Mediciones *procesos, struct Mediciones *permisos);
int guardar_medicion(const char *cat, int val,
                     struct Mediciones *disco,
                     struct Mediciones *procesos,
                     struct Mediciones *permisos);

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Uso: %s <archivo_entrada> <archivo_salida>\n", argv[0]);
        return 1;
    }
    const char *ruta_entrada = argv[1];
    const char *ruta_salida = argv[2];

    FILE *entrada = fopen(ruta_entrada, "r");
    if (entrada == NULL) {
        printf("No se pudo abrir el archivo de entrada\n");
        return 1;
    }

    // Valido que la longitud de la etiqueta
    char buffer_etiqueta[64];
    char etiqueta[32];
    if (fscanf(entrada, "%63s", buffer_etiqueta) != 1 || strlen(buffer_etiqueta) > 31) {
        printf("Etiqueta invalida o mayor a 31 caracteres\n");
        fclose(entrada);
        return 1;
    }
    // Guardo en etiqueta la cadena del archivo
    strcpy(etiqueta, buffer_etiqueta);

    // Verifico el numero de registros
    int total = 0; // cantidad de registros
    if (fscanf(entrada, "%d", &total) != 1 || total < 0 || total > 200) {
        printf("Cantidad de registros invalida (debe estar entre 0 y 200)\n");
        fclose(entrada);
        return 1;
    }

    // Inicializo estructuras mediciones
    struct Mediciones disco = {"DISCO", NULL, 0};
    struct Mediciones procesos = {"PROCESOS", NULL, 0};
    struct Mediciones permisos = {"PERMISOS", NULL, 0};

    // Reservar memoria dinamica solo si total > 0
    if (total > 0) {
        disco.valores = malloc((size_t)total * sizeof(int));
        procesos.valores = malloc((size_t)total * sizeof(int));
        permisos.valores = malloc((size_t)total * sizeof(int));

        if (disco.valores == NULL || procesos.valores == NULL || permisos.valores == NULL) {
            printf("No se pudo reservar memoria dinamica\n");
            liberar_todo(&disco, &procesos, &permisos);
            fclose(entrada);
            return 1;
        }
    }

    // Aqui inicializo mis estructuras de resumen por categoria
    struct ResumenCategoria res_disco = {"DISCO", 0, 0, 0, 0, 0.0, 0};
    struct ResumenCategoria res_procesos = {"PROCESOS", 0, 0, 0, 0, 0.0, 0};
    struct ResumenCategoria res_permisos = {"PERMISOS", 0, 0, 0, 0, 0.0, 0};

    // Leer los 'total' registros y clasificarlos por categoria
    char cat_leida[32];
    int valor_leido = 0;
    for (int i = 0; i < total; i++) {
        // Aqui leo los datos categoria y valor
        if (fscanf(entrada, "%31s %d", cat_leida, &valor_leido) != 2) {
            printf("Error de formato o faltan registros en linea %d\n", i + 1);
            liberar_todo(&disco, &procesos, &permisos);
            fclose(entrada);
            return 1;
        }

        // Valido la categoria, el rango y lo guardo
        int estado = guardar_medicion(cat_leida, valor_leido, &disco, &procesos, &permisos);
        if (estado != 1) {
            printf("Error en registro %d (%s %d): categoria o rango invalido\n",
                   i + 1, cat_leida, valor_leido);
            liberar_todo(&disco, &procesos, &permisos);
            fclose(entrada);
            return 1;
        }
    }

    // Vamos a comprobar que no existan registros de mas
    char sobrante[16];
    if (fscanf(entrada, "%15s", sobrante) == 1) {
        printf("Error: Existen registros adicionales a los %d declarados\n", total);
        liberar_todo(&disco, &procesos, &permisos);
        fclose(entrada);
        return 1;
    }

    if (fclose(entrada) != 0) {
        printf("Error al cerrar el archivo de entrada\n");
        liberar_todo(&disco, &procesos, &permisos);
        return 1;
    }

    // Realizo los calculos para cada categoria
    Calculos(disco.valores, disco.cantidad, &res_disco);
    Calculos(procesos.valores, procesos.cantidad, &res_procesos);
    Calculos(permisos.valores, permisos.cantidad, &res_permisos);

    // Escribo los resultados en el archivo de salida
    FILE *salida = fopen(ruta_salida, "w");
    if (salida == NULL) {
        printf("No se pudo abrir el archivo de salida\n");
        liberar_todo(&disco, &procesos, &permisos);
        return 1;
    }

    struct ResumenCategoria *lista_resumen[3] = {&res_disco, &res_procesos, &res_permisos};
    int alertas_totales = res_disco.alertas + res_procesos.alertas + res_permisos.alertas;

    if (fprintf(salida, "INFORME DE MONITOREO\n") < 0 ||
        fprintf(salida, "Etiqueta: %s\n", etiqueta) < 0 ||
        fprintf(salida, "Registros: %d\n\n", total) < 0) {
        printf("Error al escribir encabezado en el archivo de salida\n");
        fclose(salida);
        liberar_todo(&disco, &procesos, &permisos);
        return 1;
    }

    for (int i = 0; i < 3; i++) {
        struct ResumenCategoria *r = lista_resumen[i];
        if (fprintf(salida, "Categoría %s\n", r->categoria) < 0) {
            fclose(salida);
            liberar_todo(&disco, &procesos, &permisos);
            return 1;
        }

        if (r->cantidad == 0) {
            if (fprintf(salida, "Sin datos\n\n") < 0) {
                fclose(salida);
                liberar_todo(&disco, &procesos, &permisos);
                return 1;
            }
        } else {
            if (fprintf(salida, "Cantidad: %d\n", r->cantidad) < 0 ||
                fprintf(salida, "Suma: %d\n", r->suma) < 0 ||
                fprintf(salida, "Mínimo: %d\n", r->minimo) < 0 ||
                fprintf(salida, "Máximo: %d\n", r->maximo) < 0 ||
                fprintf(salida, "Promedio: %.2f\n", r->promedio) < 0 ||
                fprintf(salida, "Alertas: %d\n\n", r->alertas) < 0) {
                printf("Error al escribir categoria %s\n", r->categoria);
                fclose(salida);
                liberar_todo(&disco, &procesos, &permisos);
                return 1;
            }
        }
    }

    if (fprintf(salida, "Observaciones que cumplen condiciones de alerta: %d.\n", alertas_totales) < 0) {
        fclose(salida);
        liberar_todo(&disco, &procesos, &permisos);
        return 1;
    }

    if (fclose(salida) != 0) {
        printf("Error al cerrar el archivo de salida\n");
        liberar_todo(&disco, &procesos, &permisos);
        return 1;
    }

    // Liberar memoria dinamica
    liberar_todo(&disco, &procesos, &permisos);
    return 0;
}

/* ===================================
 * Funciones
 * =================================== */

int calcular_suma(const int *valores, int cantidad) {
    int suma = 0;
    for (int i = 0; i < cantidad; i++) {
        suma += valores[i];
    }
    return suma;
}

int calcular_minimo(const int *valores, int cantidad) {
    int min = valores[0];
    for (int i = 1; i < cantidad; i++) {
        if (valores[i] < min) {
            min = valores[i];
        }
    }
    return min;
}

int calcular_maximo(const int *valores, int cantidad) {
    int max = valores[0];
    for (int i = 1; i < cantidad; i++) {
        if (valores[i] > max) {
            max = valores[i];
        }
    }
    return max;
}

double calcular_promedio(int suma, int cantidad) {
    if (cantidad == 0) {
        return 0.0;
    }
    return (double)suma / cantidad;
}

// IMPLEMENTACION FALTANTE: Ajusta los umbrales segun los requisitos de tu proyecto
int calcular_alertas(const char *categoria, const int *valores, int cantidad) {
    int alertas = 0;
    for (int i = 0; i < cantidad; i++) {
        if (strcmp(categoria, "DISCO") == 0 && valores[i] >= 80) {
            alertas++;
        } else if (strcmp(categoria, "PROCESOS") == 0 && valores[i] >= 1000) {
            alertas++;
        } else if (strcmp(categoria, "PERMISOS") == 0 && valores[i] >= 50) {
            alertas++;
        }
    }
    return alertas;
}

void Calculos(const int *valores, int cantidad, struct ResumenCategoria *res) {
    res->cantidad = cantidad;
    if (cantidad == 0 || valores == NULL) {
        res->suma = 0;
        res->minimo = 0;
        res->maximo = 0;
        res->promedio = 0.0;
        res->alertas = 0;
        return;
    }

    res->suma = calcular_suma(valores, cantidad);
    res->minimo = calcular_minimo(valores, cantidad);
    res->maximo = calcular_maximo(valores, cantidad);
    res->promedio = calcular_promedio(res->suma, cantidad);
    res->alertas = calcular_alertas(res->categoria, valores, cantidad);
}

// Funcion para liberar memoria dinamica de las estructuras Mediciones
void liberar_todo(struct Mediciones *disco, struct Mediciones *procesos, struct Mediciones *permisos) {
    free(disco->valores);
    free(procesos->valores);
    free(permisos->valores);
    disco->valores = NULL;
    procesos->valores = NULL;
    permisos->valores = NULL;
}

// Funcion auxiliar: valida rango y guarda el dato en su estructura correspondiente
int guardar_medicion(const char *cat, int val,
                     struct Mediciones *disco,
                     struct Mediciones *procesos,
                     struct Mediciones *permisos) {
    if (strcmp(cat, "DISCO") == 0) {
        if (val < 0 || val > 100) return 0; // Fuera de rango
        disco->valores[disco->cantidad++] = val;
        return 1;
    }
    if (strcmp(cat, "PROCESOS") == 0) {
        if (val < 0 || val > 2000) return 0;
        procesos->valores[procesos->cantidad++] = val;
        return 1;
    }
    if (strcmp(cat, "PERMISOS") == 0) {
        if (val < 0 || val > 200) return 0;
        permisos->valores[permisos->cantidad++] = val;
        return 1;
    }
    return -1; // Categoria desconocida
}