<#
.Synopsis
   Removes extra files that are sometimes included in media downloads.
.DESCRIPTION
   Removes extra files that are sometimes included in media downloads.

   Some sites include .exe, .nfo, or .txt files in addition to media files.
.EXAMPLE
   .\Remove-ExtraFiles.ps1 'path/to/media'
#>
[CmdletBinding()]
Param
(
    # Path to the directory to rename subs in
    [Parameter(Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)]
    [string]
    $Path = 'M:\downloads'
)

# if parameterizing for show vs movie, will need different things probably, since movies have no season or whatever
# it's likely just 2k vs 4k
$files = Get-ChildItem -LiteralPath $Path -File
$pattern = '(?<showName>.*)(?<seasonNumber>\.[Ss]?\d{2})(?<episodeNumber>[Ee]?\d{2})(?<proper>\.PROPER\.)?(?<resolution>.\d{3,}p)?(?<meta>\..*)'

$tvDirectory = 'M:\tv\'

# Determine show name and episode number (for season) based on metadata but
# only for matches.
$files | ForEach-Object {
    if ($_.Name -match $pattern | Out-Null)
    {
        $showName = $Matches.showName.Replace('.', ' ')
        $seasonNumber = $Matches.seasonNumber.Replace('.', '').Replace('S', '').Replace('s', '')
        $episodeNumber = $Matches.episodeNumber.Replace('.', '').Replace('E', '').Replace('e', '')
    
        $showDirectory = Join-Path -Path $tvDirectory -ChildPath ("$showName\Season $([int]$seasonNumber)")
    
        # Create directory if needed and move item to that directory.
        if (!(Test-Path $showDirectory))
        {
            Write-Warning "Creating $showDirectory."
            New-Item $showDirectory -ItemType Directory
        }    
        Write-Output "Moving $showName - S$seasonNumber.E$episodeNumber to $showDirectory."
        Move-Item -LiteralPath $_.FullName -Destination $showDirectory
    }
    else
    {
        Write-Warning "$showName not recognized. File not moved."
    }
}
