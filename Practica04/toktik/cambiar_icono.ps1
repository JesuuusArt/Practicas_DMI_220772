param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('navidad', 'halloween', 'principal', 'valentines')]
    [string]$Temporada
)

$source = Join-Path $PSScriptRoot "assets\icons\$Temporada.png"

if (-not (Test-Path $source)) {
    Write-Error "No se encontro el icono: $source"
    exit 1
}

$mipmaps = @(
    "android\app\src\main\res\mipmap-mdpi\ic_launcher.png",
    "android\app\src\main\res\mipmap-hdpi\ic_launcher.png",
    "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png",
    "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png",
    "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
)

foreach ($relPath in $mipmaps) {
    $dest = Join-Path $PSScriptRoot $relPath
    Copy-Item -Path $source -Destination $dest -Force
}

Write-Host " Icono de la aplicacion actualizado a: $Temporada" -ForegroundColor Green
Write-Host "Ahora ejecuta 'flutter run' para compilar con el nuevo icono." -ForegroundColor Cyan
