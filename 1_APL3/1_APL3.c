/**
# ======================Inicio De Encabezado=======================

# Nombre del script: 1_APL3.c
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
#include <sys/types.h>
#include <unistd.h>
#include <proc/readproc.h>
#include <signal.h>

#define CHEQUEO 2
#define NIVELES 3
#define INICIO_RAIZ 4

void crear_hijo(char *argv[]);
void mostrar_ayuda();
int es_numero(const char*);
void err_sintax();

int main(int argc, char *argv[]) // 0 n check c pid0 pid1 pid2 .. pidn
{
    int i,
        n;

    if(argc != 1)
    {
        if(strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)
        {
            mostrar_ayuda();
            return 0;
        }
        else if(!es_numero(argv[1]) || (argv[CHEQUEO]==NULL && atoi(argv[1])<=1)) //n<=1
            err_sintax();

        if(argc != 2 && argv[CHEQUEO]!=NULL && strcmp(argv[CHEQUEO], "chequeo de parametros"))
            err_sintax();

        n = atoi(argv[1]);
    }
    else
        err_sintax();

    if( es_numero(argv[NIVELES]) )
    {
        printf("%s%d:", "Proceso \t", getpid());
        for(i = atoi(argv[NIVELES]) - 1; i >= 0; i--)
            printf("\tPid\t%s", *(argv + INICIO_RAIZ + i));
        printf("\n");
    }

    if(n > 1)
    {
        if(argv[CHEQUEO] == NULL)
        {
            char check[25];

            char str_cant_niveles[20];
            char str_pid_raiz[25]; //pid_t tiene a lo sumo 20 caracteres

            sprintf(check, "chequeo de parametros");
            sprintf(str_cant_niveles, "1");
            sprintf(str_pid_raiz, "%d", getpid());

            argv[CHEQUEO] = check;
            argv[NIVELES] = str_cant_niveles;
            argv[INICIO_RAIZ] = str_pid_raiz;
            argv[INICIO_RAIZ + 1] = NULL;
        }
        else
        {
            int cant_niveles = atoi(argv[NIVELES]);
            char str_pid_act[25];

            sprintf(str_pid_act, "%d", getpid());
            *(argv + INICIO_RAIZ + cant_niveles) = str_pid_act;
            sprintf(argv[NIVELES], "%d", cant_niveles + 1);
            *(argv + INICIO_RAIZ + cant_niveles + 1) = NULL; // para evitar los parametros que vienen por default en bash
        }

        sprintf(argv[1], "%d", n - 1); // le resto uno a n
        crear_hijo(argv); // hijo izq
        crear_hijo(argv); // hijo der
    }

    if(getpid()==atoi(argv[INICIO_RAIZ]))
    {
        char* nombre_de_programa;

        getchar();
        printf("\nPresione enter para finalizar el programa\n");
        getchar();

        nombre_de_programa=strrchr(argv[0],'/');

        PROCTAB* proc = openproc(PROC_FILLMEM | PROC_FILLSTAT | PROC_FILLSTATUS);
        proc_t proc_info;
        memset(&proc_info, 0, sizeof(proc_info));

        while (readproc(proc, &proc_info) != NULL) {
            if(strcmp(proc_info.cmd,nombre_de_programa+1)==0 && proc_info.tid!=atoi(argv[INICIO_RAIZ]))
                kill(proc_info.tid,SIGTERM);
        }
    }
    else
    {
        while(1)
            sleep(2);
    }

    return 0;
}

void crear_hijo(char *argv[])
{
    pid_t pid_hijo = fork();

    if(pid_hijo == 0)
        execvp(argv[0],argv);
}

void mostrar_ayuda()
{
    printf("\n\n\n\n\n\n\n\t\t\t%30s\n\n","GENERADOR DE GRAFOS");
    printf("\tEl programa generará un árbol de procesos de N generaciones (siendo N un valor entero\n");
    printf("\tLuego de que se haya mostrado la lista de procesos, el usuario debe presionar una tecla para continuar\n");
    printf("\trecibido por parámetro). Cada proceso deberá generar dos procesos hijos por cada generación.\n");
    printf("\tUsando los parametros -h o --help puede obtener esta ayuda");
    printf("\n\n\t\t\t%25s\n", "SINTAXIS");
    printf("\t\t\t[nombre del programa] [cantidad de generaciones]\n\n");
}

int es_numero(const char *param)
{
    while(*param != '\0')
    {
        if(*param < '0' || *param > '9')
            return 0;
        param++;
    }

    return 1;
}

void err_sintax()
{
    printf("Error de sintaxis: use -h o --help para ver la ayuda\n");
    exit(1);
}
//ps -aef --forest
