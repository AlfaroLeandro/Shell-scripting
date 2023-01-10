#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <ctype.h>
#include <signal.h>
#define COL 8
#define ROW 14
#define MAX_FALLOS 6

void imprimirGrafico(unsigned fallos);
void imprimirJuego(unsigned fallos, char* palabra, char* letras_elegidas);
void imprimirPalabra(char* palabra);
char* strupper(char *sptr);
void senialSIGINT();

char letra;
bool jugando = false;
bool win = false;
char letras_ingresadas[30] = {0};
unsigned fallos = 0;

char grafico0[COL][ROW] =
{
    "___________  ",
    "|         |  ",
    "|            ",
    "|            ",
    "|            ",
    "|            ",
    "|____________",
    "|___________|"
};

char grafico1[COL][ROW] =
{
    "___________  ",
    "|         |  ",
    "|         O  ",
    "|            ",
    "|            ",
    "|            ",
    "|____________",
    "|___________|"
};

char grafico2[COL][ROW] =
{
    "___________  ",
    "|         |  ",
    "|         O  ",
    "|         |  ",
    "|            ",
    "|            ",
    "|____________",
    "|___________|"
};

char grafico3[COL][ROW] =
{
    "___________  ",
    "|         |  ",
    "|         O  ",
    "|         |  ",
    "|          \\ ",
    "|            ",
    "|____________",
    "|___________|"
};

char grafico4[COL][ROW] =
{
    "___________  ",
    "|         |  ",
    "|         O  ",
    "|         |  ",
    "|        / \\ ",
    "|            ",
    "|____________",
    "|___________|"
};

char grafico5[COL][ROW] =
{
    "___________  ",
    "|         |  ",
    "|         O  ",
    "|         |\\ ",
    "|        / \\ ",
    "|            ",
    "|____________",
    "|___________|"
};

char grafico6[COL][ROW] =
{
    "___________  ",
    "|         |  ",
    "|         O  ",
    "|        /|\\ ",
    "|        / \\ ",
    "|            ",
    "|____________",
    "|___________|"
};

char (*ptr_graficos[7])[COL][ROW] = 
    {&grafico0, &grafico1, &grafico2, &grafico3, &grafico4, &grafico5, &grafico6};

void senialSIGINT()
{
    letra = '\0';
    return;
}

void imprimirGrafico(unsigned num_grafico)
{
    printf("\e[1;1H\e[2J"); // LIMPIA LA PANTALLA

    for (int i = 0; i < COL; i++)
    {
        for (int j = 0; j < ROW; j++)
            printf("%c", (*ptr_graficos[num_grafico]) [i][j] );
            
        printf("\n");
    }
}

void imprimirJuego(unsigned fallos, char* palabra, char* letras_elegidas)
{
    unsigned j = 0;
    bool coincidencia = false;

    imprimirGrafico(fallos);
    printf("\nPalabra: ");

    // ALGORITMO para imprimir espacios o letras dependiendo de las letras ingresadas

    while (*palabra != '\0')
    {   
        j = 0;
        coincidencia = false;

        while ( *(letras_elegidas + j) != '\0' && coincidencia == false )
        {
            if ( toupper(*(letras_elegidas + j)) == toupper(*palabra) )
                coincidencia = true;

            j++;
        }
        
        if (coincidencia)
            printf("%c ", toupper(*palabra));
        else if (*palabra == ' ')
            printf("  ");
        else
            printf("_ ");
        
        palabra++;
    }
    
    printf("\n\n");
    printf("Cantidad de intentos restantes: %d\n", MAX_FALLOS - fallos);
}

void imprimirPalabra(char* palabra)
{
    printf("\nPalabra: ");
    while (*palabra != '\0')
    {
        printf("%c ", toupper(*palabra));
        palabra++;
    }
}