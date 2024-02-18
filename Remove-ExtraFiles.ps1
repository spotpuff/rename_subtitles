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
    [Parameter(Mandatory = $true, Position = 0)]
    $Path
)

Begin
{
}

Process
{
    # Remove any .exe, .nfo, or .txt files from the folders.
    # This SHOULD work but is deleting all the files in the directory.
    $fileTypes = @('.exe', '.nfo', '.txt')
    $filesToRemove = Get-ChildItem -LiteralPath $Path | Where-Object { $_.Extension -in $fileTypes }

    if ($filesToRemove.count -gt 0)
    {
        $filestoremove | Remove-Item
        $logText = "Extra files removed from: $Path"
        Write-Output $logText
    }
    else
    {
        $logText = "No extra files found in: $Path."
        Write-Warning $logtext
    }

    # Remove any "samples" subdir
    $sampleDirectoryName = 'sample*'
    $sampleDirectories = Get-ChildItem -LiteralPath $Path -Directory -Filter $sampleDirectoryName
    if ($sampleDirectories.count -gt 0)
    {
        $sampleDirectories | Remove-Item -Force
        $logText = "Sample directories removed from: $Path"
        Write-Output $logText
    }
    else
    {
        $logText = "No sample directories found in: $Path"
        Write-Output $logText
    }
}

End
{

}
