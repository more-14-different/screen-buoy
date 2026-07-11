param(
    [switch]$Console,
    [switch]$Build,
    [switch]$Release,
    [switch]$StopOnly
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Stop-AppProcesses {
    Get-Process -Name "screen-buoy", "screen_buoy" -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 300
}

Stop-AppProcesses

if ($StopOnly) {
    exit 0
}

$profile = if ($Release) { "release" } else { "debug" }
$exePath = Join-Path $PSScriptRoot "src-tauri\target\$profile\screen-buoy.exe"
$srcTauriDir = Join-Path $PSScriptRoot "src-tauri"

$buildArgs = @("tauri", "build", "--no-bundle")
if (-not $Release) {
    $buildArgs += "--debug"
}

Push-Location $srcTauriDir
try {
    & cargo @buildArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Tauri build failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

if (-not (Test-Path -LiteralPath $exePath)) {
    throw "Built executable not found: $exePath"
}

if ((Get-Item -LiteralPath $exePath).Length -le 0) {
    throw "Built executable is empty: $exePath"
}

if ($Build) {
    exit 0
}

if ($Console) {
    & $exePath
    exit $LASTEXITCODE
}

Start-Process -FilePath $exePath -WorkingDirectory $PSScriptRoot
