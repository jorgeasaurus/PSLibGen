function Parse-LibGenSearchResults {
    <#
    .SYNOPSIS
    Parses LibGen HTML search results into structured book data.
    
    .DESCRIPTION
    Extracts book information from the LibGen search results table.
    
    .PARAMETER Html
    The HTML content to parse.
    
    .OUTPUTS
    Array of hashtables containing book information.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Html
    )

    try {
        $results = @()

        # Find the table with id="tablelibgen"
        if ($Html -match '(?s)<table[^>]*id="tablelibgen"[^>]*>(.*?)</table>') {
            $tableContent = $matches[1]
            
            # Extract all rows
            $rowMatches = [regex]::Matches($tableContent, '(?s)<tr[^>]*>(.*?)</tr>')
            
            foreach ($rowMatch in $rowMatches) {
                $rowHtml = $rowMatch.Groups[1].Value
                
                # Extract all cells
                $cellMatches = [regex]::Matches($rowHtml, '(?s)<td[^>]*>(.*?)</td>')
                
                if ($cellMatches.Count -lt 10) {
                    continue
                }
                
                $cells = @()
                foreach ($cellMatch in $cellMatches) {
                    $cells += $cellMatch.Groups[1].Value
                }
                
                # Extract cover image from first cell
                $coverUrl = ''
                if ($cells[0] -match '<img[^>]*src="([^"]+)"') {
                    $coverUrl = $matches[1]
                }
                
                # Extract mirror link from last cell (10th column)
                $mirrorLink = ''
                if ($cells[9] -match '<a[^>]*href="([^"]+)"') {
                    $mirrorLink = $matches[1]
                }
                
                # Helper function to extract title from the title cell
                function Extract-Title {
                    param([string]$CellHtml)

                    # The title cell starts with <b>title text followed by <a> tags and other metadata
                    # The <b> tag may not have a proper closing tag, so we match until the next <
                    if ($CellHtml -match '<b>([^<]+)') {
                        $title = $matches[1]
                        $title = [System.Web.HttpUtility]::HtmlDecode($title)
                        $title = $title.Trim()
                        return $title
                    }

                    # Fallback: try <a> tag
                    if ($CellHtml -match '<a[^>]*>([^<]+)</a>') {
                        $title = $matches[1]
                        $title = [System.Web.HttpUtility]::HtmlDecode($title)
                        $title = $title.Trim()
                        return $title
                    }

                    # Last resort: use Clean-Text
                    return Clean-Text $CellHtml
                }

                # Helper function to strip HTML tags and clean text
                function Clean-Text {
                    param([string]$Text)
                    # Remove all HTML tags (handles nested tags)
                    while ($Text -match '<[^>]+>') {
                        $Text = $Text -replace '<[^>]+>', ' '
                    }
                    # Decode HTML entities
                    $Text = [System.Web.HttpUtility]::HtmlDecode($Text)
                    # Clean up multiple spaces and trim
                    $Text = $Text -replace '\s+', ' '
                    $Text = $Text.Trim()
                    # Remove common artifacts
                    $Text = $Text -replace '^\s*\d+\s*$', ''  # Remove lone numbers
                    return $Text
                }
                
                $result = @{
                    Cover     = $coverUrl
                    Title     = Extract-Title $cells[1]
                    Authors   = Clean-Text $cells[2]
                    Publisher = Clean-Text $cells[3]
                    Year      = Clean-Text $cells[4]
                    Language  = Clean-Text $cells[5]
                    Pages     = Clean-Text $cells[6]
                    Size      = Clean-Text $cells[7]
                    Extension = Clean-Text $cells[8]
                    Mirror    = $mirrorLink
                }
                
                # Only add if we have meaningful data
                if ($result.Title -or $result.Authors) {
                    $results += $result
                }
            }
        }
        
        return $results
    }
    catch {
        throw [LibGenParseException]::new("Failed to parse HTML: $($_.Exception.Message)", $_.Exception)
    }
}
