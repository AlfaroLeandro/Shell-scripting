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
#include <unistd.h>
#include <sys/time.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <semaphore.h>
#include <pthread.h>

void crear_hijo(char *argv[]);
void mostrar_ayuda();
int es_numero(const char*);
void iniciar_sem();
void *hilof(void *);
void err_sintax();

sem_t mutex,
      mutex_t;
int n,
    M = 2;
pthread_t vec_hilo_m[8][2];
struct timeval t_final_global, t_final_aux;

int main(int argc, char *argv[]) 
{
    int i,
        P;

    pthread_t *ptr_hilos;

    gettimeofday(&t_final_global,NULL);

    if(argc==2 && (strcmp(argv[1],"-h")==0 || strcmp(argv[1],"--help")==0))
    {
        mostrar_ayuda();
        return 0;
    }

    if(argc==3 && es_numero(argv[1]) && es_numero(argv[2])) ///VALIDACIÓN DE N Y P
    {
        n=atoi(argv[1]);
        P=atoi(argv[2]);
        if(n<=0 || P<=0)
            err_sintax();
    }
    else
        err_sintax();

    iniciar_sem();
    gettimeofday(&t_final_global,NULL);
    ///ABRO HILOS
    ptr_hilos=(pthread_t*)malloc(P*sizeof(pthread_t));

    gettimeofday(&t_final_aux,NULL);
    timersub(&t_final_aux,&t_final_global,&t_final_global);
    printf("inicio: %ld.%06ld\n\n",t_final_global.tv_sec,t_final_global.tv_usec);

    for(i = 0; i<P; i++) //inicializo cada hilo
        pthread_create(ptr_hilos + i, NULL, hilof, NULL);

    ///CIERRO HILOS
    for(i = 0; i<P; i++) //inicializo cada hilo
        pthread_join(*(ptr_hilos + i), NULL);

    for(i = 0; i<8; i++)
        printf("\nThread\t%lu: opera sobre el numero %d",vec_hilo_m[i][1],i+2);
    printf("\n");

    printf("\nTIEMPO TOTAL DE EJECUCION: %ld.%06ld\n\n",t_final_global.tv_sec,t_final_global.tv_usec);

    sem_destroy(&mutex);
    sem_destroy(&mutex_t);

    return 0;
}

void iniciar_sem()
{
    if(sem_init(&mutex,0,1) == -1)
    {
        perror("Semaforo mutex");
        exit(3);
    }

    if(sem_init(&mutex_t,0,1) == -1)
    {
        perror("Semaforo mutex_t");
        exit(3);
    }
}

void* hilof(void *arg)
{
    int i,
        paso=2,
        m_act,
        max_num_hilo=0,
        num_hilo=-1;

    long double acumulador=0;

    struct timeval t_ini, t_fin, t_total;

    sem_wait(&mutex); ///INICIO RC

    m_act=M;
    M++;
    if(m_act<=9)
    {
        vec_hilo_m[m_act-2][0]=pthread_self();
        for(i=0; i<m_act-2; i++)
        {
            if(vec_hilo_m[i][0]==pthread_self())
                num_hilo = vec_hilo_m[i][1];

            if(vec_hilo_m[i][1]>max_num_hilo)
                max_num_hilo=vec_hilo_m[i][1];
        }

        if(num_hilo==-1)
            num_hilo=max_num_hilo+1;
    }

    sem_post(&mutex); ///FIN RC

    if(num_hilo==-1)
        return NULL;
    else
        vec_hilo_m[m_act-2][1]=num_hilo;

    gettimeofday(&t_ini,NULL);

    acumulador=M;
    printf("Paso 1: acumulador=%d //contenido de acumulador=%.2Lf\n",m_act,acumulador);
    for(i = 2; i<=n; i++)
    {
        if(paso==2)
        {
            acumulador*=m_act;
            printf("Paso %d: acumulador*=%d //contenido de acumulador=%.2Lf\n",i,m_act,acumulador); ///2
            paso=3;
        }
        else if(paso==3)
        {
            acumulador+=acumulador;
            printf("Paso %d: acumulador+=acumulador //contenido de acumulador=%.2Lf\n",i,acumulador); ///3
            paso=4;
        }
        else
        {
            acumulador/=m_act;
            printf("Paso %d: acumulador/=%d //contenido de acumulador=%.2Lf\n",i,m_act,acumulador); ///4
            paso=2;
        }
    }

    gettimeofday(&t_fin,NULL);
    timersub(&t_fin,&t_ini,&t_total);
    printf("\n Tiempo total operación M=%d es: %ld.%06ld segundos\n------------\n",m_act, t_total.tv_sec, t_total.tv_usec);

    sem_wait(&mutex_t); ///RC2
    timeradd(&t_final_global,&t_total,&t_final_global);
    sem_post(&mutex_t); ///RC2

    hilof(arg);
    return NULL;
}

void mostrar_ayuda()
{
    printf("\n\n\n\n\n\n\n\t\t\t%30s\n\n","OPERACIONES E HILOS");
    printf("\n\tEl programa recibe por parámetro un número N (cantidad de iteraciones) y un número");
	printf("\n\tP (nivel de paralelismo). Se desea ejecutar un ciclo de N iteraciones matemáticas para cada número");
	printf("\n\tdel 2 al 9. El ciclo está compuesto por las siguientes operaciones.");
	printf("\n\tSuponiendo a la variable M como un número del intervalo mencionado (del 2 a 9) se debe:");
	printf("\n\t\t1. Iniciar una variable acumulador con el valor M inicial");
	printf("\n\t\t2. En la primera iteración se multiplica el contenido del acumulador por el valor de M");
	printf("\n\t\t3. En la segunda iteración se suma el contenido del acumulador por sí mismo");
	printf("\n\t\t4. En la tercera iteración se divide el contenido del acumulador por el número N");
	printf("\n\t\t5. Repite desde el paso 2 hasta cumplir con los N ciclos.");
    printf("\n\trecibido por parámetro). Cada proceso deberá generar dos procesos hijos por cada generación.\n");
    printf("\n\tUsando los parametros -h o --help puede obtener esta ayuda");
    printf("\n\n\t\t\t%25s\n", "SINTAXIS");
    printf("\t\t\t[nombre del programa] [N] [P]\n\n");
}

int es_numero(const char *param)
{
    while(*param != '\0')
    {
        if(*param<'0' || *param>'9')
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
