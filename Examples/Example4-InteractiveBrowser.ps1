# Example 4: Interactive Book Browser
# This example shows an interactive workflow for searching and selecting books

Import-Module .\PSLibGen\PSLibGen.psd1

function Show-BookMenu {
    param([array]$Books)
    
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           LibGen Search Results                           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt [Math]::Min($Books.Count, 10); $i++) {
        $book = $Books[$i]
        Write-Host "`n[$i] " -NoNewline -ForegroundColor Yellow
        Write-Host $book.Title -ForegroundColor White
        Write-Host "    Authors: " -NoNewline -ForegroundColor Gray
        Write-Host ($book.Authors -join ', ') -ForegroundColor Cyan
        Write-Host "    Year: $($book.Year) | Size: $($book.Size) | Format: $($book.Extension)" -ForegroundColor Gray
        
        if ($book.DownloadLinks.GetLink) {
            Write-Host "    ✓ Download available" -ForegroundColor Green
        } else {
            Write-Host "    ✗ No download link" -ForegroundColor Red
        }
    }
}

# Main interactive loop
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        PSLibGen - Interactive Book Browser                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$continue = $true
while ($continue) {
    # Get search query
    Write-Host "`nEnter search query (or 'quit' to exit): " -NoNewline -ForegroundColor Yellow
    $query = Read-Host
    
    if ($query -eq 'quit' -or $query -eq 'exit' -or [string]::IsNullOrWhiteSpace($query)) {
        $continue = $false
        Write-Host "`nThank you for using PSLibGen!" -ForegroundColor Cyan
        break
    }
    
    # Search with progress
    Write-Host "`nSearching LibGen for: '$query'..." -ForegroundColor Cyan
    try {
        $books = Search-LibGen -Query $query -Verbose
        
        if ($books.Count -eq 0) {
            Write-Host "No results found. Try a different search." -ForegroundColor Yellow
            continue
        }
        
        Write-Host "`nFound $($books.Count) books!" -ForegroundColor Green
        
        # Show results
        Show-BookMenu -Books $books
        
        # Get user selection
        Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
        Write-Host "Options:" -ForegroundColor Yellow
        Write-Host "  Enter a number (0-9) to select a book" -ForegroundColor Gray
        Write-Host "  Press 'n' for new search" -ForegroundColor Gray
        Write-Host "  Press 'q' to quit" -ForegroundColor Gray
        Write-Host "`nYour choice: " -NoNewline -ForegroundColor Yellow
        $choice = Read-Host
        
        if ($choice -eq 'n' -or $choice -eq 'N') {
            continue
        }
        
        if ($choice -eq 'q' -or $choice -eq 'Q') {
            $continue = $false
            Write-Host "`nThank you for using PSLibGen!" -ForegroundColor Cyan
            break
        }
        
        # Try to parse as number
        try {
            $index = [int]$choice
            if ($index -lt 0 -or $index -ge [Math]::Min($books.Count, 10)) {
                Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                continue
            }
            
            $selectedBook = $books[$index]
            
            # Show book details
            Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║                 Selected Book Details                      ║" -ForegroundColor Green
            Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host "`nTitle:     $($selectedBook.Title)" -ForegroundColor White
            Write-Host "Authors:   $($selectedBook.Authors -join ', ')" -ForegroundColor Cyan
            Write-Host "Publisher: $($selectedBook.Publisher)" -ForegroundColor Gray
            Write-Host "Year:      $($selectedBook.Year)" -ForegroundColor Gray
            Write-Host "Pages:     $($selectedBook.Pages)" -ForegroundColor Gray
            Write-Host "Language:  $($selectedBook.Language)" -ForegroundColor Gray
            Write-Host "Size:      $($selectedBook.Size)" -ForegroundColor Gray
            Write-Host "Format:    $($selectedBook.Extension)" -ForegroundColor Gray
            
            if ($selectedBook.DownloadLinks.GetLink) {
                Write-Host "`nDownload URL: $($selectedBook.DownloadLinks.GetLink)" -ForegroundColor Yellow
                
                # Ask to download
                Write-Host "`nDownload this book? (y/n): " -NoNewline -ForegroundColor Yellow
                $download = Read-Host
                
                if ($download -eq 'y' -or $download -eq 'Y') {
                    # Create filename
                    $safeTitle = $selectedBook.Title -replace '[\\/:*?"<>|]', '_'
                    $safeTitle = $safeTitle.Substring(0, [Math]::Min($safeTitle.Length, 50))
                    $filename = "${safeTitle}.$($selectedBook.Extension)"
                    
                    Write-Host "Filename: " -NoNewline -ForegroundColor Gray
                    Write-Host $filename -ForegroundColor Cyan
                    Write-Host "Use this filename? (y/n or enter custom name): " -NoNewline -ForegroundColor Yellow
                    $filenameChoice = Read-Host
                    
                    if (-not [string]::IsNullOrWhiteSpace($filenameChoice) -and $filenameChoice -ne 'y' -and $filenameChoice -ne 'Y') {
                        $filename = $filenameChoice
                    }
                    
                    # Download
                    Write-Host "`nStarting download..." -ForegroundColor Cyan
                    Save-LibGenBook -Url $selectedBook.DownloadLinks.GetLink -OutputPath $filename -Force
                    Write-Host "`nDownload complete!" -ForegroundColor Green
                }
            }
            else {
                Write-Host "`n✗ No download link available for this book." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "Invalid input. Please try again." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "`nError: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please try again with a different search." -ForegroundColor Yellow
    }
}

Write-Host ""
