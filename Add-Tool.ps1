[CmdletBinding()]
param (
    [Parameter(Mandatory, Position = 0)]
    [Path]
    $ZipFilePath,

    [Parameter(Mandatory, Position = 1)]
    [Path]
    $OutputFolderPath,

    [Parameter()]
    [string]
    $FolderName
)

Get-Item $ZipFilePath | Expand-Archive -DestinationPath $OutputFolderPath

# Add to User PATH
$UserPATH = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path

$UpdatedPATH = "$UserPATH;$OutputFolderPath"

Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH -Value $UpdatedPATH

# TODO
# Add support to rename folder of the unzipped folder
# Check the file is a valid zip file
# Check that the folder isn't already in the path
# Check path to ensure it has been added correctly
