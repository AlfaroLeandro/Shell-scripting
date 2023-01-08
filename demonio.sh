#!/bin/bash

dirOrigen="$1"
dirDestino="$2"

# echo $dirOrigen
# echo $dirDestino

while true ; do

	# lista de todos los archivos dentro del directorio origen
	# se usa readarray para armar el array con cada salto de linea
	# y de esta manera contemplar nombres de archivos con whitespaces

	readarray lista <<< `ls -pA "$dirOrigen" | grep -v /`

	# verifica si hay nuevos archivos en el directorio
	if [[ ! -z `echo ${lista[0]} | tr -d '\n'` ]]; then 
		for (( i=0; i<"${#lista[*]}"; i++ ))
		do
			elemento=${lista[$i]}
			elemento=`echo $elemento | tr -d '\n'`
			extension=`echo "$elemento" | awk -F"." '{print $(NF)}'` # obtiene la extension del archivo

			# Si son archivos sin extensión o que empiecen por "."
			if [[ $elemento = $extension || $elemento = ".$extension" ]]; then
				# elemento -> dirDestino

				# Evitamos bucle infinito (dirOrigen != dirDestino)
				if [[ $dirOrigen != $dirDestino ]]; then
					mv -f "$dirOrigen/$elemento" "$dirDestino"
				fi
			elif [[ $elemento != $extension && $elemento != ".$extension" ]]; then
				# Encontró con extension
				dirDestinoFinal=$dirDestino/"${extension^^}"	
				# dirOrigen/elemento -> dirDestinoFinal
				mkdir "$dirDestinoFinal" 2>/dev/null
				mv -f "$dirOrigen/$elemento" "$dirDestinoFinal"
			fi
		done	
	fi
	sleep 3
done