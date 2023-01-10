# Shell-scripting

### ¡¡Importante!!: En los otros branches se encuentran los scripts de powershell y los programas desarrollados en C para linux.

## Programación de scripts en tecnología bash

### contar_subdir_mas_ele.bash:

El script tiene como objetivo a partir de un directorio y un numero n dados, mostrar los n subdirectorios ordenados de mayor a menor según la cantidad de elementos que contienen en su interior. Recibe un directorio y el numero de subdirectorios finales a mostrar.

ejemplo de llamado:

contar_subdir_mas_ele.bash directorio 5

### corrector.bash:

Realice un script que dado un archivo de texto plano (pasado por parámetro) le aplique las siguientes reglas:

• Eliminar espacios duplicados.

• Eliminar espacios de más antes de un punto (.), coma (,) o punto y coma (;)

• Agregar un espacio luego de un punto seguido, coma o punto y coma (En caso de que no lo tuviera).

Generando un nuevo archivo a guardarse en el mismo directorio del archivo original, agregándole al final del nombre la fecha y hora en el formato: 

[NOMBRE ORIGINAL]_[YYYYMMDDHHmm].[extensión, si la tuviera]

Además, debe generar por cada archivo un reporte de corrección, con el mismo nombre del archivo corregido, pero con extensión .log con los siguientes datos:

• Cantidad de correcciones realizadas.

• Cantidad de inconsistencias encontradas, diferenciadas por paréntesis dispares, signos de pregunta dispares y signos de admiración dispares. Llamamos dispares cuando se encuentra el signo o paréntesis de apertura y no el de cierre, o viceversa. Para verificar esto basta con tomar la diferencia entre los signos de apertura y cierre, sin mayor análisis sintáctico

Ejemplo de llamada: ./Corrector.sh -in [archivo]

### listar_duplicados.bash:

Se requiere generar un script que pueda determinar que archivos son copia de otros archivos (por su contenido) para posteriormente tomar la decisión de cuales archivos se eliminaran. Además, se debe generar un archivo log en otro directorio donde se listen los archivos repetidos con su ubicación original, cuyo nombre será 

Resultado_[YYYYMMDDHHmm].out

Dicho script debe recibir los siguientes parámetros:

• -Directorio: directorio donde se generan los archivos generados por el proceso. El mismo puede contener subdirectorios y los archivos encontrarse dentro o fuera de estos.

• -DirectorioSalida: directorio donde se guarda el archivo log, no debe ser el mismo directorio que -Directorio.

• -Umbral: tamaño en KB a partir del cual se empezarán a evaluar si los archivos presentan duplicados en el directorio ya que a veces el proceso a veces también genera archivos erróneos(vacíos) o incompletos y se desean filtrar del script.

Los mismos se deben poder recibir en cualquier orden.

Si por ejemplo tenemos 3 archivos “A”, “B”, “A” iguales y 2 archivos “D”, “E”. El script debería informar cada grupo de archivos duplicados delimitados por una línea vacía. Puede darse el caso que los archivos A B C se encuentran en subdirectorios diferentes y la salida del script debe ser la misma.

### archivos_extensiones.bash:

realizar un script demonio que detecte cada vez que un archivo nuevo aparezca en un directorio “descargas”. Una vez detectado, se debe mover a un subdirectorio “extensión” cuyo nombre será la extensión del archivo y que estará localizado en un directorio “destino”. Tener en cuenta que, al ser un demonio, el script debe liberar la terminal una vez ejecutado, dejando al usuario la posibilidad de ejecutar nuevos comandos.

El script recibirá los siguientes parámetros:

• -d: Indica el directorio a monitorear (directorio “descargas”).

• -o: Indica el directorio que contendrá los subdirectorios “extensión” (directorio “destino”). Si no se pasa valor a este parámetro, el directorio “destino” será el de “descarga”.

• -s: Si está presente, se debe detener el demonio. No puede pasarse al mismo tiempo que los otros parámetros.

Para tener en cuenta:

• Pueden existir archivos sin extensión. En ese caso, deberán moverse al directorio “destino” (fuera de los subdirectorios “extensión”).

• Los archivos con nombres que empiecen por “.” y que no tengan otra extensión deben trataste como los archivos sin extensión. Ejemplos: “.gitignore”, “.mailconfig”.

• Las extensiones no necesariamente tienen que ser de 3 caracteres. Ejemplos: .c, .cs, .cpp, .csproj.

• Si el subdirectorio “extensión” no existe, deberá crearse.

• Los subdirectorios “extensión” deben tener el nombre en mayúscula.

### generar_json_notas.bash:

Cada vez que llegaba una fecha de final, una universidad tenía el mismo problema: todas las materias dictadas entregaban las actas de final en papel para luego ser cargadas manualmente en el sistema central de actas. Este proceso, además de lento, contaba con un elevado número de errores, en su mayoría involuntarios.

Para agilizar este proceso, se decidió crear un sistema al que los profesores pudieran mandar las actas de manera digital. El flujo del sistema es el siguiente:

• Luego de tomar un final, el jefe de cátedra de cada materia crea un archivo en formato CSV con una fila por alumno y en donde se informa DNI y las notas de cada uno de los puntos del examen (B, R o M).

• Este archivo se sube a una web y es almacenado en un directorio a la espera de su procesamiento.

• Cada sábado a las 23:45hs, corre un script que procesa todos los CSV subidos (uno por mesa de examen) y genera un archivo JSON con las notas de los alumnos que rindieron final esa semana.

• El archivo JSON es luego leído por el sistema central de actas

Como grupo de alumnos que participa de un voluntariado de ayuda en la universidad, se ofrecen para programar un script que realice el procesamiento de las notas y genere el archivo JSON. El script recibirá los siguientes parámetros:

• --notas: Directorio en el que se encuentran los archivos CSV.

• --salida: Ruta del archivo JSON a generar (incluye nombre del archivo). Para tener en cuenta:

  • Cada archivo CSV representa una fecha de final, por lo tanto, tendrá las notas de todos los ejercicios de los alumnos que se presentaron a rendir. Los ausentes no están listados.

  • El nombre del archivo CSV es el código de la materia y la fecha de final, separados por un “_”. Ej: “1115_20210317.csv”.

  • La cantidad de ejercicios por final es variable entre materias (una materia siempre tiene la misma cantidad de ejercicios). Esto quiere decir que la cantidad de columnas que tiene cada archivo CSV no tiene porqué ser la misma.

  • Se genera un único archivo JSON que contiene la información de todas las materias y alumnos que rindieron durante la semana. Es decir, puede haber materias y alumnos repetidos. Sin embargo, un alumno no puede rendir la misma materia más de una vez a la semana, pero una materia puede tomar más de un final en la semana.
  
Para calcular la nota de cada final, se debe tener en cuenta que:
Cada ejercicio tiene el mismo peso en la nota final. Para calcularlo se puede usar la siguiente fórmula: 10 / CantidadEjercicios.

• Un ejercicio bien (B) vale el ejercicio entero.

• Un ejercicio regular (R) vale medio ejercicio.

• Un ejercicio mal (M) no suma puntos a la nota final

Formato de los archivos

CSV (no se debe incluir la primera fila de encabezados, se muestra solo para explicar el ejemplo):

Dni,Ej-1,Ej-2,Ej-3,…,Ej-n

12345678,b,m,r,…,m

87654321,b,b,b,…,r

JSON:
{ "actas": [
 {
 "dni": "12345678",
 "notas": [
 { "materia": 1115, "nota": 8 },
 { "materia": 1116, "nota": 2 }
 ]
 },
 {
 "dni": "87654321",
 "notas": [
 { "materia": 1116, "nota": 9 },
 { "materia": 1118, "nota": 7 }
 ]
 }
] }

### papelera.bash:

Realizar un script que emule el comportamiento del comando rm, pero utilizando el concepto de “papelera de reciclaje”, es decir que, al borrar un archivo se tenga la posibilidad de recuperarlo en el futuro. 

El script tendrá las siguientes opciones:

• -l listar los archivos que contiene la papelera de reciclaje, informando nombre de archivo y su ubicación original.

• -r [archivo] recuperar el archivo pasado por parámetro a su ubicación original.

• -e vaciar la papelera de reciclaje (eliminar definitivamente)

• [archivo] Sin modificador para que elimine el archivo (o sea, que lo envíe a la papelera de reciclaje). 

La papelera de reciclaje deberá ser un archivo comprimido ZIP y debe estar alojada en el home del usuario que ejecuta el comando, en caso de no encontrarse debe crearla.

Nota1: Tenga presente que archivos de diferentes directorios podrían tener el mismo nombre. El script debe considerar estos casos.

Nota2: En caso de que se quiera recuperar un nombre de archivo que esta varias veces en la papelera, debe listar los archivos y su ubicación original y preguntar cuál se quiere recuperar.

