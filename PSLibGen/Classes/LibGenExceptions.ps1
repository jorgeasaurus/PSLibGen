class LibGenException : System.Exception {
    LibGenException([string]$Message) : base($Message) {}
    LibGenException([string]$Message, [System.Exception]$InnerException) : base($Message, $InnerException) {}
}

class LibGenNetworkException : LibGenException {
    [int]$StatusCode
    [string]$Url

    LibGenNetworkException([string]$Message) : base($Message) {}
    
    LibGenNetworkException([string]$Message, [int]$StatusCode, [string]$Url) : base($Message) {
        $this.StatusCode = $StatusCode
        $this.Url = $Url
    }
}

class LibGenSearchException : LibGenException {
    [string]$Query

    LibGenSearchException([string]$Message) : base($Message) {}
    
    LibGenSearchException([string]$Message, [string]$Query) : base($Message) {
        $this.Query = $Query
    }
}

class LibGenParseException : LibGenException {
    LibGenParseException([string]$Message) : base($Message) {}
    LibGenParseException([string]$Message, [System.Exception]$InnerException) : base($Message, $InnerException) {}
}
