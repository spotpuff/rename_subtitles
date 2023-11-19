<#
.Synopsis
   Controller to handle renaming subtitles and moving media files to appropriate directories.
.DESCRIPTION
   Controller to handle renaming subtitles and moving media files to appropriate directories.
   This media prep controller should:
   1. Check for directories/media files in the top level of the directory.
      Directories are likely movies, individual media files are likely TV shows.
   2. Rename subtitles for any directories with "Subs" sub-directories.
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

$directories = Get-ChildItem -LiteralPath $Path -Directory
if ($directories.count -gt 0)
{
    $directories | ForEach-Object {
        # remove extraneous files
        Write-Output "Removing extra files in: $($_.FullName)"
        & $PSScriptRoot\Remove-ExtraFiles.ps1 -Path $_.FullName

        # Check if there are multiple files over 5MB (non-sample video files)
        # Call Rename-Subtitles.ps1 script
        Write-Output "Renaming subtitles in: $($_.FullName)"
        & $PSScriptRoot\Rename-Subtitles.ps1 -LiteralPath $_.FullName
    }
}
else
{
    Write-Output "No media directories found in $Path."
}

Pause
