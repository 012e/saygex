function Download-And-ExtractZip {
    param (
        [string]$Url,
        [string]$ExtractTo
    )

    $zipPath = "$env:TEMP\$(New-Guid).zip"
    Invoke-WebRequest -Uri $Url -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $ExtractTo -Force
    Remove-Item $zipPath -Force
}

function Add-ToUserPath {
    param (
        [string]$Directory
    )

    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$Directory*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$Directory", "User")
        Write-Host "Added $Directory to PATH. Restart your shell to use it."
    } else {
        Write-Host "$Directory is already in PATH."
    }
}

function Install-BinaryFromZip {
    param (
        [string]$ZipUrl,
        [string]$BinaryName,
        [string]$InstallDir
    )

    $tempExtract = "$env:TEMP\extract_$(New-Guid)"
    Download-And-ExtractZip -Url $ZipUrl -ExtractTo $tempExtract

    if (!(Test-Path $InstallDir)) {
        New-Item -Path $InstallDir -ItemType Directory | Out-Null
    }

    $binaryPath = Get-ChildItem -Path $tempExtract -Recurse -Filter $BinaryName | Select-Object -First 1
    if ($null -eq $binaryPath) {
        Write-Error "Could not find $BinaryName in extracted files."
        return
    }

    Copy-Item -Path $binaryPath.FullName -Destination (Join-Path $InstallDir $BinaryName) -Force
    Remove-Item -Path $tempExtract -Recurse -Force

    Add-ToUserPath -Directory $InstallDir

    Write-Host "$BinaryName installed successfully to $InstallDir"
}

$zipUrl = "https://github.com/jgm/pandoc/releases/download/3.6.4/pandoc-3.6.4-windows-x86_64.zip"
$binaryName = "pandoc.exe"
$installDir = "C:\Tools\Pandoc"

Write-Host "Installing $binaryName from $zipUrl to $installDir..."
Install-BinaryFromZip -ZipUrl $zipUrl -BinaryName $binaryName -InstallDir $installDir

$zipUrl = "https://github.com/typst/typst/releases/download/v0.13.1/typst-x86_64-pc-windows-msvc.zip"
$binaryName = "typst.exe"
$installDir = "C:\Tools\Typst"

Write-Host "Installing $binaryName from $zipUrl to $installDir..."
Install-BinaryFromZip -ZipUrl $zipUrl -BinaryName $binaryName -InstallDir $installDir
