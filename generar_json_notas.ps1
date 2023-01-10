# ======================Inicio De Encabezado=======================

# Nombre del script: 5_APL2.ps1
# Número de ejercicio: 5
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

###### MODIFICAR ESTA AYUDA POR FAVOR NO OLVIDARSE ######

<#
.SYNOPSIS
El script genera un informe en formato JSON según archivos CSV.

.DESCRIPTION
El script obtiene archivos CSV desde una carpeta pasada por parámetro, que contienen calificaciones de alumnos en diferentes materias. Se unifica la información y se la almacena en un archivo JSON pasado por parámetro.

.PARAMETER Notas
Indica el directorio que contendrá los archivos CSV.

.PARAMETER Salida
Indica el archivo JSON que se creará con el informe total.

.EXAMPLE
./Jsonificador.ps1 -Notas "./carpeta/" -Destino "./carpeta destino/destino.JSON"
#>

[CmdletBinding()]
Param (
[parameter(Mandatory = $true)]
[ValidateNotNullOrEmpty()]
[ValidateScript( { Test-Path -PathType Container $_ } )]
[String] $Notas,

[parameter(Mandatory = $true)]
[ValidateNotNullOrEmpty()]
[String] $Salida
)

# Setea que todos los errores paren la ejecución del script
# lo que permite hacer un try catch en partes críticas
$erroractionPreference = "stop"

$nombre_completo = Get-ChildItem -Path "$Notas/*" -Include "*.csv"
$nombres = Get-ChildItem -Path $Notas -Name -Include "*.csv"

if ($null -eq $nombres) {
    Write-Warning "No se encontró ningún archivo CSV"
    exit 1
}

try {
    New-Item $Salida | Out-Null
}
catch {
    Write-Warning "No se pudo crear el archivo de salida (ruta inexistente o sin permisos)"
    exit 1
}

# Variable que se aumenta por cada archivo leído (se usa para
# determinar el nombre de las materias)
$j = 0

# Hashtable con todos los DNIs de todos los csv
$hashtable = @{}

# Array que contendrá en cada posición materia_DNI. Ejemplo: 1234_42333111
$hash = @()

foreach ($archivo in $nombre_completo) {
    
    # Conseguimos la cantidad de columnas del archivo (sin contar al DNI)
    $delimiter = ","
    $columnas = (Get-Content $archivo | ForEach-Object{($_.split($delimiter)).Count} | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum) - 1

    # Conseguimos el nombre de la materia actual
    $materia = $nombres[$j] -replace '_.*', ''
    
    # Conseguimos el encabezado para el csv
    $Header = @()
    $Header += 'DNI'
    for($i = 1; $i -le $columnas; $i++) {
        $Header += "N$i"
    }

    # Consigo el archivo en formato de tabla
    $tabla = Import-Csv -Path $archivo -Header $Header
    
    # Consigo todos los dnis del archivo
    $dnis = $tabla | Select-Object -Property DNI

    # Variable que representa la fila actual en el csv
    $i = 0

    $dnis | ForEach-Object {
        $dni = $_.DNI

        $hash += $materia + "_" + $dni

        # Armo una hashtable evitando repetir DNIs, donde cada DNI va a ser un array
        if ($hashtable.$dni -eq $null) {
            $hashtable.Add($dni, @())
        }
        
        $nota = 0

        # Loop por todas las columnas para hallar nota promedio
        for($l = 1; $l -le $columnas; $l++) {
            $notasColumna = $tabla | Select-Object -Property "N$l"
            $notaAct = $notasColumna[$i]."N$l"
    
            if($notaAct -eq 'r' -or $notaAct -eq 'R'){
                $nota += ((10/$columnas)/2)
            }
            elseif($notaAct -eq 'b' -or $notaAct -eq 'B'){
                $nota += ((10/$columnas))
            }
        }

        $i++

        # El dni de la hashtable va a ser igual a un array de hashtables

        $err = 0
        $hashtable.$dni.materia | ForEach-Object {
            if($_ -eq $materia){
                $err = 1
            }
        }
        #Evitamos que guarde en la hashtable un final repetido por un alumno
        if($err -eq 0){
            $hashtable.$dni += [ordered]@{materia = $materia; nota = [int][math]::Round($nota)}
        }
    }

    $j++
}

# Armamos un array que contenga la relación materia_DNI de los repetidos
# (un alumno no puede cursar la misma materia dos veces en la semana)

$hash2 = $hash | Select-Object -unique
$hash2 += "0"

$dniRepetido = @{}
$materiaTarget = @{}
$actas = @()

$repetido = Compare-Object -ReferenceObject $hash2 -DifferenceObject $hash

#Contemplamos el caso de que como minimo algun alumno repita alguna materia
if ($repetido.InputObject[0] -ne "0") {
    $cantidad = $repetido.count - 1

    #Conseguimos la materia y los dnis de los alumnos que repitan dicha materia
    for($j = 0; $j -lt $cantidad; $j++){ 
        $datosRepetidos = $repetido.InputObject[$j].Split("_")
        $dniRepetido[$j] = $datosRepetidos[1];
        $materiaTarget[$j] = $datosRepetidos[0];

        $dniAlumno = $dniRepetido[$j] | Out-String -NoNewline
        $materiaAlumno = $materiaTarget[$j] | Out-String -NoNewline

        Write-Warning "El alumno con DNI $dniAlumno curso la materia $materiaAlumno otra vez, entonces sus finales a dicha materia no se los incluira en el Json"
    }

    #A todos los finales invalidos los reemplazamos por un valor nulo
    $hashtable.Keys | ForEach-Object {
        $fallo = 0
        $j = 0

        $Alum = $_

        $hashtable.$_ | ForEach-Object {
            $fallo = 0
            $i = 0
            
            $mat = $_.materia
            $not = $_.nota

            #Veo si este final que estoy evaluando es un final invalido
            for($i = 0; $i -le $cantidad; $i++){
                if ($dniRepetido[$i] -eq $Alum){
                    if ($materiaTarget[$i] -eq $mat){
                        $fallo = 1
                    }
                }
            }
            if ($fallo -eq 1){
                $hashtable.$Alum[$j] = $null
            }
            $j++
        }
    }

    #Creamos una nueva hashtable que no contendra a los finales repetidos por algun alumno
    $hashtable2 = @{}

    $hashtable.keys | ForEach-Object {
        $alumno = $_
        $falla = 1

        $hashtable.$_ | ForEach-Object {
            if($_.materia -ne $null){
                $falla = 0
            }
        }

        #Le agregamos un nuevo alumno a la nueva hashtable solo cuando el alumno haya hecho como minimo un final valido
        if($falla -eq 0){
            $hashtable2.Add($alumno, @()) 
            $hashtable2.$alumno = $hashtable.$alumno | Where-Object { $_ -ne $null}
        }
    }
    #Llenamos las actas cuando algun alumno repite alguna materia
    $hashtable2.Keys | ForEach-Object {
        $actas += [ordered]@{dni = $_; notas = $hashtable2.$_}
    }
}
else{
    #Llenamos las actas cuando ningun alumno repite alguna materia
    $hashtable.Keys | ForEach-Object {
        $actas += [ordered]@{dni = $_; notas = $hashtable.$_}
    }
}

# Esta hashtable es solo para mostrar "actas" al inicio del JSON
$jsonListo = @{actas = $actas}

$jsonListo | ConvertTo-Json -Depth 5 > $Salida
