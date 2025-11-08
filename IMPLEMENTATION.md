# PSLibGen Implementation Summary

## Overview
PSLibGen is a PowerShell module that provides a clean, PowerShell-native interface for searching and downloading books from Library Genesis. This is a complete PowerShell implementation inspired by the [libgen-api-modern](https://github.com/johnnie-610/libgen-api-modern) Python library.

## Project Structure

```
PSLibGen/
├── PSLibGen/                      # Main module directory
│   ├── Classes/
│   │   ├── BookData.ps1           # Data model for book information
│   │   └── LibGenExceptions.ps1   # Custom exception types
│   ├── Private/
│   │   ├── Parse-LibGenSearchResults.ps1  # HTML parser
│   │   └── Resolve-LibGenMirrorLink.ps1   # Mirror link resolver
│   ├── Public/
│   │   ├── Search-LibGen.ps1      # Main search cmdlet
│   │   └── Save-LibGenBook.ps1    # Download cmdlet
│   ├── Tests/
│   │   └── PSLibGen.Tests.ps1     # Pester test suite
│   ├── PSLibGen.psd1              # Module manifest
│   └── PSLibGen.psm1              # Module entry point
├── Examples/                       # Example scripts
│   ├── Example1-BasicSearch.ps1
│   ├── Example2-SearchAndDownload.ps1
│   ├── Example3-FilterAndExport.ps1
│   └── Example4-InteractiveBrowser.ps1
├── CHANGELOG.md                    # Version history
├── CONTRIBUTING.md                 # Contribution guidelines
├── LICENSE                         # MIT License
├── README.md                       # Main documentation
└── Validate-Module.ps1            # Validation script
```

## Core Components

### 1. Data Models (Classes/BookData.ps1)

**DownloadLinks Class**
- Properties for multiple download mirror types (Get, Cloudflare, IPFS, Pinata)
- Cover image link storage

**BookData Class**
- Complete book metadata (title, authors, publisher, etc.)
- Embedded DownloadLinks object
- Immutable data structure for consistency

### 2. Exception Handling (Classes/LibGenExceptions.ps1)

Custom exception hierarchy:
- `LibGenException`: Base exception
- `LibGenNetworkException`: Network/HTTP errors
- `LibGenSearchException`: Search operation failures
- `LibGenParseException`: HTML parsing errors

### 3. HTML Parser (Private/Parse-LibGenSearchResults.ps1)

Features:
- Parses LibGen's search results table
- Extracts book metadata (title, authors, year, size, etc.)
- Extracts cover image URLs and mirror links
- Handles HTML decoding and text cleanup
- Robust error handling

### 4. Mirror Link Resolution (Private/Resolve-LibGenMirrorLink.ps1)

Features:
- Resolves indirect mirror links to direct download URLs
- Fetches mirror pages and extracts `get.php?md5=` links
- Graceful fallback on resolution failures
- Timeout and error handling

### 5. Search Cmdlet (Public/Search-LibGen.ps1)

**Features:**
- Searches multiple LibGen mirror sites automatically
- Automatic fallback if one site fails
- Pipeline support for PowerShell workflows
- Optional link resolution (can be disabled for speed)
- Verbose logging support

**Parameters:**
- `Query` (mandatory): Search query string
- `Results`: Maximum results to return (default: 100)
- `NoResolveLinks`: Skip mirror link resolution

**Mirror Sites:**
- libgen.gl
- libgen.gs
- libgen.vg
- libgen.la
- libgen.bz

### 6. Download Cmdlet (Public/Save-LibGenBook.ps1)

**Features:**
- Downloads books from LibGen URLs
- Progress indication (PowerShell native)
- File overwrite protection
- Force parameter for automated downloads
- Returns FileInfo object

**Parameters:**
- `Url` (mandatory): Download URL
- `OutputPath` (mandatory): Save location
- `Force`: Overwrite without prompting

## Testing

### Test Coverage (PSLibGen.Tests.ps1)

15 unit tests covering:
- ✅ Module loading
- ✅ Command exports
- ✅ Class instantiation
- ✅ Exception types
- ✅ Parameter validation
- ✅ Pipeline support

All tests pass successfully (15/15).

### Validation Script (Validate-Module.ps1)

Comprehensive validation including:
- Module loading verification
- Command availability checks
- Class functionality tests
- Parameter validation
- Full Pester test suite execution

## Documentation

### README.md
Complete documentation including:
- Installation instructions
- Usage examples
- Cmdlet reference
- Data model documentation
- Error handling guide
- Legal notice

### Examples
Four example scripts demonstrating:
1. Basic search functionality
2. Search and download workflow
3. Filtering and exporting results
4. Interactive book browser (full CLI experience)

### CHANGELOG.md
Version history following Keep a Changelog format.

### CONTRIBUTING.md
Contribution guidelines including:
- Bug reporting
- Feature suggestions
- Pull request process
- Code style guidelines
- Development setup

## Key Design Decisions

### PowerShell-Native Implementation
- Uses PowerShell idioms and patterns
- Pipeline support for composability
- Standard parameter validation
- Comment-based help
- Follows PowerShell naming conventions

### Error Handling
- Custom exception hierarchy
- Try/catch blocks throughout
- Graceful degradation (mirror fallback)
- Verbose logging support

### Robustness
- Multiple mirror site support
- Automatic retry logic
- Timeout handling
- HTML parsing edge cases handled

### User Experience
- Clear, descriptive cmdlet names
- Progress indication
- Interactive prompts with defaults
- Rich example scripts

## Comparison with Python Implementation

### Similarities
- Same core functionality (search, download)
- Same LibGen mirror sites
- Similar data models
- Comparable error handling
- Mirror link resolution logic

### Differences
- PowerShell-native API (vs Python)
- Synchronous only (no async/await)
- Different testing framework (Pester vs pytest)
- PowerShell classes (vs dataclasses)
- More extensive examples

## Future Enhancements (Potential)

1. **Performance**
   - Parallel mirror site queries
   - Caching search results
   - Background job support

2. **Features**
   - Advanced search filters
   - Batch download support
   - Resume interrupted downloads
   - Progress bars for slow connections

3. **Integration**
   - PowerShell Gallery publishing
   - Module auto-update support
   - Configuration file support

## Testing Checklist

- [x] Module loads successfully
- [x] All cmdlets exported
- [x] Classes instantiate correctly
- [x] Exception types work properly
- [x] Parameters validate correctly
- [x] Pipeline support functional
- [x] All unit tests pass (15/15)
- [x] Validation script passes
- [x] Documentation complete
- [x] Examples functional

## Notes

- LibGen sites may change or become unavailable; mirror list should be maintained
- HTML parsing is brittle and may break if LibGen changes their HTML structure
- Network timeouts are set conservatively (10-15 seconds)
- No authentication required for LibGen access
- Module requires PowerShell 5.1 or higher

## License

MIT License - see LICENSE file for details.

## Credits

Inspired by [libgen-api-modern](https://github.com/johnnie-610/libgen-api-modern) by Johnnie.
