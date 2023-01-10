/**
# ======================Inicio De Encabezado=======================

# Nombre del script: 5_APL3_cliente.c
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

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>
#include "cliente.h"

void mostrarAyuda();
void error(char* string);

int main(int argc, char const *argv[])
{
    // ---------- VALIDACIÓN DE PARÁMETROS ---------- //

    if (argc == 2 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0))
        mostrarAyuda();

    if (argc < 3)
        error("Cantidad de parámetros incorrecta.");
    
    char* IP = (char*) malloc(strlen(argv[1]));
    char* puerto_str = (char*) malloc(strlen(argv[2]));

    strcpy(IP, argv[1]);
    strcpy(puerto_str, argv[2]);

    int puerto = atoi(puerto_str);

    if (puerto == 0)
        error("Puerto inválido.");

    free(puerto_str);

    // ---------------------------------------------- //
    // Contemplando una señal mientras se pide stdin  //

    struct sigaction sa;

    sa.sa_handler = senialSIGINT;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGINT, &sa, NULL);

    // CREANDO LA CONEXIÓN ENTRE CLIENTE Y SERVIDOR //

    int sock;
	struct sockaddr_in serv_addr;
    char buffer_palabra[128];
    char buffer_letra;

    // Crea el socket. IPv4, TCP, IP
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("Falló en la creación del socket");
        exit (EXIT_FAILURE);
    } 

    serv_addr.sin_family = AF_INET;
	serv_addr.sin_port = htons(puerto);

    // Convierte la IP de texto a binario y la guarda en la estructura sockaddr_in
    if(inet_pton(AF_INET, IP, &serv_addr.sin_addr) <= 0)
        error("Dirección inválida o no soportada.");

    // Se conecta al socket
    if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        perror("Falló en la etapa de connect");
        exit(EXIT_FAILURE);
    }

    // ---------------------------------------------- //

    unsigned tam_palabra;
    jugando = true;

    tam_palabra = read(sock, buffer_palabra, sizeof(buffer_palabra));
    buffer_palabra[tam_palabra] = '\0';

    while (jugando == true)
    {
        imprimirJuego(fallos, buffer_palabra, letras_ingresadas);

        printf("\nIngrese una letra: ");
        scanf("%c", &letra);

        // si SIGINT (ctrl+c)
        if (letra == '\0')
        {
            send(sock, &letra, sizeof(letra), 0);
            goto salir;
        }

        while (getchar() != '\n'); // Limpia el buffer

        send(sock, &letra, sizeof(letra), 0);

        read(sock, &fallos, sizeof(fallos));
        read(sock, &letras_ingresadas, sizeof(letras_ingresadas));
        read(sock, &jugando, sizeof(jugando));
        read(sock, &win, sizeof(win));

        if (jugando == 0)
            jugando = false;
    }

    imprimirGrafico(fallos);
    imprimirPalabra(buffer_palabra);

    if (win)
        printf("\n\n¡¡¡ MUY BIEN !!! ADIVINASTE LA PALABRA");
    else
        printf("\n\nPerdiste... Lo lamentamos");

    // ---------------------------------------------- //

    salir:

    printf("\n\nPartida finalizada\n\n");

    close(sock);
    free(IP);

    return 0;
}

void mostrarAyuda()
{
    printf("\n\nCLIENTE HANGMAN\n\n");
    printf("Este programa permite conectarse a un servidor local para jugar al hangman!!\n");
    printf("- Recibirá la IP y puerto del servidor a donde deberá conectarse\n");
    printf("- Usando los parametros -h o --help puede obtener esta ayuda\n");
    printf("\nSINTAXIS\n");
    printf("[Nombre del programa] [IP de servidor] [Puerto]\n\n");

    exit (EXIT_SUCCESS);
}

void error(char* string)
{
    printf("%s\n", string);
    exit (EXIT_FAILURE);
}