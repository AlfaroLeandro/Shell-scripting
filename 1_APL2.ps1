# ======================Inicio De Encabezado=======================

# Nombre del script: 1_APL2.ps1
# Número de ejercicio: 1
# Trabajo Práctico: 2
# Entrega: Cuarta entrega

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

# Explicado en punto 5
[CmdletBinding()]

Param (

    # El script recibe dos parámetros (dirAnalizar y cantDirMostrar), ninguno de los dos
    # son obligatorios, si no se escribe "-dirAnalizar" para pasar este dato por
    # parámetro, se lo toma por default en la segunda posición.
    # dirAnalizar debe ser un directorio válido 

    [Parameter(Position = 1, Mandatory = $false)]
    [ValidateScript( { Test-Path -PathType Container $_ } )]
    [String] $dirAnalizar,
    [int] $cantDirMostrar = 0
)

# $LIST contendrá todos los directorios que se encuentren en el path pasado por parámetro
$LIST = Get-ChildItem -Path $dirAnalizar -Directory

$ITEMS = ForEach ($ITEM in $LIST) {

    # obtiene la cantidad de elementos en los subdirectorios de $LIST
    $COUNT = (Get-ChildItem -Path $ITEM).Length
    
    # @{} == HASHTABLE
    $props = @{ 
        name = $ITEM
        count = $COUNT
    }

    # Crea un objeto que contiene el hashmap $props, usando las key como encabezados
    # y los valores como datos relacionados, luego es retornado al terminar el for.
    New-Object psobject -Property $props
}

# A este punto, $ITEMS es un objeto que tiene hashtables, como encabezados las
# claves "name" y "count", con los datos como filas.

# A $ITEMS lo ordena por cantidad de elementos de forma descendente tomando
# los primeros $cantDirMostrar de la lista ordenada y el campo nombre.
$CANDIDATES = $ITEMS | Sort-Object -Property count -Descending | Select-Object -First $cantDirMostrar | Select-Object -Property name

Write-Output "Los subdirectorios con mas archivos son: " # COMPLETAR

# Imprime $CANDIDATES sin encabezados de tabla
$CANDIDATES | Format-Table -HideTableHeaders

<#
1- El script tiene como objetivo que a partir de un directorio y un numero n dados,
mostrar los n subdirectorios ordenados de mayor a menor según la cantidad de elementos
que contienen en su interior.
Recibe como parámetros un directorio y el numero de subdirectorios finales a mostrar.
Renombramos los parámetros $param1 como $dirAnalizar y $param2 como $cantDirMostrar.

4- Agregaría 3 validaciones:
    - Que los parámetros dirAnalizar y cantDirMostrar sean obligatorios, ya que si no
      se los pasa el script no tiene funcionalidad.
    - Agregaría que cantDirMostrar sea un entero positivo.
    - Que el parámetro dirAnalizar tenga permisos de lectura.
No se encontraron errores en el script, funciona como corresponde.

5-[CmdletBinding()] permite varias cosas:
    - Crear funciones avanzadas las cuales actúan como cmdlets (comandos que participan
      en la semántica de la pipeline)
    - La habilidad de usar los commonParameters en el script, algunos son:
      Debug (db), Verbose (vb), ErrorVariable (ev), etc. con sus respectivas funciones,
      como Write-Debug, Write-Verbose, etc.
    - La posibilidad de usar -WhatIf y -Confirm, para mayor interactividad con el usuario
      al momento de incluir [CmdletBinding()] en una función.

6- Los tipos de comillas son: comillas dobles (“), comillas simples (‘) y acento grave (`):
    - Las comillas dobles, también denominadas comillas débiles, permiten utilizar texto e
      interpretar variables al mismo tiempo.
    - Las comillas simples, también denominadas comillas fuertes, generan que el texto
      delimitado entre ellas se utilice de forma literal, lo que evita que se interpreten las
      variables. 
    - El acento grave, es el carácter de escape para evitar la interpretación de los
      caracteres especiales, como por ejemplo el símbolo $.

7- Si se ejecuta el script sin ningún parámetro, muestra el mensaje del final en el que se
indica el resultado del script, y, como $cantDirMostrar es igual a cero, no se almacenó nada
en la variable CANDIDATES y por lo tanto, no se muestra nada al final.
#>