class DownloadLinks {
    [string]$GetLink
    [string]$CloudflareLink
    [string]$IpfsLink
    [string]$PinataLink
    [string]$CoverLink

    DownloadLinks(
        [string]$GetLink,
        [string]$CloudflareLink,
        [string]$IpfsLink,
        [string]$PinataLink,
        [string]$CoverLink
    ) {
        $this.GetLink = $GetLink
        $this.CloudflareLink = $CloudflareLink
        $this.IpfsLink = $IpfsLink
        $this.PinataLink = $PinataLink
        $this.CoverLink = $CoverLink
    }
}

class BookData {
    [string]$Id
    [string[]]$Authors
    [string]$Title
    [string]$Publisher
    [string]$Year
    [string]$Pages
    [string]$Language
    [string]$Size
    [string]$Extension
    [string]$Isbn
    [string]$CoverUrl
    [DownloadLinks]$DownloadLinks

    BookData(
        [string]$Id,
        [string[]]$Authors,
        [string]$Title,
        [string]$Publisher,
        [string]$Year,
        [string]$Pages,
        [string]$Language,
        [string]$Size,
        [string]$Extension,
        [string]$Isbn,
        [string]$CoverUrl,
        [DownloadLinks]$DownloadLinks
    ) {
        $this.Id = $Id
        $this.Authors = $Authors
        $this.Title = $Title
        $this.Publisher = $Publisher
        $this.Year = $Year
        $this.Pages = $Pages
        $this.Language = $Language
        $this.Size = $Size
        $this.Extension = $Extension
        $this.Isbn = $Isbn
        $this.CoverUrl = $CoverUrl
        $this.DownloadLinks = $DownloadLinks
    }
}
