#!/bin/bash

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

funcA() {
    echo "Error. La sintaxis del script es la siguiente:"
    echo "$0 [directorio] [cantDeSubdir]" 
	echo "ej: $0 directorio 5" 
}
funcB() {
    echo "Error. $1 No es un directorio" 
}
funcC() {
    if [[ ! -d $2 ]]; then
        funcB
    fi
}
funcC $# $1 $2 $3 $4 $5

LIST=$(ls -d $1*/) #el directorio lo termina con */ -> /dir1*/
ITEMS=() #crea un array
for d in $LIST; do
    ITEM="`ls $d | wc -l`-$d" #cuenta la cantidad de elementos que tiene el directorio y le agrega -nombreDirectorio al final
    ITEMS+=($ITEM) #Se lo agrega en una nueva posicion al array
done

IFS=$'\n' sorted=($(sort -rV -t '-' -k 1 <<<${ITEMS[*]})) #Indica que el caracter de separación es \n
#r-Ordena en reverso, V-indica que solo se ordenan numeros, t-usando el '-' como campo separador
#k 1- comparando solo por el campo 1, tomando a todo el contenido de ITEMS
CANDIDATES="${sorted[*]:0:$2}" #Crea un nuevo array donde se guardan una cantidad $2 (segundo parámetro enviado en el script) de directorios ordenados
unset IFS
echo "Subdirectorios ordenados por cantidad de ficheros que contienen: " 
printf "%s\n" "$(cut -d '-' -f 2 <<<${CANDIDATES[*]})" #Se queda solo con el ultimo campo, que contiene el nombre de dir

#1- El script tiene como objetivo a partir de un directorio y un numero n dados, mostrar los n subdirectorios ordenados
#   de mayor a menor según la cantidad de elementos que contienen en su interior.
#   Recibe un directorio y el numero de subdirectorios finales a mostrar.

#4- funcA: mostrarErrorSintaxis
#   funcB: mostrarNoEsDirectorio
#   funcC: comprobarSiEsDIrectorio

#5- Agregaria varias cosas, primero y principal, si hubo algun error que no se ejecute la parte que tiene la logica del
#   programa, ya que no tiene sentido ejecutar esas instrucciones si no se pudo validar que realmente se trataba de un 
#   directorio. Validaria si se envio un segundo parametro numerico y finalmente si hubo algun error, llamaria a funcA
#   para poder mostrarle al usuario la sintaxis del programa

#6- La variable $# indica la cantidad de parametros que se pasaron, sin contar $0,
#   otras variables parecidas son $@ o $* que listan todos los parametros

#7- Comillas simples: Texto fuerte, el Shell no reemplaza las variables dentro.
#   Comillas dobles: Texto débil, las variables dentro son reemplazadas por sus valores.
#   Comillas francesas: Ejecución de comandos, primero las variables se reemplazan y luego se ejecuta el comando.
#   luego, su salida se guarda en la variable.

#8- Si se ejecuta el script sin parametros, se muestra el mensaje de error de que no se paso un directorio por parametro.
#   Luego muestra el mensaje del final en el que se indica el resultado del script, como no se almaceno nada
#   en la variable CANDIDATES no se muestra nada al final
