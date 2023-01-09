# Shell-scripting

## Programación de scripts en tecnología bash

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

