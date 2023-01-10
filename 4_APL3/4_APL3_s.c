/**
# ======================Inicio De Encabezado=======================

# Nombre del script: 4_APL3_c.c
# Número de ejercicio: 4
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
#include <sys/types.h>
#include <proc/readproc.h>
#include <signal.h>
#include <sys/time.h>
#include <time.h>
#include <sys/ipc.h>
#include <sys/shm.h>

#define PATH "/dev/null"
#define PROYECTO_ID 25051810
#define NUMERO_INTENTOS 5

int existe_instancia(char *argv[]);
void manejarCliente(int signum);
void cerrarServidor(int signum);
void pedir_asignar_memoria_compartida();
void iniciar_juego();
void continuar_partida();
void ignorar_senial();
void mostrar_ayuda();

typedef struct{
    int intentos,
        juego_en_curso;
    pid_t pid_cliente;
    pid_t pid_servidor;
    char palabra[30];
    char c_ingresado;
}t_juego;

typedef struct {
    t_juego* ptr_juego_act;
    char palabra_completa[30];
    int letras_faltantes;
}t_juego_serv;

t_juego_serv juego;
int shmid,
    cliente_conectado=0;

int main(int argc, char *argv[])
{
    if(argc==2 && (strcmp(argv[1],"-h")==0 || strcmp(argv[1],"--help")==0))
    {
        mostrar_ayuda();
        goto salida;
    }

    if(existe_instancia(argv))
    {
        printf("Error: El servidor ya fue inicializado\n");
        exit(1);
    }

    pedir_asignar_memoria_compartida();
    juego.ptr_juego_act->pid_servidor=getpid();
    juego.ptr_juego_act->juego_en_curso=0;
    printf("Servidor iniciado correctamente\n");
    signal(SIGUSR1, cerrarServidor);
    signal(SIGUSR2, manejarCliente);
    signal(SIGINT, ignorar_senial);

    while(1)
        sleep(1);

salida:
    return 0;
}

int existe_instancia(char *argv[])
{
    char* nombre_de_programa;
    proc_t proc_info;
    PROCTAB* proc = openproc(PROC_FILLMEM | PROC_FILLSTAT | PROC_FILLSTATUS);
    memset(&proc_info, 0, sizeof(proc_info));
    int cont_apariciones=0;

    nombre_de_programa=strrchr(argv[0],'/'); ///Busca '/' en reverso en argv[0]
                                             /// /mnt/d/4s -> /4s
    while (readproc(proc, &proc_info) != NULL) {
        if(strcmp(proc_info.cmd,nombre_de_programa+1)==0)
        {
            cont_apariciones++;
            if(cont_apariciones!=1)
                return 1;
        }
    }

    return 0;
}

void manejarCliente(int signum)
{
    if(juego.ptr_juego_act->juego_en_curso==0)
    {
        printf("\nPartida inicializada\n");
        juego.ptr_juego_act->juego_en_curso=1;
        iniciar_juego();
        printf("palabra: %s\n",juego.palabra_completa);
        kill(juego.ptr_juego_act->pid_cliente,SIGUSR1);
    }
    else
    {
        if(juego.ptr_juego_act->pid_cliente==-1)
        {
            printf("Jugador desconectado\n");
            printf("Partida finalizada\n");
            juego.ptr_juego_act->juego_en_curso=0;
        }
        else
        {
            printf("cliente envio caracter: %c\n",juego.ptr_juego_act->c_ingresado);
            continuar_partida();
        }
    }
}

void continuar_partida()
{
    char *posAnt,
         *posAct;

    posAct=strchr(juego.ptr_juego_act->palabra,juego.ptr_juego_act->c_ingresado);
    if(posAct!=NULL && juego.ptr_juego_act->c_ingresado!='_')
    {
        kill(juego.ptr_juego_act->pid_cliente, SIGUSR1);
        return;
    }


    posAct=strchr(juego.palabra_completa,juego.ptr_juego_act->c_ingresado);
    if(posAct)
    {
        do {
            juego.ptr_juego_act->palabra[posAct - juego.palabra_completa] = *posAct;
            posAnt=posAct;
            posAct=strchr(posAnt+1,juego.ptr_juego_act->c_ingresado);
            juego.letras_faltantes--;
        }while(posAct);

        printf("%s\n",juego.ptr_juego_act->palabra);

        if(juego.letras_faltantes==0) ///GANO
        {
            printf("Partida finalizada\n");
            strcpy(juego.ptr_juego_act->palabra , juego.palabra_completa);
            kill(juego.ptr_juego_act->pid_cliente,SIGUSR2);
            cliente_conectado=0;
            juego.ptr_juego_act->juego_en_curso=0;
            return;
        }
        else
            kill(juego.ptr_juego_act->pid_cliente, SIGUSR1);
    }
    else
    {
        juego.ptr_juego_act->intentos--;
        if(juego.ptr_juego_act->intentos==0)
        {
            printf("Partida finalizada\n");

            strcpy(juego.ptr_juego_act->palabra,juego.palabra_completa);
            cliente_conectado=0;
            juego.ptr_juego_act->juego_en_curso=0;
        }
            kill(juego.ptr_juego_act->pid_cliente, SIGUSR1);
    }
}

void iniciar_juego()
{
    srand(time(NULL));
    int i,
        cantidad_de_palabras,
        num_palabra_a_sacar;

    FILE *arch_palabras = fopen("palabras.txt","rt");

    if(arch_palabras==NULL)
    {
        shmctl(shmid, IPC_RMID, NULL);
        printf("Error: no se econtro el archivo palabras.txt");
        exit(4);
    }

    fscanf(arch_palabras,"%d",&cantidad_de_palabras);
    num_palabra_a_sacar = rand() % cantidad_de_palabras + 1;

    for(i=1; i<=num_palabra_a_sacar; i++)
        fscanf(arch_palabras,"%s",juego.palabra_completa);

    juego.letras_faltantes = strlen(juego.palabra_completa);
    for(i=0; i<juego.letras_faltantes; i++)
        sprintf(juego.ptr_juego_act->palabra+i,"%c",'_');

    juego.ptr_juego_act->intentos=NUMERO_INTENTOS;

    fclose(arch_palabras); ///FALTA: MANEJAR ERROR DE CIERRE DE ARCHIVO
}

void cerrarServidor(int signum)
{
    if(juego.ptr_juego_act->juego_en_curso==1)
    {
        printf("No se puede cerrar el servidor hasta que no termine el juego en curso\n");
        return;
    }

    shmctl(shmid, IPC_RMID, NULL);
    printf("\nCerrando servidor\n");
    exit(0);
}

void pedir_asignar_memoria_compartida()
{
    key_t shm_llave = ftok(PATH,PROYECTO_ID);

    if ((shmid = shmget(shm_llave,sizeof(t_juego),IPC_CREAT | 0644)) == -1)
    {
        perror("Memoria compartida");
        exit(2);
    }

    if((juego.ptr_juego_act = (t_juego*) shmat(shmid, NULL, 0)) == (void*)-1)
    {
        perror("Asignacion de memoria compartida");
        shmctl(shmid, IPC_RMID, NULL);
        exit(2);
    }
}

void ignorar_senial()
{
    return;
}

void mostrar_ayuda()
{
    printf("\n\n\n\n\n\n\n\t\t\t%30s\n\n","SERVIDOR HANGMAN");
    printf("\tEste programa permite que un cliente se conecte a este servidor para jugar al hangman!!\n");
    printf("\tNo recibe parametros de ningun tipo para poder jugar.\n");
    printf("\tUsando los parametros -h o --help puede obtener esta ayuda");
    printf("\tPara cerrar este servidor se debe enviar la senal SIGUSR1.\n");
    printf("\n\n\t\t\t%25s\n", "SINTAXIS");
    printf("\t\t\t[nombre del programa]\n\n");
}

