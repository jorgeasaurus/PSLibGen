# Example 2: Search and Download
# This example shows how to search and download a book

Import-Module .\PSLibGen\PSLibGen.psd1

# Search for a specific book
Write-Host "`n=== Searching for 'The Art of War' ===" -ForegroundColor Cyan
$books = Search-LibGen -Query "the art of war"

# Show first 5 results
Write-Host "`nTop 5 results:" -ForegroundColor Yellow
$books | Select-Object -First 5 | Format-Table -Property @{
    Label = '#'; Expression = { [array]::IndexOf($books, $_) }
}, Title, @{
    Label = 'Authors'; Expression = { $_.Authors -join ', ' }
}, Year, Size, Extension -AutoSize

# Select first book with download link
$selectedBook = $books | Where-Object { $_.DownloadLinks.GetLink } | Select-Object -First 1

if ($selectedBook) {
    Write-Host "`n=== Selected Book ===" -ForegroundColor Cyan
    Write-Host "Title: $($selectedBook.Title)"
    Write-Host "Authors: $($selectedBook.Authors -join ', ')"
    Write-Host "Year: $($selectedBook.Year)"
    Write-Host "Size: $($selectedBook.Size)"
    Write-Host "Extension: $($selectedBook.Extension)"
    
    # Create safe filename
    $safeTitle = $selectedBook.Title -replace '[\\/:*?"<>|]', '_'
    $filename = "$safeTitle.$($selectedBook.Extension)"
    
    Write-Host "`nDownload URL: $($selectedBook.DownloadLinks.GetLink)" -ForegroundColor Gray
    Write-Host "Would download to: $filename" -ForegroundColor Gray
    
    # Uncomment to actually download:
    # Save-LibGenBook -Url $selectedBook.DownloadLinks.GetLink -OutputPath $filename
}
else {
    Write-Host "`nNo books with download links found." -ForegroundColor Red
}
