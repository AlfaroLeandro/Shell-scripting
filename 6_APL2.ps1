# ======================Inicio De Encabezado=======================

# Nombre del script: 6_APL1.bash
# Número de ejercicio: 6
# Trabajo Práctico: 1
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
# ------------- Ayuda ------------------ #

<#
.DESCRIPTION
    Al borrar un archivo se tenga la posibilidad de listarlo o recuperarlo en el futuro.
	
				
	        -l listar los archivos que contiene la papelera de reciclaje, informando nombre de archivo y
	    	 su ubicación original.
	        -r [archivo] recuperar el archivo pasado por parámetro a su ubicación original.
	        -e vaciar la papelera de reciclaje (eliminar definitivamente)
	        [archivo] Sin modificador para que elimine el archivo (o sea, que lo envíe a la papelera de
	        reciclaje).
	
	
	        La papelera de reciclaje deberá ser un archivo comprimido ZIP y debe estar alojada en el home del
	        usuario que ejecuta el comando, en caso de no encontrarse debe crearla.
#>

# ------------ Validaciones ---------------- #

Param (
[Parameter(Mandatory=$true, ParameterSetName="listar")] 
[switch] $l,
[Parameter(Mandatory=$true, ParameterSetName="limpiar")] 
[switch] $e,
[Parameter(Mandatory=$true, Position = 1, ParameterSetName="recuperar")] 
[switch] $r,
[Parameter(Mandatory=$true, Position = 2, ParameterSetName="recuperar")] 
[System.String] $archivoARecuperar,
[Parameter(Mandatory=$true, Position = 1, ParameterSetName="borrar")] 
[ValidateScript({
    if( -Not ("$_" | Test-Path) ){
        throw "Archivo no existe"
    }
    return $true
})]
[System.String] $archivoABorrar
)

$Global:dirPapelera="$HOME/.papelera" 
$Global:dirPapeleraCompr="$HOME/.papelera.zip" 


function listarPapelera {
    Param ( 
    [switch] $mostrarEnumerado,
    [System.String] $archivoABuscarSinPath
    )
    $listaDeArchEnPapelera = New-Object -TypeName "System.Collections.ArrayList" 
    Get-Content -Path "$dirPapelera/.registro" | ForEach-Object {$listaDeArchEnPapelera.Add($_)} | Out-Null
    $j=1 

    Write-Host("       {0,-30} {1,-30}ULTIMA MODIFICACION`n" -f "NOMBRE" , "RUTA")
    for($i=0; $i -lt $listaDeArchEnPapelera.Count ;$i++) {
            $archAct="$($listaDeArchEnPapelera[$i])".Substring(0,"$($listaDeArchEnPapelera[$i])".Length-3) 
            $ultModificacion=(Get-Item "$dirPapelera/$([io.path]::GetFileName("$($listaDeArchEnPapelera[$i])"))").LastWriteTime 
            
            if($mostrarEnumerado) {
                if("$archivoABuscarSinPath" -eq "$([io.path]::GetFileName("$archAct"))") {
                    write-output ("{0,-2} - {1,-15} {2,-45} {3}" -f "$j" , [io.path]::GetFileName("$archAct") ,[io.path]::GetDirectoryName($listaDeArchEnPapelera[$i]) , $ultModificacion)
                    $j++ | Out-Null
                }
            }
            else {
                write-output ("  {0,-15} {1,-45} {2}" -f [io.path]::GetFileName("$archAct") , [io.path]::GetDirectoryName($listaDeArchEnPapelera[$i]) , $ultModificacion)
            }
    }
    write-output "`n"
}

function renombrarArchivos {
    param (
    [String]$archivoABuscarSinPath,
    [int]$opc
    )
    $indice=0
    $cantArchivosEnPapelera=$listaDeArchEnPapelera.Count 

    for($i=0; $i -lt $cantArchivosEnPapelera; $i++) {
        $archEnPapeleraAct=[io.path]::GetFileName("$($listaDeArchEnPapelera[$i])") 
        
        if("$archivoABuscarSinPath" -eq "$archEnPapeleraAct".Substring(0,"$archEnPapeleraAct".Length-3)) {
            if(-Not (Test-Path -path "$dirPapelera/$archEnPapeleraAct")) {
                $indice=$opc 
                $listaDeArchEnPapelera.RemoveAt($i) 
                $i-- 
                $cantArchivosEnPapelera-- 
            }
            elseif ($indice -ne 0) {
               $indiceAux=$indice+1 
               Move-Item -Force "$dirPapelera/$archivoABuscarSinPath($indiceAux)" "$dirPapelera/$archivoABuscarSinPath($indice)"

               $listaDeArchEnPapelera[$i]="$("$($listaDeArchEnPapelera[$i])".Substring(0,"$($listaDeArchEnPapelera[$i])".Length-3))($indice)"
               $indice++ 
            }
            
        }
        
    }
    
    write-output ("{0}" -f "$($listaDeArchEnPapelera -join "`n")")  | Out-File "$dirPapelera/.registro"
}

function restaurarArchivo {
    $archivoABuscar= $archivoARecuperar 
    $archivoABuscarSinPath=[io.path]::GetFileName("$archivoABuscar")
    $encontro="falso"

    $listaDeArchEnPapelera = New-Object -TypeName "System.Collections.ArrayList" 
    Get-Content -Path "$dirPapelera/.registro" | forEach {$listaDeArchEnPapelera.Add($_)} | Out-Null
    
    $cantArchivosEnPapelera=$listaDeArchEnPapelera.Count
    $cantArchivosParaRestaurar=contarCantArchivosParaRestaurar $cantArchivosEnPapelera $archivoABuscarSinPath

    if ($cantArchivosParaRestaurar -gt 1) {
        listarPapelera -mostrarEnumerado $archivoABuscarSinPath
        Write-Host ("Digite el numero de archivo a recuperar: ")
        $opc=Read-Host
        for($i=0; $i -lt $cantArchivosEnPapelera; $i++) {
            [String]$archivoASacar=[io.path]::GetFileName("$($listaDeArchEnPapelera[$i])")

            if("$archivoABuscarSinPath($opc)" -eq "$archivoASacar") {
                Move-Item -Force -Path "$dirPapelera/$archivoABuscarSinPath($opc)" "$($listaDeArchEnPapelera[$i])".Substring(0,"$($listaDeArchEnPapelera[$i])".Length-3)
                $encontro="verdadero"
                renombrarArchivos "$archivoABuscarSinPath" "$opc"
                break
            }
        }
    }
    elseif ($cantArchivosParaRestaurar -eq 1) {
        for($i=0; $i -lt $cantArchivosEnPapelera; $i++) {
            $archivoASacar=[io.path]::GetFileName($listaDeArchEnPapelera[$i])

            if("$archivoABuscarSinPath" -eq "$archivoASacar".Substring(0,"$archivoASacar".Length-3)) {
                Move-Item -Force -Path "$dirPapelera/$archivoASacar" "$($listaDeArchEnPapelera[$i])".Substring(0,"$($listaDeArchEnPapelera[$i])".Length-3)
                $encontro="verdadero"
                $listaDeArchEnPapelera.RemoveAt($i)
                if($listaDeArchEnPapelera.Count -ne 0) {
                    write-output ("{0}" -f "$($listaDeArchEnPapelera -join "`n")")  | Out-File "$dirPapelera/.registro" 
                } else {
                    write-output ("") | Out-File -NoNewline "$dirPapelera/.registro" 
                }
                break
            }
        }
    }
    
    if ($encontro -eq "verdadero") {
        Write-Host ("Se recupero el archivo")
    } else {
        Write-Host ("No se encontro el archivo especificado")
    }

}

function borrarArchivo {
    $i=1
    $archivoSinRuta="$([io.path]::GetFileName($archivoABorrar))"
    $nombreFinal="$archivoSinRuta($i)"

    while (Test-Path $dirPapelera/$nombreFinal) {
        $i++
        $nombreFinal="$archivoSinRuta($i)"
    }

    $dirAnterior="$([io.path]::GetDirectoryName((Get-ChildItem $archivoABorrar | % { $_.FullName })))"
    Move-Item -Force -Path $archivoABorrar -Destination "$dirPapelera/$nombreFinal"
    write-output ("$dirAnterior/$nombreFinal") | Out-File -Append "$dirPapelera/.registro"
    Write-Host ("El archivo que se elimino ahora es: $nombreFinal")
}

function limpiarPapelera {
    Remove-Item -Recurse -Verbose -Force "$dirPapelera" | Out-Null
    New-Item -Verbose -Path "$dirPapelera" -ItemType "Directory" | Out-Null
    New-Item -Verbose -Path "$dirPapelera" -Name ".registro" -ItemType "File" | Out-Null
}


function contarCantArchivosParaRestaurar {
    Param (
    [int]$cantDeArchivosEnPapelera,
    [String]$archABuscarSinPath
    )

    $cont=0
    for($i=0;$i -lt $cantDeArchivosEnPapelera; $i++) {
        $archAct="$($listaDeArchEnPapelera[$i])".Substring(0,"$($listaDeArchEnPapelera[$i])".Length-3)        
        $archAct=[io.path]::GetFileName($archAct)
        if ("$archAct" -eq "$archABuscarSinPath") {
            $cont++
        }
    }    

    return [int]$cont
}


if ( -Not (Test-Path -Path "$dirPapeleraCompr")) {
    New-Item -Path "$dirPapelera" -ItemType "Directory" | Out-Null
    New-Item -Path "$dirPapelera" -Name ".registro" -ItemType "File" | Out-Null
} else {
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$dirPapeleraCompr", "$dirPapelera", $true)
  #  Expand-Archive -Path "$dirPapeleraCompr" -DestinationPath "$HOME" | Out-Null
    Remove-Item -Force -Recurse "$dirPapeleraCompr"| Out-Null
}


if($l) {
    listarPapelera
}
elseif ($e) {
    limpiarPapelera
}
elseif ($r) {
    restaurarArchivo
}
else {
    borrarArchivo
}


Add-Type -Assembly System.IO.Compression.FileSystem
$compressionLevel = [System.IO.Compression.CompressionLevel]::Fastest
[System.IO.Compression.ZipFile]::CreateFromDirectory("$dirPapelera", "$dirPapeleraCompr", $compressionLevel, $false)
#Compress-Archive -CompressionLevel Fastest -Path "$dirPapelera" -DestinationPath "$dirPapeleraCompr" | Out-Null
remove-item -Force -Recurse $Global:dirPapelera | Out-Null

