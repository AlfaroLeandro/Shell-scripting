# ======================Inicio De Encabezado=======================

# Nombre del script: 3_APL2.ps1
# Número de ejercicio: 3
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

# ------------- Ayuda ------------------ #

<#
.SYNOPSIS
	este script puededeterminar que archivos son copia de otros archivos (por su contenido) para posteriormente tomar
	Además, se debe generar un archivo log en otro directorio donde se listen los archivos repetidos con su 
    ubicaci�n original, cuyo nombre ser� Resultado_[YYYYMMDDHHmm].out.
.INPUTS
    -Directorio: directorio donde se generan los archivos generados por el proceso. El mismo puede contener subdirectorios y los archivos encontrarse dentro o fuera de estos.
    -DirectorioSalida: directorio donde se guarda el archivo log, no debe ser el mismo directorio que -Directorio.
    -Umbral: tama�o en KB a partir del cual se empezar�n a evaluar si los archivos presentan duplicados en el directorio.
#>


# ------------ Validaciones ---------------- #

Param (
[Parameter(Mandatory = $true)] 
[ValidateScript({
    if( -Not ($_ | Test-Path) ){
        throw "Directorio no existe"
    }
    return $true
})]
[ValidateNotNullOrEmpty()]
[System.String] $Directorio,
[Parameter(Mandatory = $true)] 
[ValidateScript({
    if( -Not ($_ | Test-Path) ){
        throw "Directorio no existe"
    }
    return $true
})]
[ValidateNotNullOrEmpty()]
[System.String] $DirectorioSalida,
[Parameter(Mandatory = $true)]
[ValidateScript({
    if( $_ -lt 0 ){
        throw "Ingresar un numero mayor o igual a 0"
    }
    return $true
})]
[ValidateNotNullOrEmpty()]
[int]$Umbral
)

$ErrorActionPreference = "stop"

if ("$Directorio" -eq "$DirectorioSalida") {
    throw "El directorio origen no puede ser igual el directorio destino"
}

$listaDeRepetidos = New-Object -TypeName "System.Collections.ArrayList" 

# ------------ Funciones ---------------- #

function buscar_duplicados {
    param (
        [Parameter(Mandatory=$true, Position=1)] [System.String]$Directory
    )
    
    ForEach ($archivo1 in $mayores){
        [boolean]$seRepite=$false
        
        ForEach ($archivo2 in $mayores){
            if($archivo1 -ne $archivo2) {
                $contenidoArch1 = Get-Content($archivo1)
                $contenidoArch2 = Get-Content($archivo2)
                
				if($contenidoArch1.Length -eq 0 -or $contenidoArch2.Length -eq 0) {
                    if($contenidoArch1.Length -eq $contenidoArch2.Length) {
                        $listaDeRepetidos.Add($(write-output("  {0,-20}`t{1}" -f [io.path]::GetFileName($archivo2) , [io.path]::GetDirectoryName($archivo2)))) | Out-Null
					    $seRepite=$true    
                    }
                }
				elseif ([String]::IsNullOrEmpty((Compare-Object -ReferenceObject $(Get-Content $archivo1) -DifferenceObject $(Get-Content $archivo2)))) {
					$listaDeRepetidos.Add($(write-output("  {0,-20}`t{1}" -f [io.path]::GetFileName($archivo2) , [io.path]::GetDirectoryName($archivo2)))) | Out-Null
					$seRepite=$true
				}
            }
        }
        if($seRepite) {
            $listaDeRepetidos.Add($(write-output("  {0,-20}`t{1}" -f [io.path]::GetFileName($archivo1) , [io.path]::GetDirectoryName($archivo1)))) | Out-Null 
        }
        $listaDeRepetidos.add("") | Out-Null
    }

    for($i=0; $i -lt $listaDeRepetidos.Count; $i++) {
        if($listaDeRepetidos[$i] -ne "") {
            for($j=$i+1; $j -lt $listaDeRepetidos.Count; $j++) {
                if("$($listaDeRepetidos[$i])" -eq "$($listaDeRepetidos[$j])") {
                    $listaDeRepetidos.RemoveAt($j) | Out-Null
                    $j--
                }
            }
        }
    }
}


function buscar_por_umbral {
    param (
        [Parameter(Mandatory=$true, Position=1)]
        [System.Double]$size
    )

    $size=[math]::round($size*1024) 
    try {
    $Global:mayores=Get-ChildItem -Path "$Directorio" -Recurse -File | Where-Object {$_.Length -ge $size} | % { $_.FullName }
    } catch {
        Write-Error ("Permisos erroneos al intentar leer los archivos")
        exit 1
    }
}

# --------------- main -------------------#

$date = Get-Date -UFormat "%Y%m%d%H%M"

$path_informe="$DirectorioSalida/Resultado_$date.out"

buscar_por_umbral -size "$Umbral"
buscar_duplicados -Directory "$Directorio"
write-output("{0}" -f "$($listaDeRepetidos -join "`n")")  | Out-File "$path_informe"
Get-Content -Path "$path_informe" | Get-Unique | Out-File "auxiliar.txt"
Get-Content -Path "auxiliar.txt" | Out-File "$path_informe"
Remove-Item "auxiliar.txt"
Get-Content -Path $path_informe