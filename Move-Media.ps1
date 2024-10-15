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
    [string]$TvMediaPattern = '(?<showName>.*)(?<seasonNumber>\.[Ss]\d{2})(?<episodeNumber>[Ee]\d{2})?(?<proper>\.PROPER)?(?<resolution>\.\d{3,}p)?(?<meta>\..*)'
)

# Function to process a TV show. Analagous movie function also exists.
Function Move-TvShow()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # If working on directory, get child items first. Then move media + subs.
    if (Test-Path -LiteralPath $Path -PathType Container)
    {
        Move-TvShowDirectory -Path $Path
    }
    else
    {
        Move-TvShowFile -Path $Path
    }
}

Function Move-TvShowFile()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$TvRegexPattern = $TvMediaPattern,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-Path -LiteralPath $_ -ItemType Directory })]
        [string]$TvDestinationPath = 'M:\tv\'
    )

    # If working on directory, get child items first. Then move media + subs.
    $filename = Split-Path $Path -Leaf

    # Determine show name and episode number (for season) based on item name.
    if ( $filename -match $TvRegexPattern)
    {
        $showName = $Matches.showName.Replace('.', ' ')
        $seasonNumber = $Matches.seasonNumber.Replace('.', '').Replace('S', '').Replace('s', '')
        $episodeNumber = $Matches.episodeNumber.Replace('.', '').Replace('E', '').Replace('e', '')

        $tvShowDirectory = Join-Path -Path $TvDestinationPath -ChildPath $("$showName\Season $([int]$seasonNumber)")

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

Function Move-TvShowDirectory
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Get Child items and call move-tv show on each
    $mediaFileTypes = @('.srt', '.mkv', '.mp4', '.mpeg4')
    $filesTomove = Get-ChildItem -LiteralPath $Path | Where-Object { $_.Extension -in $mediaFileTypes }
    $filesTomove | ForEach-Object { Move-TvShowFile $_.FullName }
}

Function Move-Movie()
{
    [CmdletBinding()]
    param
    (
        # The supplied path to he movie file/directory.
        [Parameter(Mandatory = $true)][string]$Path,
        # Destination path for 4K movies.
        [Parameter(Mandatory = $false)][string]$4kDestinationPath = 'M:\4K movies\',
        # Destination path for 2K movies.
        [Parameter(Mandatory = $false)][string]$2kDestinationPath = 'M:\2K movies\New'
    )

    function New-MovieDirectoryFromMovieFile()
    {
        param
        (
            [parameter(Mandatory = $true)][string]$Path
        )

        $movieFile = Get-Item -LiteralPath $Path
        $movieDirectoryPath = Join-Path -Path $moviefile.Directory -ChildPath $movieFile.BaseName
        
        if (-not (Test-Path -Path $movieDirectoryPath))
        {
            New-Item -Path $movieDirectoryPath -ItemType Directory
        }
        else
        {
            Write-Warning "Path $($movieDirectoryPath) already exists, using existing directory."
        }
        
        Write-Output [string]$movieDirectoryPath
    }

    function Move-MovieDirectory
    {
        param
        (
            [Parameter(Mandatory = $true)][string]$Path
        )
        
        if ($_.fullname -match '.*2160p.*')
        {
            Write-Host "Moving $(Split-Path -Path $Path -Leaf) to $($4kDestinationPath)"
            Move-Item -LiteralPath $Path -Destination $4kDestinationPath
        }
        else
        {
            Write-Host "Moving $(Split-Path -Path $Path -Leaf) to $($2kDestinationPath)"
            Move-Item -LiteralPath $Path -Destination $2kDestinationPath
        }
    }

    # If movie is in a directory, move it, otherwise create a directory with
    # the same name and then move it.
    if (Test-Path -LiteralPath $Path -PathType Container)
    {
        Move-MovieDirectory -Path $Path
    }
    else
    {
        $newMovieDirectory = New-MovieDirectoryFromMovieFile -Path $Path
        Move-Item -LiteralPath $Path -Destination $newMovieDirectory
        Move-MovieDirectory -Path $newMovieDirectory
    }
}

# If parameterizing for show vs movie, will need different things probably, since movies have no season or whatever
# it's likely just 2k vs 4k.
$mediaItems = Get-ChildItem -LiteralPath $Path
$mediaFileTypes = @('.srt', '.mkv', '.mp4', '.mpeg4')

# If the directory/file name matches this pattern it should be a TV show.
$mediaItems | ForEach-Object {
    $mediaItem = Get-Item -LiteralPath $_.FullName
    
    switch ($true)
    {
        
        ($mediaItem.Name -match $TvMediaPattern)
        {
            Move-TvShow -Path $mediaItem.FullName
            break
        }
        
        (Test-Path -LiteralPath $mediaItem.FullName -PathType Container)
        {
            $mediaFiles = Get-ChildItem -LiteralPath $mediaItem.FullName | Where-Object { $_.Extension -in $mediaFileTypes }
            if ($mediaFiles.Count -gt 0)
            {
                Move-Movie -Path $mediaItem.FullName
            }
            break
        }
        
        ($mediaItem.Extension -in $mediaFileTypes)
        {
            Move-Movie -Path $mediaItem.FullName
            break
        }
        
        default
        {
            Write-Host "Couldn't match media pattern. Process stopped."
        }
        
    }    
}
