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

# Check the file extension to see if it's a zip file
if (-not $File.Extension -eq ".zip") {
    Write-Error "$Zipfile is not a zip file" -ErrorAction Stop
}

# Check to see if the folder already exists
if (Test-Path -Path $FolderToAddToPATH) {
    Write-Error "$UnzippedFolderName already exists in $OutputFolder" -ErrorAction Stop
}

# Check to see if the folder is already in the users PATH
$UserPATH = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path
if ($UserPATH.Contains($FolderToAddToPATH)) {
    Write-Error "PATH already contains $FolderToAddToPATH" -ErrorAction Stop
}

# Unzip the file and add to PATH
try {
    $File | Expand-Archive -DestinationPath $OutputFolder
    $NewPATH = $UserPATH + ";" + $FolderToAddToPATH
    Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH -Value $NewPATH
}
catch {
    Write-Error "Failed to set PATH" -ErrorAction Stop
}

# Checks the new PATH to see if the Tool got added successfully.
if (-not ((Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path).Contains($FolderToAddToPATH)) {
    Write-Error "Failed to set PATH" -ErrorAction Stop
}

Write-Host "Successfully added $FolderToAddToPATH to PATH"
