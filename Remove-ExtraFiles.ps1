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
    [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)]
    $Path
)

# Get the subs from the subdir and the movie file name
Begin
{
}

# Remove any .exe, .nfo, or .txt files from the folders
Process
{
    $fileTypes = @('*.exe', '*.nfo', '*.txt')
    $filesToRemove = Get-ChildItem -Path $Path -Recurse -Include $fileTypes
    if ($filesToRemove.count -gt 0)
    {
        $filestoremove | Remove-Item
        $logText = "$Path extra files removed."
        Write-Output $logText
    }
    else
    {
        $logText = "$Path no extra files found."
        Write-Warning $logtext
    }
}

End
{

}
