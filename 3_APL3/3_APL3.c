/**
# ======================Inicio De Encabezado=======================

# Nombre del script: 3_APL3.c
# Número de ejercicio: 1
# Trabajo Práctico: 3
# Entrega: Tercera entrega

# =================================================================

# ~~~~~~~~~~~~~~~~~~~~~~~~ Integrantes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#		Nombre			|		Apellido	|	   DNI
#		Leandro			|		Alfaro		|	43.397.288
#		Lucas 			|		Flores		|	40.125.858
#		Darian			|		Morales		|	43.032.129
#		Matias			|		Galzerano	|	38.067.504
#		Ezequiel		|		Martinez	|	42.775.992
#
# ======================Fin De Encabezado==========================
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h> // Retorno de errores

void mostrarMenu();
void mostrarAyuda();
void error(char* string);

int main(int argc, char const *argv[])
{
    // ---- Validación de parámetros ---- //

    if (argc > 2)
        error("Cantidad de parámetros incorrecta.");
    else if (argc == 2)
    {
        if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)
            mostrarAyuda();
        else
            error("Parámetro incorrecto.");
    }

    // ---------------------------------- //

    int opcion;
    int anio;
    int mes = 0;

    mostrarMenu();

    do
    {
        scanf("%d", &opcion);

        switch (opcion)
        {
        case 1:     // Facturación mensual
            printf("Ingrese el año de facturación: ");
            scanf("%d", &anio);

            printf("Ingrese el mes de facturación (1 a 12): ");
            scanf("%d", &mes);

            // Validación de variable mes

            while (mes <= 0 || mes >= 13)
            {
                printf("Mes incorrecto, volver a ingresar: ");
                scanf("%d", &mes);
            }
            
            break;

        case 2:     // Facturación anual
        case 3:     // Facturación media anual
            printf("Ingrese el año de facturación: ");
            scanf("%d", &anio);
            break;

        case 4:
            break;
        
        default:
            printf("Error, opción incorrecta, vuelva a ingresar: \n");
            opcion = -1;

            // Limpia el buffer
            while (getchar() != '\n');

            break;
        }
    } while (opcion == -1);

    // A partir de acá el usuario ingresó una opción válida

    int fifo;
    float resultado;

    // Si la opción fue salir y no estaba creado el fifo, salir
    if (mkfifo("./fifo", 0666) == 0 && opcion == 4)
    {
        remove("./fifo");
        return 0;
    }

    // Abre el fifo para esperar escribir los datos para el proceso A

    fifo = open("./fifo", O_WRONLY);
    write(fifo, &opcion, sizeof(opcion));

    // Si la opción fue salir, no necesito escribir más datos en el fifo
    if (opcion == 4)
    {
        close(fifo);
        return 0;
    }

    write(fifo, &anio, sizeof(anio));

    // Contemplo la opción de facturación anual (no se pasa un mes)
    if (mes >= 1 && mes <= 12)
        write(fifo, &mes, sizeof(mes));

    close(fifo);

    // Abre el fifo para esperar el resultado del proceso A

    fifo = open("./fifo", O_RDONLY);
    read(fifo, &resultado, sizeof(resultado));
    close(fifo);

    if (resultado == -1)
        error("Error. No se pudo abrir el archivo");

    if (opcion == 1)
        printf("Resultado de la facturación del mes %d del año %d: %.2f\n", mes, anio, resultado);
    else if (opcion == 2)
        printf("Resultado de la facturación del año %d: %.2f\n", anio, resultado);
    else if (opcion == 3)
        printf("Resultado de la facturación media del año %d: %.2f\n", anio, resultado);

    remove("./fifo");
    return 0;
}

void mostrarMenu()
{
    printf("Seleccione una operación a realizar: \n\n");

    printf("1. Facturación mensual.\n");
    printf("2. Facturación anual.\n");
    printf("3. Facturación media anual.\n");
    printf("4. Salir\n\n");
}

void mostrarAyuda()
{
    printf("PROCESO B\n");
    printf("Se calculará el total facturado de distintos archivos.\n");
    printf("El proceso A recibe por parámetro la ruta a la carpeta que contiene los años facturados.\n");
    printf("El proceso B pide una opción para calcular el total facturado:\n");
    printf("\t1- Facturación mensual\n");
    printf("\t2- Facturación anual\n");
    printf("\t3- Facturación media anual (promedio por mes)\n");
    printf("\t4- Salir\n");

    exit (EXIT_SUCCESS);
}

void error(char* string)
{
    printf("%s\n", string);
    exit (EXIT_FAILURE);
}