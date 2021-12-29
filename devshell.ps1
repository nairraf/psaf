[CmdletBinding()]
param ()

$ps = [IO.Path]::PathSeparator
$srcRoot = Join-Path -Path $PSScriptRoot -ChildPath "src"

[Environment]::SetEnvironmentVariable("PSModulePath","$srcRoot$($ps)$([Environment]::GetEnvironmentVariable("PSModulePath"))")

Import-Module PSCliio -Force