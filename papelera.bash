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


dirPapelera="$HOME/.papelera"
dirPapeleraEmpaq="$HOME/.papelera.tar"

mostrarAyuda(){ 
	echo "   ##############################################################################################################"
	echo "                                                   AYUDA:"
	echo ""
	echo "   ##############################################################################################################"
	echo "						PAPELERA DE RECICLAJE"
	echo "		Al borrar un archivo se tenga la posibilidad de recuperarlo en el futuro."
	echo ""
	echo ""
	echo "				El script tendrá las siguientes opciones:"
	echo ""
	echo "		-l listar los archivos que contiene la papelera de reciclaje, informando nombre de archivo y"
	echo "		   su ubicación original."
	echo "		-r [archivo] recuperar el archivo pasado por parámetro a su ubicación original."
	echo "		-e vaciar la papelera de reciclaje (eliminar definitivamente)"
	echo "		[archivo] Sin modificador para que elimine el archivo (o sea, que lo envíe a la papelera de"
	echo "				  reciclaje)."
	echo ""
	echo ""
	echo "		La papelera de reciclaje deberá ser un archivo comprimido ZIP y debe estar alojada en el home del"
	echo "		usuario que ejecuta el comando, en caso de no encontrarse debe crearla."
	exit 0
}

function errSintax {
    echo "Error de sintaxis: $1"
    echo "Para ver la ayuda del script, ejecutelo de la siguiente forma: -help o -h o -?"
    exit 1
}

function ejecParametros {
	case "$1" in
		'-l')	
			listarPapelera "falso"
		;;
		'-e')
			limpiarPapelera
		;;	
		'-r')
			if test -z "$2"; then
				errSintax "Cantidad de parametros incorrectos"
			fi
			restaurarArchivo "$2"
		;;
		'-'[h?])
			mostrarAyuda
		;;
		'-help')
			mostrarAyuda	
		;;
		*)
			#Valido si el archivo ingresado existe
			if [ ! -e "$1" ] || [ ! -f "$1" ] || [ ! -r "$1" ] || [ ! -w "$1" ]; then 
				errSintax "El archivo ingresado no existe o no tiene permisos de lectura/escritura"
			fi
		
			borrarArchivo "$1" "$(realpath "$1")"
		;;
	esac
}

function renombrarArchivos {
	archivoABuscarSinPath="$1"
	indice=0

	cantArchivosEnPapelera=${#listaDeArchEnPapelera[@]}
	for(( i=1; i<$cantArchivosEnPapelera; i++ )); do 
		archEnPapeleraAct="${listaDeArchEnPapelera[$i]##*/}"	
		if test "$archivoABuscarSinPath" = "${archEnPapeleraAct%(*}"; then
			if test ! -f "$dirPapelera/$archEnPapeleraAct"; then
				indice=$2
				unset 'listaDeArchEnPapelera[$i]'
			elif test $indice -ne 0; then
				let indiceAux=$indice+1
				mv -f "$dirPapelera/$archivoABuscarSinPath($indiceAux)" "$dirPapelera/$archivoABuscarSinPath($indice)"
				listaDeArchEnPapelera[$i]="${listaDeArchEnPapelera[$i]%(*}($indice)"
				let indice++
			fi
		fi		
	done
	printf "%s\n" "${listaDeArchEnPapelera[@]}" > "$dirPapelera/.registro"	
}

function listarPapelera {
	listaDeArchEnPapelera=()
	mostrarEnumerado="$1"
	archivoABuscarSinPath="$2"

	while IFS= read -r line; do #LEE CADA LINEA DEL REGISTRO - LINE = PATH/ARCHIVO
		listaDeArchEnPapelera=("${listaDeArchEnPapelera[@]}" "$line");
	done <$dirPapelera/.registro
	
	printf "   NOMBRE\t\t\t  RUTA\t\t%35s\n" "ULTIMA MODIFICACION"
        cantArchivosEnPapelera=${#listaDeArchEnPapelera[@]} # ${#var} = longitud -> numero de campos de listaDeArchEnPapelera
	j=1
	for (( i=1; i<$cantArchivosEnPapelera; i++ )); do
		archEnPapeleraAct="${listaDeArchEnPapelera[$i]##*/}" #obtengo el nombre del archivo
		fecha=`stat "$dirPapelera"/"$archEnPapeleraAct" | awk 'NR==6'`
		fecha=${fecha[*]:8:19}
		
		if test $mostrarEnumerado = "verdadero"; then
			if test "${archEnPapeleraAct%(*}" = "$archivoABuscarSinPath"; then
				printf " %-2d - %-15s %-45s %s\n" "$j" "$(basename "${listaDeArchEnPapelera[$i]%(*}")" "$(dirname "${listaDeArchEnPapelera[$i]}")" "$fecha"
				let j++
			fi
		else
			printf "  %-15s %-45s %s\n" "$(basename "${listaDeArchEnPapelera[$i]%(*}")" "$(dirname "${listaDeArchEnPapelera[$i]}")" "$fecha"
		fi
	done
	echo ""
}

function restaurarArchivo {
	listaDeArchEnPapelera=() #es la lista de archivos que estan en .registro
	archivoABuscar=`realpath "${1##*/}"`
	archivoABuscarSinPath="${archivoABuscar##*/}"
	encontro="false"

        while IFS= read -r line; do #LEE CADA LINEA DEL REGISTRO - LINE = PATH/ARCHIVO
                listaDeArchEnPapelera=("${listaDeArchEnPapelera[@]}" "$line");
        done <$dirPapelera/.registro

	cantArchivosEnPapelera=${#listaDeArchEnPapelera[@]} # ${#var} = longitud -> numero de campos de listaDeArchEnPapelera
	cantArchivosParaRestaurar=$(
		cont=0
		for ((i=1; i<$cantArchivosEnPapelera; i++)); do
			archAct="${listaDeArchEnPapelera[$i]##*/}"
			if test "${archAct%(*}" = "$archivoABuscarSinPath"; then
				let cont++
			fi
		done
		echo $cont
	)

	if test $cantArchivosParaRestaurar -gt 1; then
		listarPapelera "verdadero" "$archivoABuscarSinPath"
		opc=0	
		printf "Digite el numero de archivo a recuperar: "
		read opc
		for((i=1; i<cantArchivosEnPapelera; i++)) {
			archivoASacar="${listaDeArchEnPapelera[$i]##*/}"

				if test "$archivoABuscarSinPath($opc)" = "$archivoASacar"; then
					mv -f "$dirPapelera"/"$archivoABuscarSinPath($opc)" "${archivoASacar%(*}" 
					encontro="true"
					renombrarArchivos "$archivoABuscarSinPath" "$opc"
					break
				fi
		}
		
	elif test $cantArchivosParaRestaurar -eq 1; then
		for (( i=0; i<$cantArchivosEnPapelera; i++ )); do
			archivoASacar="${listaDeArchEnPapelera[$i]##*/}"	#OBTIENE EL NOMBRE DEL ARCHIVO SOLO
				
			if [[ "$archivoABuscarSinPath" = "${archivoASacar%(*}" ]]; #Si lo pasa con ruta relativa
			then
				mv -f "$dirPapelera"/"$archivoASacar" "$(tr -d '\n' <<< ${listaDeArchEnPapelera[$i]%(*})"
				unset 'listaDeArchEnPapelera[$i]'
				encontro="true"
			fi	
		done	
		printf "%s\n" "${listaDeArchEnPapelera[@]}" > "$dirPapelera/.registro" #QUEDAN TODOS LOS ARCHIVOS MENOS EL QUE RECUPERE 
	fi

	if [[ "$encontro" = "true"  ]]; then
		echo "Se recupero el archivo"		
	else
		echo "No se encontro el archivo especificado"		
	fi	
	
	#' > /dev/null
}

function borrarArchivo {
	i=1
	archivoSinExtension=$(basename "$1") 
	nombreFinal="$archivoSinExtension""($i)" #ARCHIVO SIN EXTENSION

	while [  -f $dirPapelera/"$nombreFinal" ] #MIENTRAS EXISTA EL ARCHIVO EN LA PAPLERA
	do
		let "i++"
		nombreFinal="$archivoSinExtension""($i)" #CONCATENA EL NOMBRE SIN EXTENSION CON i
	done
	dirAnterior=$(dirname "$2") #OBTIENE TODO EL DIRECTORIO MENOS LA ULTIMA PARTE 	
	
	mv "$1" "$dirPapelera/$nombreFinal" 
	echo "$dirAnterior/$nombreFinal" >>	"$dirPapelera/.registro"
	echo "El archivo que se elimino ahora es: $nombreFinal"
}

function limpiarPapelera {
	rm -rfv $dirPapelera && mkdir $dirPapelera #RECURSIVO - FORZADO - EXPLICANDO QUE SE ESTA HACIENDO
	rm -rf ~/.local/share/Papelera/* #RECURSIVO - FORZADO
	echo "" > $dirPapelera/.registro
	echo  "Se limpio la basura"
}

#=================VALIDACION DE PARAMETROS===============================
if [[ $# -eq 0 ]] || [[ $# -gt 2 ]]; then #Valido si no se ingreso parametro o se mandaron mas de 2 param
	errSintax "Error en la cantidad de parametros"		
	exit 1
fi

if [[ ! -f $dirPapeleraEmpaq.gz ]]; then #SI LA PAPELERA NO EXISTE, LA CREO
	mkdir -p $dirPapelera
	touch "$dirPapelera/.registro"
else
	echo ""
	gzip -d $dirPapeleraEmpaq.gz 
	tar xvf $dirPapeleraEmpaq -C / 2>/dev/null
	rm -f $dirPapeleraEmpaq	
fi

#=========================MAIN==========================
ejecParametros "$1" "$2"

#echo '
tar -cf $dirPapeleraEmpaq "$dirPapelera" 
gzip -9 $dirPapeleraEmpaq 
rm -fr $dirPapelera # '>/dev/null

