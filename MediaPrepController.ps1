<#
.Synopsis
   Controller to handle renaming subtitles and moving media files to appropriate mediaItems.
.DESCRIPTION
   Controller to handle renaming subtitles and moving media files to appropriate mediaItems.
   This media prep controller should:
   1. Check for mediaItems/media files in the top level of the directory.
      Directories are likely movies, individual media files are likely TV shows.
   2. Rename subtitles for any mediaItems with "Subs" sub-directories.
   3. If movie, move to movie (2k/4k) directory. If TV, move to TV Show\Season directory.
.EXAMPLE
   .\MediaPrepController.ps1
#>

[CmdletBinding()]
Param
(
    # Parameter help description
    [Parameter(Mandatory = $false)]
    [string]
    $Path = 'M:\downloads'
)

$mediaDirectories = Get-ChildItem -LiteralPath $Path -Directory
if ($mediaDirectories.count -gt 0)
{
    $mediaDirectories | ForEach-Object {
        $currentItemPath = $_.FullName
        Write-Host $currentItemPath

        if (Test-Path -LiteralPath $currentItemPath -PathType Container)
        {
            # remove extraneous files
            Write-Host "Removing extra files in: $($currentItemPath)"
            & $PSScriptRoot\Remove-ExtraFiles.ps1 -Path $currentItemPath

            # Call Rename-Subtitles.ps1 script
            Write-Host "Renaming subtitles in: $($currentItemPath)"
            & $PSScriptRoot\Rename-Subtitles.ps1 -Path $currentItemPath
        }
    }
}
else
{
    Write-Warning "No media directories found in $($Path)."
}

# Move files
& $PSScriptRoot\Move-Media.ps1

# Cleanup empty subdirectories
& $PSScriptRoot\Remove-EmptyDirectories.ps1
