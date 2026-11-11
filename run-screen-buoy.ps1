param(
    [switch]$Console,
    [switch]$Build,
    [switch]$Release,
    [switch]$UseDebug,
    [switch]$Rebuild,
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
    Write-Host "[✓] screen-buoy 已停止。" -ForegroundColor Green
    exit 0
}

# Profile selection: -UseDebug 为 debug，默认与 -Release 均为 release
$profile = if ($UseDebug) { "debug" } else { "release" }
$exePath = Join-Path $PSScriptRoot "src-tauri\target\$profile\screen-buoy.exe"
$srcTauriDir = Join-Path $PSScriptRoot "src-tauri"

# Build logic:
# Debug: 无条件强制 rebuild 后再 reboot (kill 并 boot)
# Release: 缺失时自动 build，不缺失时纯启动/纯重启 (kill 并 boot)
$needBuild = $false
if ($UseDebug -or $Rebuild -or $Build) {
    $needBuild = $true
} else {
    if (-not (Test-Path -LiteralPath $exePath) -or ((Get-Item -LiteralPath $exePath -ErrorAction SilentlyContinue).Length -le 0)) {
        $needBuild = $true
    }
}

if ($needBuild) {
    Write-Host "Building screen-buoy ($profile)..." -ForegroundColor Cyan
    $buildArgs = @("tauri", "build", "--no-bundle")
    if ($UseDebug) {
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

$repoConfigPath = Join-Path $srcTauriDir "config.toml"
$runtimeConfigPath = Join-Path (Split-Path -Parent $exePath) "config.toml"
if ((Test-Path -LiteralPath $repoConfigPath) -and (-not (Test-Path -LiteralPath $runtimeConfigPath))) {
    Copy-Item -LiteralPath $repoConfigPath -Destination $runtimeConfigPath -Force
}

if ($Console) {
    & $exePath
    exit $LASTEXITCODE
}

Write-Host "Starting screen-buoy ($profile)..." -ForegroundColor Green
$res = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine      = "`"$exePath`""
    CurrentDirectory = $PSScriptRoot
} -ErrorAction SilentlyContinue
if (-not $res -or $res.ReturnValue -ne 0) {
    Start-Process -FilePath $exePath -WorkingDirectory $PSScriptRoot
}
