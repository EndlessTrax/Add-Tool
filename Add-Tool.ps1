[CmdletBinding()]
param (
    [Parameter(Mandatory, Position = 0)]
    [string]
    $ZipFile,

    [Parameter(Mandatory, Position = 1)]
    [string]
    $OutputFolder
)

$File = Get-Item -Path $ZipFile
$UnzippedFolderName = $File.Name.Split('.')[0]
$FolderToAddToPATH = "$OutputFolder\$UnzippedFolderName"

if (-not $File.Extension -eq ".zip")
{
    Write-Error "$Zipfile is not a zip file" -ErrorAction Stop
}

if (Test-Path -Path $FolderToAddToPATH)
{
    Write-Error "$UnzippedFolderName already exists in $OutputFolder" -ErrorAction Stop
}

$UserPATH = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path
if ($UserPATH.Contains($FolderToAddToPATH))
{
    Write-error "PATH already contains $FolderToAddToPATH" -ErrorAction Stop
}

try {
    $File | Expand-Archive -DestinationPath $OutputFolder
    $NewPATH = $UserPATH + ";" + $FolderToAddToPATH
    Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH -Value $NewPATH
}
catch {
    Write-Error "Failed to set PATH" -ErrorAction Stop
}

# Checks the new PATH to see if the Tool got added successfully.
if (-not ((Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path).Contains($FolderToAddToPATH))
{
    Write-Error "Failed to set PATH" -ErrorAction Stop
}

Write-Host "Successfully added $FolderToAddToPATH to PATH"
