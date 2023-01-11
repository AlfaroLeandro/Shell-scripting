#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdbool.h>
#include <dirent.h> // para abrir un directorio

void error(char* string);
void mostrarAyuda();
bool directorioValido(char* ruta);
float facturacionMensual(char* ruta_mes);
float facturacionAnual(char* ruta_anio, unsigned ruta_anio_length, char meses[][15], bool media_anual);

int main(int argc, char const *argv[])
{
    // ---- Validación de parámetros ---- //

    if (argc != 2)
        error("Cantidad de parámetros incorrecta");

    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)
        mostrarAyuda();

    char* ruta = (char*) malloc(strlen(argv[1]));

    strcpy(ruta, argv[1]);

    // ruta = "./facturacion"

    if (directorioValido(ruta) == false)
        error("Directorio inexistente o sin permisos");

    // ---------------------------------- //

    int fifo;
    int anio;
    int mes;
    int opcion;
    char anio_str[6];
    float resultado;

    char archivo_meses[12][15] = {
        "enero.txt", "febrero.txt", "marzo.txt", "abril.txt", "mayo.txt", "junio.txt", "julio.txt",
        "agosto.txt", "septiembre.txt", "octubre.txt", "noviembre.txt", "diciembre.txt"
    };

    mkfifo("./fifo", 0666);

    // Abre el fifo para esperar la opción elegida en el proceso B y los datos pertinentes

    fifo = open("./fifo", O_RDONLY);
    read(fifo, &opcion, sizeof(opcion));
    read(fifo, &anio, sizeof(anio));

    char* ruta_anio = (char*) malloc(strlen(argv[1]) + 1 + sizeof(anio_str));

    sprintf(anio_str, "%d", anio);
    strcpy(ruta_anio, ruta);
    strcat(ruta_anio, "/");
    strcat(ruta_anio, anio_str);

    // ruta_anio = "./facturacion/2019"

    switch (opcion)
    {
    case 1:     // Facturación mensual
        read(fifo, &mes, sizeof(mes));
        close(fifo);

        char* ruta_mes = (char*) malloc(strlen(argv[1]) + 1 + sizeof(anio_str) + 1 + sizeof(archivo_meses[0]));

        strcpy(ruta_mes, ruta_anio);
        strcat(ruta_mes, "/");
        strcat(ruta_mes, archivo_meses[mes - 1]);

        // ruta_mes= "./facturacion/2019/agosto.txt"

        resultado = facturacionMensual(ruta_mes);

        fifo = open("./fifo", O_WRONLY);
        write(fifo, &resultado, sizeof(resultado));
        close(fifo);

        free(ruta_mes);

        break;

    case 2:     // Facturación anual
        close(fifo);
        
        resultado = facturacionAnual(ruta_anio, strlen(argv[1]) + 1 + sizeof(anio_str), archivo_meses, false);

        fifo = open("./fifo", O_WRONLY);
        write(fifo, &resultado, sizeof(resultado));
        close(fifo);

        break;

    case 3:     // Facturación media anual
        close(fifo);

        resultado = facturacionAnual(ruta_anio, strlen(argv[1]) + 1 + sizeof(anio_str), archivo_meses, true);

        fifo = open("./fifo", O_WRONLY);
        write(fifo, &resultado, sizeof(resultado));
        close(fifo);

        break;

    case 4:
        close(fifo);
        break;
    
    default:
        break;
    }

    free(ruta);
    free(ruta_anio);
    
    remove("./fifo");
    return 0;
}

void error(char* string)
{
    printf("%s\n", string);
    exit (EXIT_FAILURE);
}

void mostrarAyuda()
{
    printf("PROCESO A\n");
    printf("Se calculará el total facturado de distintos archivos.\n");
    printf("El proceso A recibe por parámetro la ruta a la carpeta que contiene los años facturados.\n");
    printf("El proceso B pide una opción para calcular el total facturado:\n");
    printf("\t1- Facturación mensual\n");
    printf("\t2- Facturación anual\n");
    printf("\t3- Facturación media anual (promedio por mes)\n");
    printf("\t4- Salir\n");

    exit (EXIT_SUCCESS);
}

float facturacionMensual(char* ruta_mes)
{
    FILE* file_mes;
    int fifo;
    float resultado_error = -1;
    float auxiliar;
    float resultado = 0;
    char linea[20];

    file_mes = fopen(ruta_mes, "r");

    if (file_mes == NULL)
    {
        // Le paso a B el resultado de error

        fifo = open("./fifo", O_WRONLY);
        write(fifo, &resultado_error, sizeof(resultado_error));
        close(fifo);

        error("Error. No se pudo abrir el archivo");
    }

    // Sumo todos los registros del mes

    while(fgets(linea, sizeof(linea), file_mes) != NULL)
    {
        auxiliar = atof(linea);
        resultado += auxiliar;
    }

    fclose(file_mes);

    return resultado;
}

float facturacionAnual(char* ruta_anio, unsigned ruta_anio_length, char meses[][15], bool media_anual)
{
    FILE* file_mes;
    int fifo;
    float resultado_error = -1;
    float auxiliar;
    float resultado = 0;
    char linea[20];
    unsigned i;
    unsigned contador = 0;

    char* ruta_mes = (char*) malloc(ruta_anio_length + 1 + sizeof(meses[0]));

    for (i = 0; i < 12; i++)
    {
        strcpy(ruta_mes, ruta_anio);
        strcat(ruta_mes, "/");
        strcat(ruta_mes, meses[i]);

        // ruta_mes= "./facturacion/2019/agosto.txt"

        file_mes = fopen(ruta_mes, "r");

        if (file_mes != NULL)
        {
            // Suma todos los registros del mes siempre y cuando
            // exista el archivo en cuestión.

            contador++;

            while(fgets(linea, sizeof(linea), file_mes) != NULL)
            {
                auxiliar = atof(linea);
                resultado += auxiliar;
            }

            fclose(file_mes);
        }
    }

    if (resultado == 0)
    {
        // Le pasa a B el resultado de error

        fifo = open("./fifo", O_WRONLY);
        write(fifo, &resultado_error, sizeof(resultado_error));
        close(fifo);

        error("Error. No se encontraron archivos de facturación");
    }

    free(ruta_mes);

    // Si se quiere sacar un promedio mensual
    
    if(media_anual)
        resultado = resultado / contador;

    return resultado;
}

bool directorioValido(char* ruta)
{
    DIR* dir = opendir(ruta);

    if (dir)
    {
        closedir(dir);
        return true;
    }
    else
        return false;
}