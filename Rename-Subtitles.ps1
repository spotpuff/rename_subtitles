<#
.Synopsis
   Format subtitles for Plex.
.DESCRIPTION
   Format subtitles for Plex.

   Copies subtitles from a "Subs" subdirectory into the top level
   with the same name as the movie file in the top level directory.
.EXAMPLE
   .\Rename-Subtitles 'path/to/movie'
.EXAMPLE
   .\Rename-Subtitles 'path/to/movie' -AllLanguages
#>
[CmdletBinding()]
Param
(
    # Path to the directory to rename subs in
    [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)]
    $Path,

    # Enable switch to copy all subtitles. Renaming not working yet with this.
    [Parameter(Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        Position = 1)]
    [switch]
    $AllLanguages
)

# Get the subs from the subdir and the movie file name
Begin
{
    $dirName = Split-Path $Path -Leaf

    # get movies; if more than one, pick the biggest one
    $movieFormatList = @('*.mkv', '*.mp4', '*.mpeg4', '*.mpeg', '*.mpg', '*.avi')
    $movieFiles = Get-ChildItem -Path $Path\* -Include $movieFormatList
    if (-not $movieFiles)
    {
        $logText = "$dirName - No movie file found."
        Write-Warning $logText
        Exit
    }
    else
    {
        $movieFile = $movieFiles | Sort-Object Length -Descending | Select-Object -First 1
    }

    # check if sub exists
    $subPath = Join-Path $Path "$($movieFile.Basename).eng.srt"
    if (Test-Path $subPath)
    {
        $logText = "$dirName - Subtitle already exists."
        Write-Warning $logText
        Exit
    }

    # Get subs subdir
    $subsDir = Get-ChildItem -Path $path -Filter 'Subs'
    if (-not $subsDir)
    {
        $logText = "$dirName - No subs dir found."
        Write-Output $logText
    }

    # get English only by default
    if (-not $AllLanguages)
    {
        $subFilter = @('*english*.srt')
        $subs = Get-ChildItem -Path "$($subsDir.FullName)\*" -Include $subFilter
    }
    else
    {
        $subs = Get-ChildItem -Path $subsDir.FullName -Filter '*.srt'
    }

    if (-not $subs)
    {
        $logText = "$dirName - No subtitles found."
        Write-Warning $logText
        Exit
    }
}

# Copy Subs from subs subdirectory to the target Path and rename to movie file.
Process
{
    $newSubs = $subs | Copy-Item -Destination $Path -PassThru

    # if only 1 sub, assume it's English
    if ($newSubs.Count -eq 1)
    {
        Rename-Item $newSubs[0].FullName -NewName "$($movieFile.BaseName).eng.srt" -ErrorAction Stop
    }
    else # if there are more than 3 subs I duno what to do lol
    {
        # if more than one sub, assume order is:
        # 1. SDH
        # 2. ENG
        # 3. Forced
        $logText = "$dirName 2+ English subtitles found."
        Write-Warning $logText
        $sortedNewSubs = $newSubs | Sort-Object Length -Descending
        Rename-Item $sortedNewSubs[0].FullName -NewName "$($movieFile.BaseName).eng.sdh.srt" -ErrorAction Stop
        Rename-Item $sortedNewSubs[1].FullName -NewName "$($movieFile.BaseName).eng.srt" -ErrorAction Stop
        if ($sortedNewSubs.count -eq 3)
        {
            Rename-Item $sortedNewSubs[2].FullName -NewName "$($movieFile.BaseName).eng.forced.srt" -ErrorAction Stop
        }
    }
}

End
{
    $logText = "$dirName subtitles moved and renamed."
    Write-Output $logText
}
