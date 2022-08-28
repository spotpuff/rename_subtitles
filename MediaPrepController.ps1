[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Path = 'M:\downloads'
)

$directories = Get-ChildItem -Path $Path -Directory
if ($directories.count -gt 0)
{
    ForEach-Object { & $PSScriptRoot\Rename-Subtitles.ps1 -Path $_.FullName }
}
else
{
    Write-Output "No media directories found in $Path."
}
