# PSLibGen

A PowerShell module for searching and downloading books from Library Genesis. This is a PowerShell implementation inspired by [libgen-api-modern](https://github.com/johnnie-610/libgen-api-modern).

## Features

- 🔍 **Search LibGen**: Search for books with simple cmdlets
- ⚡ **Fast & Reliable**: Automatically tries multiple LibGen mirrors for reliability
- 📥 **Easy Downloads**: Download books directly with built-in functions
- 🎯 **PowerShell-Native**: Uses PowerShell idioms and pipeline support
- 🔗 **Link Resolution**: Automatically resolves mirror pages to direct download links
- 📦 **Clean API**: Simple, easy-to-use cmdlets that follow PowerShell conventions

## Installation

### From Source

1. Clone the repository:
```powershell
git clone https://github.com/jorgeasaurus/PSLibGen.git
cd PSLibGen
```

2. Import the module:
```powershell
Import-Module .\PSLibGen\PSLibGen.psd1
```

### Manual Installation

Copy the `PSLibGen` folder to one of your PowerShell module paths:
```powershell
$modulePath = $env:PSModulePath -split ';' | Select-Object -First 1
Copy-Item -Path .\PSLibGen -Destination $modulePath -Recurse
Import-Module PSLibGen
```

## Usage

### Search for Books

```powershell
# Basic search
Search-LibGen -Query "python programming"

# Search and get first 5 results
Search-LibGen -Query "the art of war" | Select-Object -First 5

# Search with verbose output
Search-LibGen -Query "data science" -Verbose

# Skip link resolution for faster searches
Search-LibGen -Query "machine learning" -NoResolveLinks
```

### Download Books

```powershell
# Search and download first result
$book = Search-LibGen -Query "python" | Select-Object -First 1
if ($book.DownloadLinks.GetLink) {
    Save-LibGenBook -Url $book.DownloadLinks.GetLink -OutputPath "python_book.$($book.Extension)"
}

# Download with force overwrite
Save-LibGenBook -Url $downloadUrl -OutputPath "book.pdf" -Force
```

### Working with Results

```powershell
# Display book information
$books = Search-LibGen -Query "artificial intelligence"
$books | Format-Table Title, Authors, Year, Size, Extension -AutoSize

# Filter by extension
$books | Where-Object { $_.Extension -eq 'pdf' } | Select-Object Title, Size

# Find books by specific author
$books | Where-Object { $_.Authors -contains "Russell" }

# Export to CSV
$books | Select-Object Title, Authors, Year, Publisher, Size, Extension | 
    Export-Csv -Path "search_results.csv" -NoTypeInformation
```

## Cmdlets

### Search-LibGen

Searches Library Genesis for books.

**Parameters:**
- `Query` (string, mandatory): The search query
- `Results` (int, optional): Maximum number of results (default: 100)
- `NoResolveLinks` (switch): Skip resolving mirror links to direct download URLs

**Returns:** Array of `BookData` objects

### Save-LibGenBook

Downloads a book from LibGen.

**Parameters:**
- `Url` (string, mandatory): The direct download URL
- `OutputPath` (string, mandatory): The path where the file should be saved
- `Force` (switch): Overwrite existing file without prompting

**Returns:** FileInfo object for the downloaded file

## Data Models

### BookData

Represents a book in the LibGen database.

**Properties:**
- `Id` (string): Book ID
- `Authors` (string[]): Array of author names
- `Title` (string): Book title
- `Publisher` (string): Publisher name
- `Year` (string): Publication year
- `Pages` (string): Number of pages
- `Language` (string): Book language
- `Size` (string): File size
- `Extension` (string): File extension (pdf, epub, etc.)
- `Isbn` (string): ISBN number
- `CoverUrl` (string): URL to book cover image
- `DownloadLinks` (DownloadLinks): Download links object

### DownloadLinks

Contains various download links for a book.

**Properties:**
- `GetLink` (string): Direct download link
- `CloudflareLink` (string): Cloudflare mirror link
- `IpfsLink` (string): IPFS link
- `PinataLink` (string): Pinata link
- `CoverLink` (string): Cover image link

## Examples

### Example 1: Search and Interactive Selection

```powershell
$books = Search-LibGen -Query "machine learning"
$books | Format-Table -Property @{
    Label = "#"; Expression = { $books.IndexOf($_) }
}, Title, Authors, Year, Size, Extension -AutoSize

$choice = Read-Host "Enter the number of the book to download"
$selectedBook = $books[$choice]

if ($selectedBook.DownloadLinks.GetLink) {
    $filename = "$($selectedBook.Title -replace '[\\/:*?"<>|]', '_').$($selectedBook.Extension)"
    Save-LibGenBook -Url $selectedBook.DownloadLinks.GetLink -OutputPath $filename
}
```

### Example 2: Batch Download

```powershell
$books = Search-LibGen -Query "python programming" | 
    Where-Object { $_.Extension -eq 'pdf' } | 
    Select-Object -First 3

foreach ($book in $books) {
    if ($book.DownloadLinks.GetLink) {
        $filename = "python_$($books.IndexOf($book)).$($book.Extension)"
        Save-LibGenBook -Url $book.DownloadLinks.GetLink -OutputPath $filename -Force
        Start-Sleep -Seconds 2  # Be nice to the servers
    }
}
```

### Example 3: Export Search Results

```powershell
$books = Search-LibGen -Query "artificial intelligence"

# Create a custom report
$report = $books | Select-Object @{
    Name = 'Title'; Expression = { $_.Title }
}, @{
    Name = 'Author'; Expression = { $_.Authors -join ', ' }
}, Year, Publisher, Size, Extension, @{
    Name = 'DownloadAvailable'; Expression = { [bool]$_.DownloadLinks.GetLink }
}

$report | Export-Csv -Path "ai_books.csv" -NoTypeInformation
$report | Out-GridView -Title "AI Books"
```

## Error Handling

The module includes custom exception types:

- `LibGenException`: Base exception class
- `LibGenNetworkException`: Network-related errors
- `LibGenSearchException`: Search operation failures
- `LibGenParseException`: HTML parsing errors

```powershell
try {
    $books = Search-LibGen -Query "test query"
}
catch [LibGenSearchException] {
    Write-Host "Search failed: $($_.Exception.Message)" -ForegroundColor Red
}
catch [LibGenNetworkException] {
    Write-Host "Network error: $($_.Exception.Message)" -ForegroundColor Red
}
```

## Requirements

- PowerShell 5.1 or higher
- Internet connection
- Access to LibGen mirrors

## Mirror Sites

The module automatically tries multiple LibGen mirror sites for reliability:
- libgen.gl
- libgen.gs
- libgen.vg
- libgen.la
- libgen.bz

## Legal Notice

This module is provided for educational and research purposes only. Users are responsible for ensuring their use complies with applicable laws and LibGen's terms of service. The authors do not condone or encourage copyright infringement.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Inspired by [libgen-api-modern](https://github.com/johnnie-610/libgen-api-modern) by Johnnie.

## Related Projects

- [libgen-api-modern](https://github.com/johnnie-610/libgen-api-modern) - Python implementation