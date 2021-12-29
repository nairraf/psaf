[CmdletBinding()]
param (
    [Parameter(Position=0,Mandatory=$false)] [string] $ModuleName="PSCliio",
    [Parameter(Mandatory=$false)] [switch] $Build,
    [Parameter(Mandatory=$false)] [switch] $Install,
    [Parameter(Mandatory=$false)] [switch] $UnInstall,
    [Parameter(Mandatory=$false)] [switch] $List
)

$ds = ([system.io.path]::DirectorySeparatorChar)
$projectRoot = (Get-Item $PSScriptRoot).Parent.FullName
$srcRoot = Join-Path -Path $projectRoot -ChildPath "src"
$BuildDir = Join-Path -Path $PSScriptRoot -ChildPath "build"
$ModuleDir = Join-Path -Path $srcRoot -ChildPath $ModuleName
$ModuleRepo = "$($ModuleName)DevRepo"
$config = Get-Content -Path "$PSScriptRoot$($ds)config.json" -Raw | ConvertFrom-Json

if ( (Test-Path -Path $BuildDir) -eq $false) {
    [void](New-Item -Path $BuildDir -ItemType Directory)
}

if ( (Get-PSRepository).Name -contains $ModuleRepo -eq $false) {
    Register-PSRepository -Name $ModuleRepo -SourceLocation $BuildDir -PublishLocation $BuildDir -InstallationPolicy Trusted
}

# make sure the the repository is pointing in the right place - in case directories were moved around during development
if ( (Get-PSRepository -Name $ModuleRepo).SourceLocation -ne $BuildDir) {
    [void](Unregister-PSRepository -Name $ModuleRepo)
    Register-PSRepository -Name $ModuleRepo -SourceLocation $BuildDir -PublishLocation $BuildDir -InstallationPolicy Trusted
}

if ($Build) {
    [void](Remove-Item -Path "$BuildDir$($ds)*.nupkg")
    Publish-Module -Path $ModuleDir -Repository $ModuleRepo -NuGetApiKey ($config.NugetApiKey)
    Write-Host "Package created"
}

if ($UnInstall) {
    Remove-Module "$($ModuleName)*" | Out-Null
    Uninstall-Module PSCliio | Out-Null
}

if ($Install -and (Test-Path -Path "$BuildDir$($ds)*.nupkg") ) {
    Remove-Module "$($ModuleName)*" | Out-Null
    Write-Host "Installing Module: $ModuleName"
    Install-Module $ModuleName -Repository $ModuleRepo -Scope CurrentUser -Force
    Import-Module $ModuleName
}

if ($List) {
    Get-Module -ListAvailable | Where-Object { $_.Name -match $ModuleName }
}