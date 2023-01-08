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


#########################################

mostrarAyuda() {
	echo ""
	echo "   ##############################################################################################################"
	echo "                                                   AYUDA:"
	echo ""
	echo "   ##############################################################################################################"
	echo ""
	echo ""
	echo "este script puede determinar que archivos son copia de otros archivos (por su contenido) para posteriormente tomar "
	echo "la decisión de cuales archivos se eliminaran. Además, se debe generar un archivo log en otro directorio donde"
	echo "se listen los archivos repetidos con su ubicación original, cuyo nombre será Resultado_[YYYYMMDDHHmm].out."
	echo ""
	echo "################################################ PARAMETROS ######################################################"
	echo ""
	echo "Dicho script debe recibir los siguientes parámetros:"
	echo "• -d: directorio donde se generan los archivos generados por el proceso. El mismo"
	echo "puede contener subdirectorios y los archivos encontrarse dentro o fuera de estos."
	echo "• -o: directorio donde se guarda el archivo log, no debe ser el mismo directorio"
	echo "que -Directorio."
	echo "• -u: tamaño en KB a partir del cual se empezarán a evaluar si los archivos presentan"
	echo "duplicados en el directorio ya que a veces el proceso a veces también genera archivos"
	echo "erróneos(vacíos) o incompletos y se desean filtrar del script."
	echo ""
}

errAcceso() {
	echo "Error: $1"
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

buscarPorUmbral() {
    umbral=$(echo "$1")
    listaDeArchivos=$(find "$dirOrigen" -type f)

    IFS=$'\n'

    archivosQueSuperanElUmbral=$(
        for archivoAct in $listaDeArchivos; do
            peso=$(stat -c %s "$archivoAct" | awk '{pesoEnKB = $1/1024} END{printf "%.1f", pesoEnKB}')
            superaElUmbral=$(echo "$peso $umbral" | awk '{print($1 > $2)}')
            if [[ "$superaElUmbral" == 1 ]]; then
                echo "$(readlink -f "$archivoAct")"
            fi
        done
    )
	
	if test -z "$archivosQueSuperanElUmbral"; then
		echo "No se encontraron archivos que superen el umbral"
		exit 0
	fi
}

buscarDuplicados() {

    # RECORRO CADA ARCHIVO QUE SUPERA EL UMBRAL Y LO COMPARO CON LOS DEMAS, Y ADEMAS IGNORO LOS QUE SON EL MISMO ARCHIVO

    IFS=$'\n'

    for archivo1 in $archivosQueSuperanElUmbral; do
        for archivo2 in $archivosQueSuperanElUmbral; do

            if [[ "$archivo1" != "$archivo2" ]]; then #Me fijo que no son el mismo archivo
                cmpArchivos=$(cmp --silent "$archivo1" "$archivo2"; echo $?) # "$?" tiene el retorno de la comparacion
                if [[ $cmpArchivos -eq 0 ]]; then # Si son iguales en cmpArchivos == 0
					printf "  %-20s\t%s\n" "$(basename "$archivo1")" "$(dirname "$archivo1")" >> "$pathArchInforme"
                fi
            fi
        done
    done
}

# ==============================VALIDACION DE PARAMETROS================================
cantParametros=$#
dirDestino="." #default
cantDeParamIngresados="0"

if test $cantParametros -ne 1 && test $cantParametros -ne 6; then
	echo "ERROR: Cantidad de parametros ingresados incorrecto" 1>&2
	exit 1
fi

if [[ "$1" == "-h" || "$1" == "-?" || "$1" == "-help" ]]; then
    mostrarAyuda
    exit 0
fi

parametros=`printf "%s\n" "$@"`
argv=("$@")
#echo "${argv[n-1]}"

numDeParamAux=`grep -n "\-Directorio" <<< "$parametros" | cut -d : -f 1| awk 'NR==1{print $1}'`

if test "${argv[numDeParamAux-1]}" = "-Directorio"; then
	numDeParam=$numDeParamAux
else
	numDeParam=`grep -n "\-Directorio" <<< "$parametros" | cut -d : -f 1| awk 'NR==2{print $1}'`
fi

if test ! -z $numDeParam && test "${argv[numDeParam-1]}" = "-Directorio"; then
	dirOrigen="${argv[numDeParam]}"
	if [[ ! -e $dirOrigen ]]; then
		errAcceso "Ruta inválida $dirOrigen"
	elif [[ ! -r $dirOrigen || ! -w $dirOrigen ]]; then
		errAcceso "No se tienen permisos para acceder al directorio $dirOrigen"
	fi
else
	echo "Error de sintaxis en -Directorio, use $0 -? -h o -help para ver la ayuda"
	exit 1;
fi

numDeParam=`grep -n "\-DirectorioSalida" <<< "$parametros" | cut -d : -f 1`
if test ! -z $numDeParam && test "${argv[numDeParam-1]}" = "-DirectorioSalida"; then
	dirDestino="${argv[numDeParam]}"
	if [[ ! -e $dirDestino ]]; then
		errAcceso "Ruta inválida $dirDestino"
	elif [[ ! -r $dirDestino || ! -w $dirDestino ]]; then
		errAcceso "No se tienen permisos para acceder al directorio $dirDestino"
	fi
else
	echo "Error de sintaxis en -DirectorioSalida, use $0 -? -h o -help para ver la ayuda"
	exit 1;
fi 

numDeParam=`grep -n "\-Umbral" <<< "$parametros" | cut -d : -f 1`
if test ! -z $numDeParam && test "${argv[numDeParam-1]}" = "-Umbral"; then
	umbral="${argv[numDeParam]}"
	esNumero='^[0-9]+$'
	if ! [[ $umbral =~ $esNumero ]] ; then
	   echo "ERROR: el umbral no es un numero" 1>&2; 
	   echo "Para mas informacion: $0 -help"
	   exit 1
	fi
else
	echo "Error de sintaxis en -Umbral, use $0 -? -h o -help para ver la ayuda"
	exit 1;
fi

if [[ "$dirOrigen" = "$dirDestino" ]]; then
    echo "ERROR: directorio origen igual al directorio destino" 1>&2
    exit 1
fi

# ============================== MAIN ================================ #

#echo '
fecha=$(date +"%Y%m%d%H%M")
pathArchInforme="$dirDestino"/Resultado_"$fecha".out
buscarPorUmbral "$umbral"
buscarDuplicados "$archivosQueSuperanElUmbral"
cat "$pathArchInforme" | sort | uniq >auxiliar.txt
cat auxiliar.txt >"$pathArchInforme"
rm -f auxiliar.txt
cat "$pathArchInforme" #'>/dev/null