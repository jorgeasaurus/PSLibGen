# Contributing to PSLibGen

Thank you for considering contributing to PSLibGen! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue on GitHub with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Your PowerShell version (`$PSVersionTable`)
- Any error messages or screenshots

### Suggesting Enhancements

Enhancement suggestions are welcome! Please create an issue with:
- A clear, descriptive title
- Detailed description of the proposed feature
- Use cases and examples
- Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Add or update tests as needed
5. Run the test suite (`Invoke-Pester`)
6. Update documentation if needed
7. Commit your changes with clear commit messages
8. Push to your fork
9. Create a Pull Request

## Development Setup

1. Clone the repository:
```powershell
git clone https://github.com/jorgeasaurus/PSLibGen.git
cd PSLibGen
```

2. Import the module:
```powershell
Import-Module ./PSLibGen/PSLibGen.psd1 -Force
```

3. Run tests:
```powershell
Invoke-Pester ./PSLibGen/Tests/PSLibGen.Tests.ps1
```

## Code Style

- Follow PowerShell best practices and style guidelines
- Use approved PowerShell verbs for function names
- Add comment-based help for all public functions
- Use `[CmdletBinding()]` for advanced functions
- Validate parameters appropriately
- Handle errors gracefully with try/catch blocks

## Testing

- All new features should include Pester tests
- Existing tests must pass before submitting a PR
- Aim for good test coverage of new code
- Use descriptive test names

### Running Tests

```powershell
# Run all tests
Invoke-Pester ./PSLibGen/Tests/PSLibGen.Tests.ps1

# Run unit tests only (skip integration tests)
Invoke-Pester ./PSLibGen/Tests/PSLibGen.Tests.ps1 -ExcludeTag Integration

# Run with detailed output
Invoke-Pester ./PSLibGen/Tests/PSLibGen.Tests.ps1 -Output Detailed
```

## Documentation

- Update README.md for user-facing changes
- Add/update examples for new features
- Update CHANGELOG.md following Keep a Changelog format
- Include comment-based help in functions

## Module Structure

```
PSLibGen/
├── PSLibGen/
│   ├── Classes/           # PowerShell classes
│   ├── Private/           # Internal helper functions
│   ├── Public/            # Exported cmdlets
│   ├── Tests/             # Pester tests
│   ├── PSLibGen.psd1      # Module manifest
│   └── PSLibGen.psm1      # Module file
├── Examples/              # Example scripts
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Commit Messages

- Use clear, descriptive commit messages
- Start with a verb in imperative mood (Add, Fix, Update, etc.)
- Keep the first line under 72 characters
- Add detailed description if needed

Example:
```
Add support for custom timeout values

- Add Timeout parameter to Search-LibGen
- Update tests for new parameter
- Update documentation
```

## Questions?

If you have questions about contributing, feel free to create an issue with the "question" label.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
