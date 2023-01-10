# ======================Inicio De Encabezado=======================

# Nombre del script: 4_APL2.ps1
# Número de ejercicio: 4
# Trabajo Práctico: 2
# Entrega: Cuarta entrega

# =================================================================

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
El script encarpeta archivos según su extensión.

.DESCRIPTION
El script monitorea una carpeta especificada. Cuando allí se aparezcan archivos con extensiones, los mismos irán a parar a subdirectorios con el nombre de la extensión correspondiente.

.PARAMETER Descargas
Indica el directorio a monitorear.

.PARAMETER Destino
Indica el directorio que contendrá los subdirectorios "extensión" (por defecto directorio pasado en -Descargas si no se pasa valor a este parámetro)

.PARAMETER Detener
Si está presente, se debe detener el demonio. No puede pasarse al mismo tiempo que los otros parámetros

.EXAMPLE
./Monitor.ps1 -Descargas "./carpeta/" -Destino "./carpeta destino/"
.EXAMPLE
./Monitor.ps1 -Descargas "./carpeta/"
.EXAMPLE
./Monitor.ps1 -Detener   
#>

[CmdletBinding()]

Param (
    [parameter(Mandatory = $true, ParameterSetName = "monitorear")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path -PathType Container $_ } )]
    [String] $Descargas,

    [parameter(Mandatory = $false, ParameterSetName = "monitorear")]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path -PathType Container $_ } )]
    [String] $Destino = $Descargas,

    [parameter(Mandatory = $True, ParameterSetName = "detener")]
    [Switch] $Detener
)

# Setea que todos los errores paren la ejecución del script
# lo que permite hacer un try catch en partes críticas
$erroractionPreference = "stop"

$Global:Descargas = $Descargas
$Global:Destino = $Destino

$encarpetar = {

    if ($_) {
        $fileActual = $_
    }
    else {
        $details = $event.SourceEventArgs
        $Name = $details.Name
        $fileActual = $Name
    }

    # Obtenemos el nombre del archivo actual
    $nombre = Split-Path $fileActual -LeafBase

    # Obtenemos la extensión actual, sin el punto inicial
    $extension = Split-Path $fileActual -Extension
    if ($extension) {
        $extension = $extension.substring(1).ToUpper();
    }

    try {
        # Si tiene nombre y extensión, crear una subcarpeta para ese archivo
        if ($nombre -and $extension) {
            New-Item -Path $Destino -Name $extension -ItemType "directory" | Out-Null
        }
    }
    catch {}
    finally {
        $pathOrigen = Resolve-Path "$Descargas/$fileActual"

        # Moviendo archivos con extensión a su respectiva carpeta
        if ($nombre -and $extension) {
            $pathDestino = Resolve-Path "$Destino/$extension"
            Move-Item -Path $pathOrigen -Destination $pathDestino
        }
        # Si Destino != Origen mover archivos sin extensión a carpeta destino
        elseif ($Descargas -ne $Destino) {
            Move-Item -Path $pathOrigen -Destination $Destino
        }
    }
}

function detener {
    try {
        Get-EventSubscriber -SourceIdentifier "watch created" | Unregister-Event
        Get-EventSubscriber -SourceIdentifier "watch renamed" | Unregister-Event
    }
    catch {}

    try {
        Remove-Job -Force -Name "watch created"
        Remove-Job -Force -Name "watch renamed"
    }
    catch {
        Write-Warning "No se encontró monitoreo en funcionamiento"
        exit 1
    }

    Write-Warning "Monitoreo detenido con éxito"
    exit 0
}

##### INICIO DEL MAIN #####

# En el caso que se quiera detener el monitoreo
if ($Detener) {
    detener
}

# Obtenemos los archivos de la carpeta origen, para poder encarpetarlos
$Descargas | Get-ChildItem -File -Name -Force | ForEach-Object { & $encarpetar }


# Empezamos a desarrollar la lógica del monitoreo #

# Especifica la propiedad que se desea monitorear
$AttributeFilter = [IO.NotifyFilters]::FileName

# Establece un objeto para monitorear los archivos del path descargas
$watcher = New-Object -TypeName System.IO.FileSystemWatcher -Property @{
    Path = $Descargas
    Filter = '*'
    IncludeSubdirectories = $false
    NotifyFilter = $AttributeFilter
}

try {
    # Registramos los event handlers (sólo nos interesa cuando se crean y renombran archivos)
    Register-ObjectEvent -InputObject $watcher -EventName Created -Action $encarpetar -SourceIdentifier "watch created" | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $encarpetar -SourceIdentifier "watch renamed" | Out-Null
}
catch {
    Write-Warning "Monitoreo en funcionamiento"
    exit 1
}

# Comienza el monitoreo
$watcher.EnableRaisingEvents = $true


# CÓDIGO DE AYUDA
#
# touch abc.txt "a b c.prueba" ".git" ".git.hub.cpp" "este es un archivo con espacios"
# touch txt.word word.txt "los mejores archivos! .cat" "¿Podrá con símbolos? .si"