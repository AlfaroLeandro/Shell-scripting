#!/bin/bash

cd `dirname $0`

echo "### --- TANDA 1 (mensaje de ayuda) --- ###"

../5_APL1.bash -h

echo "### --- TANDA 2 (funcionamiento normal) --- ###"

../5_APL1.bash --notas "./5 lote" --salida "./5 lote/tanda 2.json"

echo "### --- TANDA 3 (carpeta sin permisos) --- ###"

chmod 000 "./5 lote"

../5_APL1.bash --notas "./5 lote" --salida "./5 lote/tanda 3.json"

chmod 754 "./5 lote"

echo "### --- TANDA 4 (directorio inexistente) --- ###"

../5_APL1.bash --notas "./Ejerccccccicio 5" --salida "./5 lote/tanda 4.json"

echo "### --- TANDA 5 (sintaxis incorrecta) --- ###"

../5_APL1.bash -notas "./5 lote" -salida "./5 lote/tanda 5.json"

echo "### --- TANDA 6 (sintaxis incorrecta) --- ###"

../5_APL1.bash --notas --salida

echo "### --- TANDA 7 (sintaxis incorrecta) --- ###"

../5_APL1.bash --notas "./5 lote" --salida

echo "### --- TANDA 8 (ruta absoluta) --- ###"

../5_APL1.bash --notas ~/Music --salida "./5 lote/tanda 8.json"

echo "### --- TANDA 9 (parámetros invertidos) --- ###"

../5_APL1.bash --salida "./5 lote/tanda 9.json" --notas "./5 lote" 