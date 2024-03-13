<#
.Synopsis
   Removes empty media directories created while moving media.
.DESCRIPTION
   Removes empty media directories created while moving media.

   For TV shows that are downloaded in a directory, they leave an empty directory
   behind after the media within are moved.
.EXAMPLE
   .\Remove-DirectoriesWithoutMedia.ps1 -Path 'path/to/media'
#>
[CmdletBinding()]
Param
(
    # Path to the directory to rename subs in
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Path = 'M:\downloads',
    
    [parameter(Mandatory = $false, Position = 1)]
    [string[]]$MediaFileTypes = @('.srt', '.mkv', '.mp4', '.mpeg4')
)

$mediaDirectories = Get-ChildItem -LiteralPath $Path -Directory
$mediaDirectories | ForEach-Object {
    $mediaFiles = Get-ChildItem -File -Recurse | Where-Object { $_.Extension -in $MediaFileTypes }
    $baseDirectory = Split-Path -Path $_.FullName -Leaf
    if ($mediaFiles.count -eq 0)
    {
        Write-Host "$($baseDirectory) was empty; removing it."
        Remove-Item -LiteralPath $_.FullName
    }
    else
    {
        Write-Warning "$($baseDirectory) wasn't empty. Aborting deletion."
    }
}
