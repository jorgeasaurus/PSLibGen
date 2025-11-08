function Search-LibGen {
    <#
    .SYNOPSIS
    Searches Library Genesis for books.
    
    .DESCRIPTION
    Searches LibGen using the provided query and returns structured book data.
    Automatically tries multiple LibGen mirror sites for reliability.
    
    .PARAMETER Query
    The search query string.
    
    .PARAMETER Results
    Maximum number of results to return (default: 100).
    
    .PARAMETER NoResolveLinks
    If specified, skip resolving mirror links to direct download URLs.
    
    .EXAMPLE
    Search-LibGen -Query "python programming"
    Searches for books about Python programming.
    
    .EXAMPLE
    Search-LibGen -Query "the art of war" | Select-Object -First 5
    Gets the first 5 results for "the art of war".
    
    .OUTPUTS
    Array of BookData objects.
    #>
    [CmdletBinding()]
    [OutputType([BookData[]])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        
        [Parameter()]
        [ValidateRange(1, 200)]
        [int]$Results = 100,
        
        [Parameter()]
        [switch]$NoResolveLinks
    )

    begin {
        # LibGen mirror URLs to try
        $libgenUrls = @(
            'https://libgen.gl',
            'https://libgen.gs',
            'https://libgen.vg',
            'https://libgen.la',
            'https://libgen.bz'
        )
    }

    process {
        $searchParams = @{
            req       = $Query
            res       = $Results.ToString()
            covers    = 'on'
            filesuns  = 'all'
        }
        
        $foundResults = $false
        $bookResults = @()
        
        foreach ($baseUrl in $libgenUrls) {
            $searchUrl = "$baseUrl/index.php"
            Write-Verbose "Trying $searchUrl"
            
            try {
                # Build query string
                $queryString = ($searchParams.GetEnumerator() | ForEach-Object { 
                    "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))" 
                }) -join '&'
                
                $fullUrl = "$searchUrl?$queryString"
                
                $response = Invoke-WebRequest -Uri $fullUrl -TimeoutSec 15 -UseBasicParsing -ErrorAction Stop
                
                if ($response.StatusCode -ne 200) {
                    throw [LibGenNetworkException]::new(
                        "HTTP error: $($response.StatusCode)",
                        $response.StatusCode,
                        $fullUrl
                    )
                }
                
                $html = $response.Content
                $rawResults = Parse-LibGenSearchResults -Html $html
                
                if ($rawResults.Count -eq 0) {
                    Write-Verbose "No results found at $baseUrl"
                    return @()
                }
                
                Write-Verbose "Found $($rawResults.Count) results at $baseUrl"
                
                # Process each result
                foreach ($result in $rawResults) {
                    # Fix cover URL if relative
                    if ($result.Cover -and -not $result.Cover.StartsWith('http')) {
                        $result.Cover = $baseUrl + $result.Cover
                    }
                    
                    # Resolve mirror link
                    $downloadLink = $null
                    if ($result.Mirror -and -not $NoResolveLinks) {
                        if ($result.Mirror -match 'get\.php\?md5=') {
                            # Already a direct link
                            if (-not $result.Mirror.StartsWith('http')) {
                                $downloadLink = $baseUrl + $result.Mirror
                            }
                            else {
                                $downloadLink = $result.Mirror
                            }
                        }
                        else {
                            # Need to resolve the mirror page
                            $downloadLink = Resolve-LibGenMirrorLink -MirrorPartial $result.Mirror -BaseUrl $baseUrl
                        }
                    }
                    
                    # Create DownloadLinks object
                    $downloadLinksObj = $null
                    if ($downloadLink) {
                        $downloadLinksObj = [DownloadLinks]::new(
                            $downloadLink,
                            $null,
                            $null,
                            $null,
                            $result.Cover
                        )
                    }
                    
                    # Parse authors
                    $authors = @()
                    if ($result.Authors) {
                        $authors = $result.Authors -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
                    }
                    
                    # Create BookData object
                    $bookData = [BookData]::new(
                        '', # ID not available from search
                        $authors,
                        $result.Title,
                        $result.Publisher,
                        $result.Year,
                        $result.Pages,
                        $result.Language,
                        $result.Size,
                        $result.Extension,
                        $null, # ISBN not available from search
                        $result.Cover,
                        $downloadLinksObj
                    )
                    
                    $bookResults += $bookData
                }
                
                $foundResults = $true
                break
            }
            catch [System.Net.WebException] {
                Write-Warning "Network error accessing $searchUrl : $($_.Exception.Message)"
                continue
            }
            catch [LibGenNetworkException] {
                Write-Warning "LibGen error: $($_.Exception.Message)"
                continue
            }
            catch {
                Write-Warning "Unexpected error accessing $searchUrl : $($_.Exception.Message)"
                continue
            }
        }
        
        if (-not $foundResults) {
            throw [LibGenSearchException]::new(
                "Failed to retrieve results from all LibGen sites",
                $Query
            )
        }
        
        return $bookResults
    }
}
