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

errSintax() {
	echo "Error de sintaxis: $1"
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

errPermisos() {
	echo "No se tienen permisos para acceder al archivo: $1"
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

errOtro() {
	echo "$1"
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

mostrarAyuda() {
    echo "AYUDA DEL SCRIPT:"
	echo ""
	echo "El script corrige un archivo de texto plano pasado por parámetro."
    echo "  - Elimina espacios repetidos."
	echo "  - Elimina espacios demás antes de un punto (.), coma (,) o punto"
	echo "    y coma (;)."
	echo "  - Agrega un espacio luego de un punto seguido, coma o punto y"
	echo "    coma (en caso de que no lo tuviera)."
	echo "Finalmente genera dos archivos, uno corregido y otro con el reporte"
	echo "de correcciones realizadas e inconsistencias de signos o paréntesis."
	echo ""
	echo "Sintaxis: [Path al script] -in [archivo]"
	echo ""
	echo "  Ejemplo de llamada:"
	echo "  ./Corrector.sh -in \"./carpeta/archivo texto.txt\" (path al archivo entre comillas)"
	echo ""
	echo "PARÁMETROS:"
	echo "  -h, -help, -?: Muestran ayuda"

        exit 0
}

# -- VALIDACIONES --

if test $# -ne 2 && test $# -ne 1; then
	errSintax "Cantidad de parámetros incorrecta"
elif (test "$1" = "-h" || test "$1" = "-help" || test "$1" = "-?"); then 
	mostrarAyuda
elif test "$1" = "-in"; then

	if [[ -z $2 ]]; then
			errSintax "Faltan parámetros"
	fi

	archivo=$2

	if [[ ! -e "$archivo" ]]; then
		errOtro "Error: no existe la ruta al archivo"
	elif [[ ! -r "$archivo" || ! -w "$archivo" ]]; then
		errPermisos "$archivo"
	elif ! test -f "$archivo"; then 
		errOtro "Error: el archivo \"$archivo\" no es un fichero regular"
	fi

else
        errSintax "Parámetros incorrectos"
fi

# -----------------

# -- Generando nombre de archivos correctos --

fecha=`date +"%Y%m%d%H%M"`
nombreArchivo=`basename "$archivo" | cut -d '.' -f 1`
extension=`basename "$archivo" | cut -d '.' -f 2`
dirDestino=${archivo%"`basename "$archivo"`"}


if [ -z "$extension" ] || test "$nombreArchivo" = "$extension"; then
	nombreArchivoNuevo="$dirDestino$nombreArchivo"_"$fecha"
	nombreArchivoReporte="$dirDestino$nombreArchivo"_"$fecha".log
else
	nombreArchivoNuevo="$dirDestino$nombreArchivo"_"$fecha"."$extension"
	nombreArchivoReporte="$dirDestino$nombreArchivo"_"$fecha".log
fi
# --------------------------------------------

cantCaracInic=`wc -c < "$archivo"`
# Reemplaza todos los espacios duplicados por uno solo
sed 's|  *| |g; s|\t\t*|\t|g' "$archivo" > "$nombreArchivoNuevo"

# Todos los espacios antes de una coma, punto, o punto y coma los borra
sed -i 's| \([,;.]\)|\1|g' "$nombreArchivoNuevo"
cantCaracAux=`wc -c < "$nombreArchivoNuevo"`

# Despues de una coma, un punto o punto y coma, agrega un espacio si necesita
sed -i 's|\([,;.]\)\(\w\)|\1 \2|g' "$nombreArchivoNuevo"
cantCaracAuxF=`wc -c < "$nombreArchivoNuevo"`

# Sumamos las correcciones parciales para hallar las correcciones totales
let cantCaracDif=$cantCaracInic-$cantCaracAux
let cantCaracFinal=$cantCaracDif+$cantCaracAuxF-$cantCaracAux

# Diferencia entre cantidad de signos de apertura y cantidad de signos de cierre
let inconsistencias=`grep -o '[¿¡(]' "$archivo" | wc -l`-`grep -o '[?!)]' "$archivo" | wc -l`

# Removiendo el signo negativo a cantidad de inconsistencias, si tuviera
inconsistencias=`sed 's/-//' <<< $inconsistencias`

# Generando archivo de reporte
echo "Candidad de correcciones realizadas: ""$cantCaracFinal" > "$nombreArchivoReporte"
echo "Cantidad de inconsistencias encontradas: ""$inconsistencias" >> "$nombreArchivoReporte"