# Arranca el emulador con la misma zona horaria que la laptop.
#
# El emulador de Android SIEMPRE arranca en GMT, no en la zona de Windows.
# La app usa DateTime.now(), o sea la hora del dispositivo donde corre: sin
# este ajuste, en el emulador sale 6 horas desfasada (3:25 p.m. cuando en la
# laptop son las 9:25 a.m.).
#
# Ni config.ini (hw.initialTimeZone, persist.sys.timezone) ni el flag -prop del
# emulador lo respetan, y la consola no expone el comando. La unica via que
# funciona es poner la propiedad desde root una vez que el sistema arranca.
#
#   Uso:  powershell -ExecutionPolicy Bypass -File tool\start_emulator.ps1

$ErrorActionPreference = 'Stop'

# Zona IANA (formato de Android). Cambiala si no es la tuya.
$zona = 'America/Mexico_City'

$sdk = "$env:LOCALAPPDATA\Android\Sdk"
$emulator = "$sdk\emulator\emulator.exe"
$adb = "$sdk\platform-tools\adb.exe"
$avd = 'Pixel_10'

function Adb([string[]]$argsList) {
    $out = & $adb @argsList 2>&1
    return ($out | Out-String).Trim()
}

$offsetLaptop = [System.TimeZoneInfo]::Local.GetUtcOffset((Get-Date))

Write-Host "Laptop: $((Get-Date).ToString('HH:mm:ss')) (UTC$offsetLaptop)"

$corriendo = Adb @('devices') -match $avd -or (Adb @('devices') -match 'emulator-\d+\s+device')
if (-not $corriendo) {
    Write-Host "Arrancando $avd..."
    Start-Process -FilePath $emulator -ArgumentList '-avd', $avd, '-no-snapshot-load'
    Start-Sleep -Seconds 10
    Adb @('wait-for-device') | Out-Null
}

$limite = (Get-Date).AddMinutes(10)
do {
    $boot = Adb @('shell', 'getprop', 'sys.boot_completed')
    if ($boot -eq '1') { break }
    Start-Sleep -Seconds 5
} while ((Get-Date) -lt $limite)

if ($boot -ne '1') {
    throw 'El emulador no termino de arrancar en 10 minutos.'
}
Write-Host 'Emulador listo. Aplicando zona horaria...'

# adbd corre como shell y no puede tocar persist.*: hay que reiniciarlo
# como root primero.
Adb @('root') | Out-Null
Start-Sleep -Seconds 6
Adb @('wait-for-device') | Out-Null
Adb @('shell', 'setprop', 'persist.sys.timezone', $zona) | Out-Null
Start-Sleep -Seconds 2

$tzEmulador = Adb @('shell', 'getprop', 'persist.sys.timezone')
Write-Host "Zona emulador: $tzEmulador"
Write-Host "Emulador  : $(Adb @('shell', 'date'))"
Write-Host "Laptop    : $((Get-Date).ToString('ddd dd HH:mm:ss')) (UTC$offsetLaptop)"

if ($tzEmulador -eq 'GMT') {
    Write-Warning 'La zona sigue en GMT: algo no aplico el cambio.'
} else {
    Write-Host 'Listo: la hora de la app ya coincide con la de la laptop.' -ForegroundColor Green
}
