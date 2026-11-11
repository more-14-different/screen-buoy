<#
.SYNOPSIS
    重启 (Kill 并 Boot) screen-buoy Debug 版
.DESCRIPTION
    无条件强制重新编译 Debug 版后再重启 (Kill 并 Boot)
#>
[CmdletBinding()]
param(
    [switch]$Console,
    [switch]$StopOnly
)

& "$PSScriptRoot\run-screen-buoy.ps1" -UseDebug @PSBoundParameters