function Resolve-LibGenMirrorLink {
    <#
    .SYNOPSIS
    Resolves a LibGen mirror link to get the direct download link.
    
    .DESCRIPTION
    Fetches the mirror page and extracts the direct download (get.php) link.
    
    .PARAMETER MirrorPartial
    The partial mirror URL path.
    
    .PARAMETER BaseUrl
    The base LibGen URL.
    
    .OUTPUTS
    The resolved direct download URL.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$MirrorPartial,
        
        [Parameter(Mandatory)]
        [string]$BaseUrl
    )

    # Ensure mirror partial starts with /
    if (-not $MirrorPartial.StartsWith('/')) {
        $MirrorPartial = '/' + $MirrorPartial
    }
    
    $url = $BaseUrl + $MirrorPartial

    Write-Verbose "Resolving mirror link: $url"

    # Headers to mimic a browser request
    $headers = @{
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }

    try {
        $response = Invoke-WebRequest -Uri $url -Headers $headers -TimeoutSec 10 -UseBasicParsing
        $html = $response.Content
        
        # Look for get.php?md5= link
        if ($html -match 'href="(get\.php\?md5=[^"]+)"') {
            $getLink = $matches[1]
            
            if (-not $getLink.StartsWith('/')) {
                $getLink = '/' + $getLink
            }
            
            $resolvedUrl = $BaseUrl + $getLink
            Write-Verbose "Resolved to: $resolvedUrl"
            return $resolvedUrl
        }
        else {
            Write-Warning "Could not find get.php link in mirror page: $url"
            return $url
        }
    }
    catch {
        Write-Warning "Error resolving mirror link $url : $($_.Exception.Message)"
        return $url
    }
}
