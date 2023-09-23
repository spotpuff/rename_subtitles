<#
.Synopsis
   Format subtitles for Plex for a TV series with subs in a subdir.
.DESCRIPTION
   Format subtitles for Plex for a TV series with subs in a subdir.

   Copies subtitles from a "Subs" subdirectory into the top level
   with the same name as the movie file in the top level directory.
.EXAMPLE
   .\Rename-Subtitles 'path/to/tv/series'
.EXAMPLE
   .\Rename-Subtitles 'path/to/tv/series' -AllLanguages
#>
[CmdletBinding()]
Param
(
    # Path to the directory to rename subs in
    [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)]
    $Path#,

    # # Enable switch to copy all subtitles. Renaming not working yet with this.
    # [Parameter(Mandatory = $false,
    #     ValueFromPipelineByPropertyName = $true,
    #     Position = 1)]
    # [switch]
    # $AllLanguages
)

$files = Get-ChildItem -LiteralPath $Path -File -Filter *.mp4

foreach ($file in $files)
{
    # get the subs for each file
    $temppath = Join-Path "$path\Subs" $file.basename
    Write-Output $temppath
    $subs = Get-ChildItem -LiteralPath $temppath -Filter *eng*.srt

    # copy subs
    $newSubs = $subs | Copy-Item -Destination $path -PassThru | Sort-Object Length -Descending

    # rename subs; making assumptions on which ones are which
    $subBaseName = $file.BaseName
    Rename-Item -LiteralPath $newSubs[0] "$subBaseName.eng.sdh.srt"
    Rename-Item -LiteralPath $newSubs[1] "$subBaseName.eng.srt"
    if ($subs.Count -eq 3)
    {
        Rename-Item $newSubs[2] "$subBaseName.eng.forced.srt"
    }
}
