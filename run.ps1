$outputencoding=[console]::outputencoding=[text.encoding]::utf8

$fileName = "readme.md"
$fullPath = Resolve-Path $fileName
$directory = Split-Path $fullPath
$targetFile = Split-Path $fullPath -Leaf

# Start the typst process and suppress output
Write-Host "Starting typst.exe in watch mode..."
Start-Process -NoNewWindow -FilePath "typst.exe" -ArgumentList "watch main.generated.typ main.generated.pdf" -RedirectStandardOutput "stdout.log" -RedirectStandardError ".\NUL"

while ($true) {
    $template = Get-Content "main.template.typ" -Raw | Out-String
    $content = Get-Content "readme.md" -Raw | pandoc.exe -f gfm -t typst | Out-String
    $content = $content -replace "\r?\n", "`n" # Normalize line endings to Unix style
    $content = $content -replace "\#horizontalrule", ""
    $file = $template + "`n" + $content
    $file | Set-Content "main.generated.typ" -Encoding utf8 -Force

    Start-Sleep -Seconds 2
}