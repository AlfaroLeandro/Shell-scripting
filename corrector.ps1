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

<#
.SYNOPSIS
Corrige un archivo de texto plano (espacios).

.DESCRIPTION
El script corrige un archivo de texto plano pasado por parámetro.
  - Elimina espacios repetidos.
  - Elimina espacios demás antes de un punto (.), coma (,) o punto y coma (;).
  - Agrega un espacio luego de un punto seguido, coma o punto y coma (en caso de que no lo tuviera).
Finalmente genera dos archivos, uno corregido y otro con el reporte de correcciones realizadas e inconsistencias de signos o paréntesis.
       
.EXAMPLE
./Corrector.ps1 -in "./carpeta/archivo texto.txt"          
#>

[CmdletBinding()]

Param (
  [parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [ValidateScript( { Test-Path -PathType Leaf $_ } )]
  [String] $in
)

# Setea que todos los errores paren la ejecución del script
# lo que permite hacer un try catch en partes críticas
$erroractionPreference = "stop"

# Creación de los nombres de los archivos de salida

$fecha = Get-Date -UFormat "%Y%m%d%H%M"
$nombreArchivo = [io.path]::GetFileNameWithoutExtension($in)
$extension = [io.path]::GetExtension($in)
$nombreArchivoNuevo="$nombreArchivo`_$fecha$extension"
$nombreArchivoReporte="$nombreArchivo`_$fecha.log"
$dirDestino = (get-item $in).Directory
$dirArchivoNuevo = "$dirDestino/$nombreArchivoNuevo"

######################################################

$esTexto = Invoke-Expression "file '$in' -b | grep 'text' | wc -l"

if ($esTexto -ne "1") {
  Write-Error "No es un archivo de texto plano"
  exit 1
}

try {
  # Copiamos el archivo de entrada para aplicar las correcciones ahí
  Copy-Item "$in" -Destination "$dirArchivoNuevo"
}
catch {
  Write-Error "No hay permisos para acceder al archivo"
  exit 1
}


$cantCaracInic = (Get-Content "$dirArchivoNuevo" | Measure-Object -Character).Characters
# Reemplaza todos los espacios duplicados por uno solo
(Get-Content "$dirArchivoNuevo") -replace '  *', ' ' | Set-Content "$dirArchivoNuevo"

# Todos los espacios antes de una coma, punto, o punto y coma los borra
(Get-Content "$dirArchivoNuevo") -replace ' ([,;.])', '$1' | Set-Content "$dirArchivoNuevo"
$cantCaracAux = (Get-Content "$dirArchivoNuevo" | Measure-Object -Character).Characters

# Despues de una coma, un punto o punto y coma, agrega un espacio si necesita
(Get-Content "$dirArchivoNuevo") -replace '([,;.])(\w)', '$1 $2' | Set-Content "$dirArchivoNuevo"
$cantCaracAuxF = (Get-Content "$dirArchivoNuevo" | Measure-Object -Character).Characters

$cantCaracDif = $cantCaracInic - $cantCaracAux
$cantCaracFinal = $cantCaracDif + $cantCaracAuxF - $cantCaracAux

# Hallamos las inconsitencias diferenciadas por tipo

$incPreguntas = [math]::Abs((Select-String -Path $in -Pattern '¿' -AllMatches).Matches.Length - (Select-String -Path $in -Pattern '\?' -AllMatches).Matches.Length)
$incExclamacion = [math]::Abs((Select-String -Path $in -Pattern '¡' -AllMatches).Matches.Length - (Select-String -Path $in -Pattern '!' -AllMatches).Matches.Length)
$incParentesis = [math]::Abs((Select-String -Path $in -Pattern '\(' -AllMatches).Matches.Length - (Select-String -Path $in -Pattern '\)' -AllMatches).Matches.Length)

# Sumamos las correcciones parciales para hallar las correcciones totales
$inconsistencias = $incPreguntas + $incExclamacion + $incParentesis

Out-File -FilePath "$dirDestino/$nombreArchivoReporte" -InputObject "Candidad de correcciones realizadas: $cantCaracFinal
Cantidad de inconsistencias encontradas: $inconsistencias
  Signos de pregunta dispares: $incPreguntas
  Signos de exclamación dispares: $incExclamacion
  Paréntesis dispares: $incParentesis"