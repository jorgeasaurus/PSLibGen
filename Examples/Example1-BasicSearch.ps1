# Example 1: Basic Search
# This example shows how to perform a basic search

Import-Module .\PSLibGen\PSLibGen.psd1 -Force

# Search for books about PowerShell
Write-Host "`n=== Searching for PowerShell books ===" -ForegroundColor Cyan
$books = Search-LibGen -Query "Learn PowerShell Scripting in a Month of Lunches"

# Display results in a table
$books | Select-Object -First 10 | Format-Table -Property Title, @{
    Label = 'Authors'; Expression = { $_.Authors -join ', ' }
}, Year, Size, Extension -AutoSize

# Count total results
Write-Host "`nFound $($books.Count) books" -ForegroundColor Green
