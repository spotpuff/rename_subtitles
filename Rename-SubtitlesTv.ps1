# subtitle stuff
$path = 'M:\tv\The Sandman\The.Sandman.S01.1080p.WEBRip.x265-RARBG'
$files = Get-ChildItem $path -File -Filter *.mp4

foreach ($file in $files)
{
    # get the subs
    $temppath = Join-Path "$path\Subs" $file.basename
    "$tempPath $(Test-Path $temppath)"
    $subs = Get-ChildItem $temppath -Filter *eng*.srt
    
    # copy subs
    $newSubs = $subs | Copy-Item -Destination $path -PassThru | Sort-Object Length -Descending
    
    # rename subs; making assumptions on which ones are which
    $subBaseName = $file.BaseName
    Rename-Item $newSubs[0] "$subBaseName.eng.sdh.srt"
    Rename-Item $newSubs[1] "$subBaseName.eng.srt"
    if ($subs.Count -eq 3)
    {
        Rename-Item $newSubs[2] "$subBaseName.eng.forced.srt"
    }
}