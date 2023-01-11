# C

### Programas escritos en C para linux

## Generador de grafos:

El programa generará un árbol de procesos de N generaciones (siendo N un valor entero
recibido por parámetro). Cada proceso deberá generar dos procesos hijos por cada generación
Luego de que se haya mostrado la lista de procesos, el usuario debe presionar una tecla para continuar

SINTAXIS:

[nombre del programa] [cantidad de generaciones]

## Operaciones e hilos:

El programa recibe por parámetro un número N (cantidad de iteraciones) y un número
P (nivel de paralelismo). Se desea ejecutar un ciclo de N iteraciones matemáticas para cada número
del 2 al 9. El ciclo está compuesto por las siguientes operaciones.

Suponiendo a la variable M como un número del intervalo mencionado (del 2 a 9) se debe:

  1. Iniciar una variable acumulador con el valor M inicial
  2. En la primera iteración se multiplica el contenido del acumulador por el valor de M
  3. En la segunda iteración se suma el contenido del acumulador por sí mismo
  4. En la tercera iteración se divide el contenido del acumulador por el número N
  5. Repite desde el paso 2 hasta cumplir con los N ciclos.

SINTAXIS:

[nombre del programa] [N] [P]

## Calculo de facturacion:

Se calculará el total facturado de distintos archivos.

El proceso A recibe por parámetro la ruta a la carpeta que contiene los años facturados

El proceso B pide una opción para calcular el total facturado:
  1. Facturación mensual
  2. Facturación anual
  3. Facturación media anual (promedio por mes)
  4. Salir

*Nota: se debe utilizar una estructura FIFO

SINTAXIS:

[A] [directorio facturacion]

[B]

## Ahorcado local

### SERVIDOR HANGMAN:

No recibe parametros de ningun tipo para poder jugar.
Para cerrar este servidor se debe enviar la senal SIGUSR1.

### CLIENTE HANGMAN:

Este programa permite conectarse a un servidor local para jugar al hangman.
No recibe parametros de ningun tipo para poder jugar.

SINTAXIS

[Nombre del programa servidor]

[nombre del programa cliente]

## Ahorcado online


