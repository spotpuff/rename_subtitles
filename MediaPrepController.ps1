[CmdletBinding()]
param (
# Parameter help description
    [Parameter(Mandatory=$false)]
    [string]
    $Path = 'M:\downloads'
)

$directories = Get-ChildItem -Path $Path -Directory
if ($directories.count -gt 0)
{
    $directories | ForEach-Object { & $PSScriptRoot\Rename-Subtitles.ps1 -Path $_.FullName }
}
else
{
    Write-Output "No media directories found in $Path."
}
