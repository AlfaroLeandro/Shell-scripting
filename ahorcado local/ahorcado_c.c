/**

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
#include <sys/types.h>
#include <proc/readproc.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define PATH "/dev/null"
#define PROYECTO_ID 25051810
#define NUMERO_INTENTOS 5
#define LINEA_INICIO_GRAFICO 1
#define FILAS_GRAFICO 9

void asignar_memoria_compartida();
void jugar(int signum);
void ganar(int signum);
void limpiar_pantalla();
void imprimir_grafico();
void desconectarse();
void mostrar_ayuda();

typedef struct{
    int intentos,
        juego_en_curso;
    pid_t pid_cliente;
    pid_t pid_servidor;
    char palabra[30];
    char c_ingresado;
}t_juego;

t_juego* ptr_juego_act;
int shmid;
char grafico[FILAS_GRAFICO][20]= {" ------------",
                    " |         |",
                    " |          O",
                    " |         / |",
                    " |          |",
                    " |          |",
                    " |         / |",
                    " |",
                    "_|__          "};

int main(int argc,char* argv[])
{
    if(argc==2 && (strcmp(argv[1],"-h")==0 || strcmp(argv[1],"--help")==0))
    {
        mostrar_ayuda();
        return 0;
    }

    asignar_memoria_compartida();

    if(ptr_juego_act->juego_en_curso==1)
    {
        printf("ya hay una partida en curso");
        exit(1);
    }

    signal(SIGUSR1,jugar);
    signal(SIGUSR2,ganar);
    signal(SIGINT,desconectarse);

    ptr_juego_act->pid_cliente=getpid();
    kill(ptr_juego_act->pid_servidor,SIGUSR2);

    while(1)
        sleep(1);

    return 0;
}

void jugar(int signum)
{
    char buffer[100];
    limpiar_pantalla();
    imprimir_grafico();

    if(ptr_juego_act->intentos!=0)
    {
        printf("\t\tCANTIDAD DE INTENTOS DISPONIBLES: %d\n\n",ptr_juego_act->intentos);
        printf("\t\tPALABRA A ADIVINAR: %s\n\n",ptr_juego_act->palabra);
        printf("\tingrese una letra: ");

        do {
        fgets(buffer,100,stdin);
        ptr_juego_act->c_ingresado = buffer[0];
        } while(ptr_juego_act->c_ingresado=='\n');

        kill(ptr_juego_act->pid_servidor,SIGUSR2);
    }
    else
    {
        printf("\n\n\t\tHAS PERDIDO! JUEGO FINALIZADO\n");
        printf("\t\tPALABRA A ADIVINAR: %s\n\n",ptr_juego_act->palabra);
        printf("\npresione Enter para continuar\n");

        getchar();

        exit(0);
    }
}

void ganar(int signum)
{
    limpiar_pantalla();
    imprimir_grafico();

    printf("\t\tCANTIDAD DE INTENTOS DISPONIBLES: %d\n\n",ptr_juego_act->intentos);
    printf("\t\tPALABRA A ADIVINAR: %s\n\n",ptr_juego_act->palabra);

    printf("\n\n\t\tHAS GANADO! JUEGO FINALIZADO\n");
    printf("\npresione Enter para continuar\n");
    getchar();

    exit(0);
}

void asignar_memoria_compartida()
{
    key_t shm_llave = ftok(PATH,PROYECTO_ID);
    shmid = shmget(shm_llave,sizeof(t_juego),IPC_CREAT | 0644);
    struct shmid_ds sh;

    if (shmid == -1)
    {
        perror("Memoria compartida");
        exit(2);
    }

    ptr_juego_act = (t_juego*) shmat(shmid, NULL, 0);
    if(ptr_juego_act == (void*)-1)
    {
        perror("Asignacion de memoria compartida");
        shmctl(shmid, IPC_RMID, NULL);
        exit(2);
    }

    shmctl(shmid,SHM_STAT,&sh);
    if(sh.shm_nattch==1)
    {
        printf("Error, no se detecto el proceso servidor\n");
        shmctl(shmid, IPC_RMID, NULL);
        exit(0);
    }
}

void desconectarse()
{
    ptr_juego_act->pid_cliente=-1;
    printf("\nPartida finalizada\n\n");
    kill(ptr_juego_act->pid_servidor,SIGUSR2);
    exit(0);
}

void limpiar_pantalla()
{
    int i;

    for(i=0; i<5; i++)
        printf("\n\n\n\n\n\n\n\n\n\n");
}

void imprimir_grafico()
{
    int i,
        cant_lineas;

    if(ptr_juego_act->intentos!=0)
    {
        cant_lineas = LINEA_INICIO_GRAFICO + NUMERO_INTENTOS - ptr_juego_act->intentos;
    }
    else
        cant_lineas = FILAS_GRAFICO;

    for(i=0; i<=cant_lineas; i++)
            printf("%s\n",grafico[i]);
    printf("\n\n");
}

void mostrar_ayuda()
{
    printf("\n\n\n\n\n\n\n\t\t\t%30s\n\n","CLIENTE HANGMAN");
    printf("\tEste programa permite conectarse a un servidor local para jugar al hangman!!\n");
    printf("\tNo recibe parametros de ningun tipo para poder jugar.\n");
    printf("\tUsando los parametros -h o --help puede obtener esta ayuda");
    printf("\n\n\t\t\t%25s\n", "SINTAXIS");
    printf("\t\t\t[nombre del programa]\n\n");
}
