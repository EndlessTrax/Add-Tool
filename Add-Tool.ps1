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


if (-not $File.Extension -eq ".zip")
{
    Write-Error "$Zipfile is not a zip file" -ErrorAction Stop
}

# check if the unzip folder already exists in output folder
$UnzippedFolderName = $File.Name.Split('.')[0]

if (Test-Path -Path "$OutputFolder\$UnzippedFolderName")
{
    Write-Error "$UnzippedFolderName already exists in $OutputFolder" -ErrorAction Stop
}

$UserPATH = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path

if ($UserPATH.Contains($OutputFolder))
{
    Write-Output "PATH already contains $OutputFolder" -ErrorAction Stop
}

try {
    $File | Expand-Archive -DestinationPath $OutputFolder
    $NewPATH = $UserPATH + ";" + $OutputFolder
    Set-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH -Value $NewPATH
}
catch {
    Write-Error "Failed to set PATH" -ErrorAction Stop
}

$CheckPATH = (Get-ItemProperty -Path 'Registry::HKEY_CURRENT_USER\Environment' -Name PATH).path

if (-not $CheckPATH.Contains($OutputFolder))
{
    Write-Error "Failed to set PATH" -ErrorAction Stop
}

Write-Host "Successfully added $OutputFolder to PATH"
