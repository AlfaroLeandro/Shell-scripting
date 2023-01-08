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
	echo "Ingrese los parametros -h -help o -? para ver la ayuda"
	exit 1 # Salida por falta de parametro
}

errAcceso() {
	echo "Error: $1"
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

mostrarAyuda() {
	echo "AYUDA DEL SCRIPT:"
	echo ""
	echo "Este script procesa todos los CSV subidos (uno por mesa de examen) y"
	echo "genera un archivo JSON con las notas de los alumnos que rindieron final."
	echo "	-> Un ejercicio bien (B) vale el ejercicio entero."
	echo "	-> Un ejercicio regular (R) vale medio ejercicio."
	echo "	-> Un ejercicio mal (M) no suma puntos a la nota final"
	echo ""
	echo "Sintaxis: [Path al script] --notas [dirNotas] --salida [JSONDestino]"
	echo ""
	echo "PARÁMETROS:"
	echo ""
	echo "	--notas: Directorio en el que se encuentran los archivos CSV."
	echo "	--salida: Ruta del archivo JSON a generar (incluye nombre del archivo)."
	echo "	-h o -? o -help: muestra esta ayuda"

	exit 0
}

ejecParametros() {

	# Hay dos opciones: que el primer parámetro sea --notas y el tercero
	# --salida, o que el primero sea --salida y el tercero --notas

	if [[ $1 = "--notas" && $3 = "--salida" ]]; then
		dirOrigen=$2
		archDestino=$4
	elif [[ $1 = "--salida" && $3 = "--notas" ]]; then
		dirOrigen=$4
		archDestino=$2
	else
		errSintax "Definición de parámetros incorrecta"
	fi

	# Si no hay parámetros en --notas o en --salida, es error de sintaxis
	if [[ -z $archDestino || $dirOrigen = "--salida" ]]; then
		errSintax "Definición de parámetros incorrecta"
	fi

	if [[ ! -d $dirOrigen ]]; then
		errAcceso "No se encuentra el directorio $dirOrigen"
	elif [[ ! -r $dirOrigen || ! -w $dirOrigen ]]; then
		errAcceso "No se tienen permisos para acceder al directorio $dirOrigen"
	fi

	# Si se pasa un path sin ./ al principio, agregarlo

	if test `echo $archDestino | grep -o "/" | wc -l` -eq 0; then
		archDestino="./$archDestino"
	fi

	# Obtiene el directorio donde va a estar ubicado el archivo
	pathDestino=${archDestino%/*}
	# Obtiene el nombre del archivo
	nombreArchivo=${archDestino##*/}

	if [[ ! -e $pathDestino ]]; then
		errAcceso "Ruta inválida $pathDestino"
	elif [[ ! -r $pathDestino || ! -w $pathDestino ]]; then
		errAcceso "No se tienen permisos para acceder al directorio $pathDestino"
	fi
}

#=================COMPROBACION Y ASIGNACION DE PARAMETROS==========================

# Comprobamos si necesita ayuda

if [[ $1 = '-h' || $1 = '-help' || $1 = '-?' ]]; then
	mostrarAyuda
fi

if test $# -gt 4; then
	errSintax "Cantidad de parámetros incorrecta"
fi

# Verificamos si los parámetros "--notas" y "--salida" están presentes
if test $(echo $* | grep -o "\(--notas\)\|\(--salida\)" | wc -l) -eq 2; then
	ejecParametros "$1" "$2" "$3" "$4"
else
	errSintax "Definición de parámetros incorrecta"
fi

#================================MAIN===========================#

dirActual=`pwd`

cd "$pathDestino"

# Obtiene la ruta ABSOLUTA de donde va a estar el JSON
pathDestino=`pwd`

# echo "|$dirOrigen|"
# echo "|$pathDestino|"
# echo "|$nombreArchivo|"

cd "$dirActual"
cd "$dirOrigen"

if test `ls | grep ".csv" | wc -l` -eq 0; then
	echo "No se encontraron archivos .csv"
	exit 1
fi

# Encabezado del archivo JSON
echo "{
	\"actas\": [" > "$pathDestino/$nombreArchivo"

awk -F"," '{
	aciertos = 0
	DNI = $1

	### Obtengo el nombre de la materia actual ###
	split(FILENAME,aux,"_")
	materia = aux[1]

	### Loop para sumar las notas ###
	for (i=2; i<=NF; i++) {
		if ($i == "b" || $i == "B") {
			aciertos++
		}
		else {
			if ($i == "r" || $i == "R") {
				aciertos += 0.5
			}
		}
	}

	nota = (10 / (NF - 1)) * aciertos
	notaParteEntera = int(nota)

	### Redondeando el número ###
	if ((nota - notaParteEntera) >= 0.5)
		notaParteEntera += 1

	### Concateno la información del alumno en un array asociativo por DNI ###

	infoAuxiliar = DNIs[DNI]
	infoCompleta = infoAuxiliar "\t\t\t{ \"materia\": "materia", \"nota\": "notaParteEntera" },\n"

	DNIs[DNI] = infoCompleta
}
	END {
		### Imprimo la información en el JSON ###
		for (dni in DNIs) { 
			print "\t{"
			printf "\t\t\"dni\": %d,\n", dni
			print "\t\t\"notas\": ["
			print substr(DNIs[dni], 0, length(DNIs[dni])-2)
			print "\t\t]"
			print "\t},"
		}

	}' *.csv >> "$pathDestino/$nombreArchivo"

# Reemplazamos la coma del final por un cierre de JSON válido
sed -i '$s/,/\n\t]\n}/' "$pathDestino/$nombreArchivo"