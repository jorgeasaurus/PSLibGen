# Quick Start Guide - PSLibGen

Get started with PSLibGen in just a few minutes!

## Installation

### Option 1: Clone the Repository
```powershell
git clone https://github.com/jorgeasaurus/PSLibGen.git
cd PSLibGen
Import-Module ./PSLibGen/PSLibGen.psd1
```

### Option 2: Manual Download
1. Download the repository as a ZIP
2. Extract to a location
3. Open PowerShell and navigate to the directory
4. Run: `Import-Module ./PSLibGen/PSLibGen.psd1`

## Your First Search

```powershell
# Search for books about Python
$books = Search-LibGen -Query "python programming"

# Display first 5 results
$books | Select-Object -First 5 | Format-Table Title, Authors, Year, Size, Extension
```

## Download a Book

```powershell
# Search for a book
$books = Search-LibGen -Query "the art of war"

# Get the first book with a download link
$book = $books | Where-Object { $_.DownloadLinks.GetLink } | Select-Object -First 1

# Download it
if ($book) {
    $filename = "the_art_of_war.$($book.Extension)"
    Save-LibGenBook -Url $book.DownloadLinks.GetLink -OutputPath $filename
}
```

## Filter Results

```powershell
# Search for data science books
$books = Search-LibGen -Query "data science"

# Filter for PDF files only
$pdfBooks = $books | Where-Object { $_.Extension -eq 'pdf' }

# Filter by year
$recentBooks = $books | Where-Object { [int]$_.Year -gt 2020 }

# Find books by specific author
$books | Where-Object { $_.Authors -contains "Russell" }
```

## Export Results

```powershell
# Search and export to CSV
$books = Search-LibGen -Query "machine learning"

$books | Select-Object Title, @{
    Name = 'Authors'; Expression = { $_.Authors -join ', ' }
}, Year, Size, Extension | Export-Csv -Path "ml_books.csv" -NoTypeInformation

# View in grid (interactive)
$books | Out-GridView -Title "Machine Learning Books"
```

## Interactive Mode

Try the interactive browser example for a full CLI experience:

```powershell
./Examples/Example4-InteractiveBrowser.ps1
```

## Get Help

```powershell
# Get help for a cmdlet
Get-Help Search-LibGen -Full
Get-Help Save-LibGenBook -Full

# List all commands in the module
Get-Command -Module PSLibGen
```

## Tips

1. **Use -NoResolveLinks for faster searches** if you don't need download links immediately:
   ```powershell
   Search-LibGen -Query "python" -NoResolveLinks
   ```

2. **Use -Verbose for debugging** to see which mirrors are being tried:
   ```powershell
   Search-LibGen -Query "python" -Verbose
   ```

3. **Pipe results through PowerShell** for powerful filtering:
   ```powershell
   Search-LibGen "programming" | 
       Where-Object { $_.Extension -eq 'pdf' -and [int]$_.Year -gt 2015 } |
       Select-Object -First 10
   ```

4. **Use Force parameter** to download without prompts:
   ```powershell
   Save-LibGenBook -Url $url -OutputPath "book.pdf" -Force
   ```

## Example Workflows

### Workflow 1: Research Assistant
```powershell
# Search for academic papers
$papers = Search-LibGen -Query "quantum computing"

# Filter by recent publications
$recent = $papers | Where-Object { [int]$_.Year -ge 2020 }

# Export for reference
$recent | Export-Csv -Path "quantum_papers.csv" -NoTypeInformation
```

### Workflow 2: Building a Library
```powershell
# Search for classic literature
$classics = Search-LibGen -Query "philosophy classics"

# Filter for EPUB format
$epubs = $classics | Where-Object { $_.Extension -eq 'epub' }

# Download first 5 books
foreach ($book in ($epubs | Select-Object -First 5)) {
    if ($book.DownloadLinks.GetLink) {
        $filename = "$($book.Title -replace '[\\/:*?"<>|]', '_').$($book.Extension)"
        Save-LibGenBook -Url $book.DownloadLinks.GetLink -OutputPath $filename -Force
        Start-Sleep -Seconds 2  # Be respectful to servers
    }
}
```

## Troubleshooting

### Module won't load
```powershell
# Make sure you're in the correct directory
Get-Location

# Try with full path
Import-Module "C:\Full\Path\To\PSLibGen\PSLibGen.psd1" -Force
```

### No results found
- LibGen mirrors may be temporarily unavailable
- Try a different search query
- Check your internet connection
- Use -Verbose to see which mirrors are being tried

### Download fails
- The download link may have expired
- Try searching again to get a fresh link
- Check the URL is valid
- Ensure you have write permissions to the output directory

## Next Steps

1. Explore the [examples](Examples/) directory for more advanced usage
2. Read the full [README.md](README.md) for detailed documentation
3. Run the validation script: `./Validate-Module.ps1`
4. Check out [CONTRIBUTING.md](CONTRIBUTING.md) if you want to contribute

## Need Help?

- Check the [README.md](README.md) for full documentation
- Look at the [examples](Examples/) for common use cases
- Create an issue on GitHub for bugs or questions

Happy reading! 📚
