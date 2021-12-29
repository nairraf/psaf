[CmdletBinding()]
param ()

foreach ($folder in @('members')) {
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder

    if (Test-Path -Path $root) {
        foreach ($file in (Get-ChildItem -Path $root -Filter *.ps1)) {
            . $file.FullName
        }
    }
}

$publicMembersFile = Join-Path -Path $PSScriptRoot -ChildPath "members" | Join-Path -ChildPath "exports"
Export-ModuleMember -Function (Get-Content -Path $publicMembersFile)