# Changelog

All notable changes to the PSLibGen project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-01-08

### Fixed
- Added User-Agent headers to all HTTP requests to prevent 403 Forbidden errors from LibGen sites
- Fixed URL construction using explicit concatenation to avoid variable scope issues
- Updated mirror site list to prioritize working mirrors (libgen.vg and libgen.bz as primary)
- Improved title extraction to remove HTML artifacts and metadata from book titles
- Improved error handling and automatic fallback to alternative mirrors

### Changed
- Reordered mirror sites by current reliability and availability
- Updated documentation to reflect mirror site changes and technical notes

### Added
- libgen.plus mirror site to improve availability

## [1.0.0] - 2024-11-08

### Added
- Initial release of PSLibGen
- `Search-LibGen` cmdlet for searching Library Genesis
- `Save-LibGenBook` cmdlet for downloading books
- Support for multiple LibGen mirror sites with automatic fallback
- HTML parser for LibGen search results
- Mirror link resolution to direct download URLs
- Custom exception types for better error handling
- PowerShell classes for BookData and DownloadLinks
- Comprehensive Pester test suite
- Example scripts demonstrating module usage
- Full documentation in README.md

### Features
- Search LibGen with simple queries
- Filter results by various criteria (extension, author, etc.)
- Pipeline support for PowerShell-style workflows
- Progress indication for downloads
- Automatic retry with multiple mirror sites
- Clean, PowerShell-native API

[1.0.0]: https://github.com/jorgeasaurus/PSLibGen/releases/tag/v1.0.0
