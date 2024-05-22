<#
.Synopsis
   Format subtitles for Plex.
.DESCRIPTION
   Format subtitles for Plex.

   Copies subtitles from a "Subs" subdirectory into the top level
   with the same name as the movie file in the top level directory.
.EXAMPLE
   .\Rename-Subtitles -Path 'Path/to/directory/with/media'
.EXAMPLE
   .\Rename-Subtitles -Path 'Path/to/directory/with/media' -AllLanguages
#>

Param
(
    # Path to the directory to rename subs in
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    # Enable switch to copy all subtitles. Renaming not working yet with this.
    [Parameter(Mandatory = $false, Position = 1)]
    [switch]$AllLanguages
)

[string]$movieSizeFloor = '5MB'
[string[]]$videoFileExtensions = @('.mkv', '.mp4', '.mpeg4', '.mpeg', '.mpg', '.avi')
[string]$englishSubtitleFilterString = '*eng*.srt'

Function Rename-MovieSubtitles()
{
    [CmdletBinding()]
    Param
    (
        # Path to the directory to rename subs in
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        # Enable switch to copy all subtitles. Renaming not working yet with this.
        [Parameter(Mandatory = $false, Position = 1)]
        [switch]$AllLanguages
    )

    # Get the subs from the subdir and the movie file name
    Begin
    {
        $dirName = Split-Path $Path -Leaf

        # get movies; if more than one, pick the biggest one
        $movieFiles = Get-ChildItem -LiteralPath $Path -File | Where-Object { $_.Extension -in $videoFileExtensions -and $_.Length -gt $movieSizeFloor }
        if (-not $movieFiles)
        {
            $logText = "$dirName - No movie file found."
            Write-Warning $logText
            return
        }
        else
        {
            $movieFile = $movieFiles | Sort-Object Length -Descending | Select-Object -First 1
        }

        # check if sub exists
        $subPath = Join-Path $Path "$($movieFile.Basename).en.srt"
        if (Test-Path -LiteralPath $subPath)
        {
            $logText = "$dirName - Subtitle already exists."
            Write-Warning $logText
            return
        }

        # Get subs subdir
        $subsDir = Get-ChildItem -LiteralPath $Path -Filter 'Subs'
        if (-not $subsDir)
        {
            $logText = "$dirName - No subs dir found."
            Write-Warning $logText
            return [bool]$foundSubs = $false
        }

        # get English only by default
        if (-not $AllLanguages)
        {
            $subs = Get-ChildItem -LiteralPath $subsDir.FullName -Filter $englishSubtitleFilterString
        }
        else
        {
            $subs = Get-ChildItem -LiteralPath $subsDir.FullName -Filter '*.srt'
        }

        if ($subs.count -eq 0)
        {
            $logText = "$dirName - No subtitles found."
            Write-Warning $logText
            return [bool]$foundSubs = $false
        }
    }

    # Copy Subs from subs subdirectory to the target Path and rename to movie file.
    Process
    {
        if ($foundSubs)
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
    }

    End
    {
        $logText = "$dirName subtitles moved and renamed."
        Write-Output $logText
    }
}

Function Rename-TvSubtitles()
{
    [CmdletBinding()]
    Param
    (
        # Path to the directory to rename subs in
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Path,

        # Enable switch to copy all subtitles. Renaming not working yet with this.
        [Parameter(Mandatory = $false, Position = 1)]
        [switch]
        $AllLanguages
    )

    $videoFiles = Get-ChildItem -LiteralPath $Path -File | Where-Object { $_.Extension -in $videoFileExtensions }

    foreach ($file in $videoFiles)
    {
        # get the subs for each file; subs are usually in \Subs\<episode name>
        $tempPath = Join-Path -Path $Path -ChildPath "Subs\$($file.basename)"

        if (-not $AllLanguages)
        {
            Write-Verbose "AllLanguages = $false"
            $subs = Get-ChildItem -LiteralPath $tempPath -Filter $englishSubtitleFilterString 

            # copy subs
            $newSubs = $subs | Copy-Item -Destination $Path -PassThru | Sort-Object Length -Descending

            # rename subs; making assumptions on which ones are which
            $subBaseName = $file.BaseName

            switch ($newSubs.Count)
            {
                0 { Write-Host 'No subtitles found.'; break }
                { $_ -ge 1 } { Rename-Item -LiteralPath $newSubs[0] "$($subBaseName).eng.srt" }
                { $_ -ge 2 } { Rename-Item -LiteralPath $newSubs[1] "$($subBaseName).eng.srt" }
                { $_ -ge 3 } { Rename-Item -LiteralPath $newSubs[2] "$($subBaseName).eng.forced.srt"; break }
            }
        }
        else
        {
            Write-Verbose "AllLanguages = $true"
            $subs = Get-ChildItem -LiteralPath $tempPath -Filter '*.srt' 

            # copy subs
            $newSubs = $subs | Copy-Item -Destination $Path -PassThru | Sort-Object Length -Descending

            # rename subs; making assumptions on which ones are which
            $subBaseName = $file.BaseName

            $newSubs | ForEach-Object { Rename-Item "$($subBaseName)" }

            Rename-Item -LiteralPath $newSubs[0] "$($subBaseName).eng.sdh.srt"
            Rename-Item -LiteralPath $newSubs[1] "$($subBaseName).eng.srt"
            if ($subs.Count -eq 3)
            {
                Rename-Item $newSubs[2] "$($subBaseName).eng.forced.srt"
            }
        }
    }
}

# Actual subtitle processing here.
$videoFiles = Get-ChildItem -LiteralPath $Path |
    Where-Object { $_.Extension -in $videoFileExtensions -and $_.length -gt $movieSizeFloor }

if ($videoFiles.count -gt 1)
{
    Write-Output "Renaming tv subtitles in: $(Split-Path $Path -Leaf)"
    Rename-TvSubtitles -Path $Path -AllLanguages:$AllLanguages
}
else
{
    Write-Output "Renaming movie subtitles in: $(Split-Path $Path -Leaf)"
    Rename-MovieSubtitles -Path $Path -AllLanguages:$AllLanguages
}
