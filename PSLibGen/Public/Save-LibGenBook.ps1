function Save-LibGenBook {
    <#
    .SYNOPSIS
    Downloads a book from LibGen.
    
    .DESCRIPTION
    Downloads a book file from a LibGen URL with progress indication.
    
    .PARAMETER Url
    The direct download URL for the book.
    
    .PARAMETER OutputPath
    The path where the file should be saved.
    
    .PARAMETER Force
    Overwrite existing file without prompting.
    
    .EXAMPLE
    Save-LibGenBook -Url "https://libgen.gl/get.php?md5=..." -OutputPath "book.pdf"
    Downloads a book to book.pdf.
    
    .EXAMPLE
    $book = Search-LibGen "python" | Select-Object -First 1
    Save-LibGenBook -Url $book.DownloadLinks.GetLink -OutputPath "python_book.pdf"
    Searches for and downloads the first Python book.
    #>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Url,
        
        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,
        
        [Parameter()]
        [switch]$Force
    )

    try {
        # Check if file already exists
        if (Test-Path -Path $OutputPath) {
            if (-not $Force) {
                $response = Read-Host "File '$OutputPath' already exists. Overwrite? (y/N)"
                if ($response -ne 'y' -and $response -ne 'Y') {
                    Write-Host "Download cancelled." -ForegroundColor Yellow
                    return
                }
            }
        }
        
        Write-Verbose "Starting download from: $Url"
        Write-Host "Downloading to: $OutputPath" -ForegroundColor Cyan
        
        # Download with progress
        $originalProgressPreference = $ProgressPreference
        try {
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $Url -OutFile $OutputPath -TimeoutSec 300
            
            Write-Host "Download complete: '$OutputPath'" -ForegroundColor Green
            
            # Return file info
            Get-Item -Path $OutputPath
        }
        catch {
            throw [LibGenNetworkException]::new(
                "Download failed: $($_.Exception.Message)"
            )
        }
        finally {
            $ProgressPreference = $originalProgressPreference
        }
    }
    catch {
        Write-Error "Failed to download book: $($_.Exception.Message)"
        throw
    }
}
