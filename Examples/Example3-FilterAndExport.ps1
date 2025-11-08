# Example 3: Filter and Export
# This example shows how to filter results and export to CSV

Import-Module .\PSLibGen\PSLibGen.psd1

# Search for data science books
Write-Host "`n=== Searching for Data Science books ===" -ForegroundColor Cyan
$books = Search-LibGen -Query "data science"

# Filter for PDF files only
$pdfBooks = $books | Where-Object { $_.Extension -eq 'pdf' }

Write-Host "Found $($books.Count) total books, $($pdfBooks.Count) PDFs" -ForegroundColor Green

# Create a report
$report = $pdfBooks | Select-Object -First 20 | Select-Object @{
    Name = 'Title'; Expression = { $_.Title }
}, @{
    Name = 'Author'; Expression = { $_.Authors -join ', ' }
}, Year, Publisher, Size, Extension, @{
    Name = 'HasDownloadLink'; Expression = { [bool]$_.DownloadLinks.GetLink }
}

# Display in grid view (interactive)
Write-Host "`nDisplaying in grid view (close window to continue)..." -ForegroundColor Yellow
$report | Out-GridView -Title "Data Science Books (PDF)"

# Export to CSV
$csvPath = "DataScienceBooks.csv"
$report | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "`nExported to: $csvPath" -ForegroundColor Green
