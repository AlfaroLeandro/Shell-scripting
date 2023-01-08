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

# VALORES DE LOS EXIT: 
# 0 -EJECUCION NORMAL 
# 1 -ERROR DE SINTAXIS 
# 2 -DETENER EL SCRIPT CUANDO NO ESTA INICADO 
# 3 -INICIAR EL SCRIPT CUANDO YA ESTABA INICADO

errSintax() {
	echo "Error de sintaxis: $1"
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

errExistencia() {
	echo "No existe el directorio: "$1""
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

errPermisos() {
	echo "No hay permisos para acceder al directorio: "$1""
	echo "Use -h, -? o -help para ver la ayuda"
	exit 1
}

mostrarAyuda() {
	
	echo "AYUDA DEL SCRIPT:"
	echo ""
	echo "El script monitorea una carpeta especificada. Cuando allí se aparezcan "
	echo "archivos con extensiones, los mismos irán a parar a subdirectorios con "
	echo "el nombre de la extensión correspondiente."
	echo ""
	echo "Sintaxis: [Path al script] -d [dirMonitorear] -o [dirDestino]"
	echo ""
	echo "PARÁMETROS:"
	echo ""
	echo '	-d:	Indica el directorio a monitorear (por defecto directorio '
	echo '		"descargas" si no se le pasa valor a este parámetro).'
	echo ""
	echo '	-o:	Indica el directorio que contendrá los subdirectorios "extensión"'
	echo '		(por defecto directorio "descargas" si no se pasa valor a este '
	echo "		parámetro)."
	echo ""
	echo "	-s:	Si está presente, se debe detener el demonio. No puede pasarse al"
	echo "		mismo tiempo que los otros parámetros"
	echo ""
	echo "	-h, -help, -?: Muestran ayuda"

	exit 0
}

ejecutarParametros() {

	# Movimiento de directorios por si llaman al script desde algún lugar relativo
	scriptPath=`realpath $0`
	scriptPath=`dirname "$scriptPath"`
	cd "$scriptPath"

	# VALIDACIÓN DE PARÁMETROS

	if [[ $# = 2 ]]; then
		if [[ $1 = "-d" && $2 = "-o" ]] || [[ $1 = "-o" && $2 = "-d" ]]; then
			dirOrigen="$HOME/Downloads"
			dirDestino="$HOME/Downloads"
		else
			errSintax "Definición de parámetros incorrecta"
		fi
	elif [[ $# = 3 ]]; then
		if [[ $1 = "-d" && $3 = "-o" ]]; then
			dirOrigen="$2"
			dirDestino="$HOME/Downloads"
		elif [[ $1 = "-o" && $3 = "-d" ]]; then
			dirDestino="$2"
			dirOrigen="$HOME/Downloads"
		elif [[ $1 = "-d" && $2 = "-o" ]]; then
			dirDestino="$HOME/Downloads"
			dirOrigen="$3"
		elif [[ $1 = "-o" && $2 = "-d" ]]; then
			dirDestino="$3"
			dirOrigen="$HOME/Downloads"
		else
			errSintax "Definición de parámetros incorrecta"
		fi 
	else
		if [[ $1 = "-d" && $3 = "-o" ]]; then
			dirOrigen="$2"
			dirDestino="$4"
		elif [[ $1 = "-o" && $3 = "-d" ]]; then
			dirOrigen="$2"
			dirDestino="$4"
		else
			errSintax "Definición de parámetros incorrecta"
		fi 
	fi

	# echo "dirOrigen: |$dirOrigen|"
	# echo "dirDestino: |$dirDestino|"

	# Verificación de permisos y existencia
	if [[ ! -d $dirOrigen ]]; then
		errExistencia "$dirOrigen"
	elif [[ ! -r $dirOrigen || ! -w $dirOrigen ]]; then
		errPermisos "$dirOrigen"
	else
		dirOrigen=`realpath "$dirOrigen"`
	fi

	# Verificación de permisos y existencia
	if [[ ! -d $dirDestino ]]; then
		errExistencia "$dirDestino"
	elif [[ ! -r $dirDestino || ! -w $dirDestino ]]; then
		errPermisos "$dirDestino"
	else
		dirDestino=`realpath "$dirDestino"`
	fi

	ejecutarDemonio "$dirOrigen" "$dirDestino"
}

ejecutarDemonio() {
	pathDemonio="./demonio.sh"
	
	# Uso del nohup para al cambiar de usuario, seguir ejecutando el demonio
	# nohup genera un archivo de outputs, pero como no queremos eso, mandamos
	# toda salida a /dev/null. El símbolo "&" es para ejecutar en segundo plano
	if [[ -f "$pathDemonio" && -x "$pathDemonio" ]]; then
		nohup `"$pathDemonio" "$dirOrigen" "$dirDestino"` > /dev/null 2>&1 &
		echo "Se ha iniciado el demonio"
	else
		echo "No se ha podido iniciar el demonio (no existe o no tiene permisos de ejecución)"
	fi
}

# ------------ MAIN -------------

# ------ Comprobación y asignación de parámetros -------

# Comprobar si se requiere ayuda del script
if [[ $1 = '-h' || $1 = '-help' || $1 = '-?' ]]; then
	mostrarAyuda
fi

# Comprobar si se quiere detener el demonio
if [[ $1 = '-s' ]]; then
	if test $# -ne 1; then
		errSintax "No se puede usar el modificador -s con otros parámetros"
	fi

	psDemonio=`ps -e | grep -i demonio.sh`
	# echo "$psDemonio"

	if [[ -z $psDemonio ]]; then
		echo "No se encontró el script funcionando"
		exit 2
	else
		# echo `awk '{print $1}' <<< $psDemonio`
		kill -9 `awk '{print $1}' <<< $psDemonio`
		echo "Script detenido correctamente"
		exit 0
	fi
fi

# Compruebo si se pasaron los parámetros -d y -o que son obligatorios

if test $# -ge 2; then
	if test `ps -e | grep -i demonio.sh | wc -l` -ne 0; then
       echo "El demonio ya esta iniciado"
       exit 3
	else
		if [[ $# = 2 ]]; then
			ejecutarParametros "$1" "$2"
		elif [[ $# = 3 ]]; then
			ejecutarParametros "$1" "$2" "$3"
		else
			ejecutarParametros "$1" "$2" "$3" "$4"
		fi
	fi
else
	errSintax "Cantidad de parámetros incorrecta"
fi