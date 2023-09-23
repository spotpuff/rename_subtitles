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

Begin
{
}

Process
{
    # Remove any .exe, .nfo, or .txt files from the folders
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

    # Remove any "samples" subdir
    $sampleDirectoryName = 'sample*'
    $sampleDirectories = Get-ChildItem -Path $Path -Directory -Filter $sampleDirectoryName
    if ($sampleDirectories.count -gt 0)
    {
        $sampleDirectories | Remove-Item -Force
        $logText = "$Path sample directories removed."
        Write-Output $logText
    }
    else
    {
        $logText = "$Path no sample directories found."
        Write-Output $logText
    }
}

End
{

}
