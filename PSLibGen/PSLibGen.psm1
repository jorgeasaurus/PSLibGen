# PSLibGen Module
# A PowerShell module for searching and downloading books from Library Genesis

# Load assembly for HTML decoding
Add-Type -AssemblyName System.Web

# Load classes first using full dot sourcing (order matters)
$classFiles = @(
    (Join-Path $PSScriptRoot 'Classes\LibGenExceptions.ps1'),
    (Join-Path $PSScriptRoot 'Classes\BookData.ps1')
)

foreach ($file in $classFiles) {
    . $file
}

# Load private functions
Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter *.ps1 -Recurse | ForEach-Object {
    . $_.FullName
}

# Load public functions
Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter *.ps1 -Recurse | ForEach-Object {
    . $_.FullName
}

# Export public functions and classes
Export-ModuleMember -Function @(
    'Search-LibGen',
    'Save-LibGenBook'
)
