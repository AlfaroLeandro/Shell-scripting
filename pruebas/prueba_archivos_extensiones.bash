#!/bin/bash

scriptPath=`realpath $0`
scriptPath=`dirname "$scriptPath"`

cd "$scriptPath"

if [[ ! -e "./4 lote" ]]; then
    echo "ERROR: Para ejecutar esta prueba debe haber un directorio llamado"
    echo "'4 lote' en el mismo lugar que este script."
    exit 1
fi

echo "### --- TANDA 1 (funcionamiento normal) --- ###"

cd "./4 lote"

mkdir "carpeta a monitorear"
mkdir "carpeta destino"

cd "carpeta a monitorear"

touch abc.txt "a b c.prueba" ".git" ".git.hub.cpp" "este es un archivo con espacios"
touch txt.word word.txt "los mejores archivos! .cat" "¿Podrá con símbolos? .si"

../../../4_APL1.bash -d "./pruebas/4 lote/carpeta a monitorear" -o "./pruebas/4 lote/carpeta destino"
sleep 3
../../../4_APL1.bash -s

echo "### --- TANDA 2 (funcionamiento normal) --- ###"

cd "../"

mkdir "carpeta padre"

cd "carpeta padre"

mkdir "carpeta hijo"

touch abc.txt "a b c.prueba" ".git" ".git.hub.cpp" "este es un archivo con espacios"
touch txt.word word.txt "los mejores archivos! .cat" "¿Podrá con símbolos? .si"

../../../4_APL1.bash -d "./pruebas/4 lote/carpeta padre" -o "./pruebas/4 lote/carpeta padre/carpeta hijo"
sleep 3
../../../4_APL1.bash -s

echo "### --- TANDA 3 (error de existencia) --- ###"

../../../4_APL1.bash -d dirInexistente -o

echo "### --- TANDA 4 (funcionamiento normal parámetros por defecto invertidos) --- ###"
echo "### --- (monitorea la carpeta de descargas) --- ###"

../../../4_APL1.bash -o -d
sleep 3
../../../4_APL1.bash -s

echo "### --- TANDA 5 (error existencia) --- ###"

../../../4_APL1.bash -d -o dirInexistente

echo "### --- TANDA 6 (error privilegios) --- ###"

cd "../"
mkdir carpetaSinPrivilegios
chmod 444 carpetaSinPrivilegios

../../4_APL1.bash -d -o "./pruebas/4 lote/carpetaSinPrivilegios"

chmod 754 carpetaSinPrivilegios

echo "### --- TANDA 7 (MONITOREA CARPETA DESCARGAS) --- ###"
echo "######## SE DEBE FINALIZAR MANUALMENTE (./APL1/4_APL1.bash -s) ########"

../../4_APL1.bash -d -o
