[CmdletBinding()]
param (
    # Parameter help description
    [Parameter(Mandatory = $false)]
    [string]
    $Path = 'M:\downloads'
)

$directories = Get-ChildItem -Path $Path -Directory
if ($directories.count -gt 0)
{
    $directories | ForEach-Object {
        # remove extraneous files
        & $PSScriptRoot\Remove-ExtraFiles.ps1 -Path $_.FullName    

        # check if there are multiple files over 5MB (anything less is assumed to be a subtitle)
        # if there are, assume it's a TV series
        $videoFiles = Get-ChildItem $_.FullName | Where-Object { $_.length -gt '5MB' }
        if ($videoFiles.count -gt 1)
        {
            & $PSScriptRoot\Rename-SubtitlesTv.ps1 -Path $_.FullName
        }
        else
        {
            & $PSScriptRoot\Rename-Subtitles.ps1 -Path $_.FullName
        }
    }
}
else
{
    Write-Output "No media directories found in $Path."
}
