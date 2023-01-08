#!/bin/bash

cd `dirname $0`

echo "### --- TANDA 1 (mensaje de ayuda) --- ###"

../3_APL1.bash -h
../3_APL1.bash -?
../3_APL1.bash -help

echo "### --- TANDA 2 (funcionamiento normal) --- ###"

../3_APL1.bash -Directorio "./3 lote" -DirectorioSalida "." -Umbral 1

echo "### --- TANDA 3 (carpeta sin permisos) --- ###"

chmod 000 "./3 lote"

../3_APL1.bash -Directorio "./3 lote" -DirectorioSalida "." -Umbral 1

chmod 754 "./3 lote"

echo "### --- TANDA 4 (directorio inexistente) --- ###"

../3_APL1.bash -Directorio "./Ejerccccccicio 3" -DirectorioSalida "." -Umbral 1

echo "### --- TANDA 5 (sintaxis incorrecta) --- ###"

../3_APL1.bash -Directoio "./3 lote" -DirectorioSalida "." -Umbral 1

echo "### --- TANDA 6 (sintaxis incorrecta) --- ###"

../3_APL1.bash -Directorio -DirectorioSalida -Umbral

echo "### --- TANDA 7 (sintaxis incorrecta) --- ###"

../3_APL1.bash -Directorio "./3 lote" -DirectorioSalida -Umbral 1

echo "### --- TANDA 8 (sintaxis incorrecta) --- ###"

../3_APL1.bash -Directorio "./3 lote" -DirectorioSalida "." -Umbral a

echo "### --- TANDA 9 (ruta absoluta) --- ###"

../3_APL1.bash -Directorio "./3 lote" -DirectorioSalida ~ -Umbral 1