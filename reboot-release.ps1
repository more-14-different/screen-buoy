<#
.SYNOPSIS
    重启 (Kill 并 Boot) screen-buoy Release 版
.DESCRIPTION
    缺失时自动 build，不缺失时纯启动/纯重启 (Kill 并 Boot)
#>
[CmdletBinding()]
param(
    [switch]$Rebuild,
    [switch]$StopOnly
)

& "$PSScriptRoot\run-screen-buoy.ps1" -Release @PSBoundParameters
