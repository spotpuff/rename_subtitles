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
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Path = 'M:\downloads',

    [parameter(Mandatory = $false, Position = 1)]
    [string]$TvMediaPattern = '(?<showName>.*)(?<seasonNumber>\.[Ss]?\d{2})(?<episodeNumber>[Ee]?\d{2})(?<proper>\.PROPER)?(?<resolution>\.\d{3,}p)?(?<meta>\..*)'
)

# Function to process a TV show. Analagous movie function also exists.
Function Move-TvShow()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$TvMediaPattern = $TvMediaPattern,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-Path -LiteralPath $_ -ItemType Directory })]
        [string]$TvDestinationPath = 'M:\tv\'
    )

    # If working on directory, get child items first. Then move media + subs.
    if (Test-Path -LiteralPath $Path -PathType Leaf)
    {
        # Determine show name and episode number (for season) based on item name.
        if ( $Path -match $TvMediaPattern)
        {
            $showName = $Matches.showName.Replace('.', ' ')
            $seasonNumber = $Matches.seasonNumber.Replace('.', '').Replace('S', '').Replace('s', '')
            $episodeNumber = $Matches.episodeNumber.Replace('.', '').Replace('E', '').Replace('e', '')

            $tvShowDirectory = Join-Path -Path $TvDestinationPath -ChildPath ("$showName\Season $([int]$seasonNumber)")

            # Create directory if needed and move item to that directory.
            if (!(Test-Path $tvShowDirectory))
            {
                Write-Warning "Creating $tvShowDirectory."
                New-Item $tvShowDirectory -ItemType Directory
            }

            Write-Output "Moving $showName - S$seasonNumber.E$episodeNumber to $tvShowDirectory."
            Move-Item -LiteralPath $_.FullName -Destination $tvShowDirectory
        }
        else
        {
            Write-Warning 'Media name not recognized. Media files not moved.'
        }
    }
}

Function Move-Movie()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$4kDestinationPath = 'M:\4K movies\',

        [Parameter(Mandatory = $false)]
        [string]$2kDestinationPath = 'M:\2K movies\New'
    )

    if ($_.fullname -match '.*2160p.*')
    {
        Write-Host "Moving $($Path.basename) to 4k movies"
        Move-Item -Path $Path -Destination $4kDestinationPath
    }
    else
    {
        Write-Host "Moving $($Path.basename) to new 2k movies"
        Move-Item -Path $Path -Destination $2kDestinationPath
    }
}

# if parameterizing for show vs movie, will need different things probably, since movies have no season or whatever
# it's likely just 2k vs 4k
$mediaItems = Get-ChildItem -LiteralPath $Path -File

# If the directory/file name matches this pattern it's very likely a TV show.
$mediaItems | ForEach-Object {
    if ($_.name -match $TvMediaPattern)
    {
        Move-TvShow -Path $_.FullName
    }
    else
    {
        Move-Movie -Path $_.FullName
    }
}
