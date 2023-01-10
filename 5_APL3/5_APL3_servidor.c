/**
# ======================Inicio De Encabezado=======================

# Nombre del script: 5_APL3_servidor.c
# Número de ejercicio: 5
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

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <string.h>
#include <ctype.h>
#include "servidor.h"
#define MAX_QUEUE 1
#define IP INADDR_ANY

void mostrarAyuda();
void error(char* string);

int main(int argc, char const *argv[])
{
    // ---------- VALIDACIÓN DE PARÁMETROS ---------- //

    if (argc < 2)
        error("Cantidad de parámetros incorrecta.");

    if ((strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0))
        mostrarAyuda();
    
    char* puerto_str = (char*) malloc(strlen(argv[1]));

    strcpy(puerto_str, argv[1]);

    int puerto = atoi(puerto_str);

    if (puerto == 0)
        error("Puerto inválido.");

    free(puerto_str);

    // ---------------------------------------------- //

    signal(SIGUSR1, senialSIGUSR1);
    signal(SIGINT, senialSIGINT);

    // CREANDO LA CONEXIÓN ENTRE CLIENTE Y SERVIDOR //

    struct sockaddr_in address;
    int addrlen = sizeof(address);
    int opt = 1;

    // Crea el socket. IPv4, TCP, IP
    if ((server_socket = socket(AF_INET, SOCK_STREAM, 0)) < 0)
        error("Falló al crear el socket.");
    
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = IP;
    address.sin_port = htons(puerto);

    // Etapa de vinculación
    if (bind(server_socket, (struct sockaddr *)&address, sizeof(address)) < 0)
    {
        perror("Falló en la etapa de bind");
        exit(EXIT_FAILURE);
    }

    // Loop hasta que SIGUSR1

    // Etapa de escucha
    if (listen(server_socket, MAX_QUEUE) < 0)
    {
        perror("Falló en la etapa de listen");
        exit(EXIT_FAILURE);
    }

    while (1)
    {
        // Se establece la conexión a traves de un nuevo socket
        if ((new_socket = accept(server_socket, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0)
        {
            perror("Falló en la etapa de accept");
            exit(EXIT_FAILURE);
        }

    // ---------------------------------------------- //
    
        limpiarVector(letras_ingresadas);

        jugando = true;
        fallos = 0;
        win = false;

        unsigned contador_letras = 0;

        palabra_elegida = palabraDesdeTXT("./palabras.txt");
        send(new_socket, palabra_elegida, strlen(palabra_elegida), 0);

        printf("Esperando ingreso de letras por el proceso cliente...\n\n");
        printf("Letras ingresadas: ");
        
        while (jugando == true)
        {   
            read(new_socket, &letra, sizeof(letra));
            
            if (letra == '\0')
                goto salir;

            printf("%c ", toupper(letra));

            // Va imprimiendo lo que tiene en el buffer de salida
            fflush(stdout); 

            letras_ingresadas[contador_letras] = letra;
            contador_letras++;

            if (letraEnPalabra(letra, palabra_elegida) == false || letraRepetida(letra, letras_ingresadas) == true)
                fallos++;

            if (fallos == MAX_FALLOS)
                jugando = false;

            if (palabraAdivinada(palabra_elegida, letras_ingresadas) == true)
            {
                jugando = false;
                win = true;
            }
            
            send(new_socket, &fallos, sizeof(fallos), 0);
            send(new_socket, letras_ingresadas, sizeof(letras_ingresadas), 0);
            send(new_socket, &jugando, sizeof(jugando), 0);
            send(new_socket, &win, sizeof(win), 0);
        }
        
        salir:
        
        printf("\n\nPartida finalizada\n\n");
        jugando = false;

        // ---------------------------------------------- //

        close(new_socket);
    }

    return 0; // Por seguridad
}

void mostrarAyuda()
{
    printf("\nSERVIDOR HANGMAN\n\n");
    printf("Este programa permite que un cliente se conecte a este servidor para jugar al hangman!!\n");
    printf("- Recibe como parámetro el puerto que escuchará\n");
    printf("- Por defecto, la IP del servidor será localhost (127.0.0.1)\n");
    printf("- Usando los parametros -h o --help puede obtener esta ayuda\n");
    printf("- Para cerrar este servidor se debe enviar la senal SIGUSR1.\n");
    printf("\nSINTAXIS\n");
    printf("[Nombre del programa] [Puerto a escuchar]\n\n");
    
    exit(EXIT_SUCCESS);
}

void error(char* string)
{
    printf("%s\n", string);
    exit (EXIT_FAILURE);
}