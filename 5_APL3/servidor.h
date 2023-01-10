#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <stdbool.h>
#include <signal.h>
#define MAX_FALLOS 6

char* palabraDesdeTXT(char* txt_file);
bool letraEnPalabra(char letra, char* palabra);
bool palabraAdivinada(char* palabra, char* letras_ingresadas);
bool letraRepetida(char letra, char* letras_ingresadas);
void limpiarVector(char* vector);
void senialSIGUSR1();
void senialSIGINT();

char palabra[128];
char* palabra_elegida;
char letras_ingresadas[30] = {0};
char letra;
bool jugando = false;
bool win = false;
unsigned fallos = 0;
int server_socket, new_socket;

void senialSIGUSR1()
{
    if (jugando == true)
    {
        printf("\n\nPartida en curso, no se puede finalizar con SIGUSR1.\n\n");
        printf("Letras ingresadas: ");
    }
    else
    {
        close(server_socket);
        close(new_socket);
        exit(EXIT_SUCCESS);
    }
}

void senialSIGINT()
{
    return;
}

char* palabraDesdeTXT(char* txt_file)
{
    FILE* ptr_txt;
    int i = 0;
    int ran = 0;

    ptr_txt = fopen(txt_file, "r");
    
    srand(time(NULL));

    if (!ptr_txt)
    {
        printf("No se pudo abrir el archivo de palabras.\n");
        exit(EXIT_FAILURE);
    }

    for (; fgets(palabra, sizeof(palabra), ptr_txt); i++)
    ;

    ran = rand() % i;

    rewind(ptr_txt);

    for (i = 0 ; i < ran ; i++)
        fgets(palabra, sizeof(palabra), ptr_txt);

    // Reemplazando el salto de línea por fin de cadena (\0)
    if (palabra[strlen(palabra) - 1] == '\n')
        palabra[strlen(palabra) - 1] = '\0';
    
    fclose(ptr_txt);

    return palabra;
}

bool letraEnPalabra(char letra, char* palabra)
{
    while (*palabra != '\0')
    {
        if (toupper(letra) == toupper(*palabra))
            return true;

        palabra++;
    }

    return false;
}

bool letraRepetida(char letra, char* letras_ingresadas)
{
    while (*letras_ingresadas != '\0' && *(letras_ingresadas + 1) != '\0')
    {
        if ( toupper(letra) == toupper(*letras_ingresadas))
        {
            return true;
        }

        letras_ingresadas++;
    }

    return false;
}

bool palabraAdivinada(char* palabra, char* letras_ingresadas)
{
    bool coincidencia = false;
    unsigned i = 0;

    while (*palabra != '\0')
    {
        coincidencia = false;
        i = 0;

        if (*palabra == ' ') // Ignora espacios
            palabra++;

        while (*(letras_ingresadas + i) != '\0')
        {
            if (toupper(*(letras_ingresadas + i)) == toupper(*palabra))
                coincidencia = true;

            i++;
        }
        
        if (coincidencia == false)
            return false;
        
        palabra++;
    }

    return true;
}

void limpiarVector(char* vector)
{
    while (*vector != '\0')
    {
        *vector = '\0';
        vector++;
    }
}