#!/usr/bin/env pwsh
# Quick validation script for PSLibGen module

Write-Host "`n=== PSLibGen Module Validation ===" -ForegroundColor Cyan

# Test 1: Module loading
Write-Host "`n[Test 1] Loading module..." -ForegroundColor Yellow
Import-Module ./PSLibGen/PSLibGen.psd1 -Force
Write-Host "✓ Module loaded successfully" -ForegroundColor Green

# Test 2: Check exported commands
Write-Host "`n[Test 2] Checking exported commands..." -ForegroundColor Yellow
$commands = Get-Command -Module PSLibGen
if ($commands.Count -eq 2) {
    Write-Host "✓ Found $($commands.Count) commands:" -ForegroundColor Green
    $commands | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
} else {
    Write-Host "✗ Expected 2 commands, found $($commands.Count)" -ForegroundColor Red
    exit 1
}

# Test 3: Check classes
Write-Host "`n[Test 3] Testing classes..." -ForegroundColor Yellow
try {
    # Load classes for testing
    . ./PSLibGen/Classes/LibGenExceptions.ps1
    . ./PSLibGen/Classes/BookData.ps1
    
    $downloadLinks = [DownloadLinks]::new($null, $null, $null, $null, $null)
    $book = [BookData]::new(
        '123',
        @('Test Author'),
        'Test Book',
        'Test Publisher',
        '2024',
        '100',
        'English',
        '1MB',
        'pdf',
        $null,
        'http://example.com/cover.jpg',
        $downloadLinks
    )
    
    if ($book.Title -eq 'Test Book' -and $book.Authors[0] -eq 'Test Author') {
        Write-Host "✓ Classes working correctly" -ForegroundColor Green
    } else {
        Write-Host "✗ Class properties not set correctly" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "✗ Error testing classes: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Check command parameters
Write-Host "`n[Test 4] Checking Search-LibGen parameters..." -ForegroundColor Yellow
$searchCmd = Get-Command Search-LibGen
$expectedParams = @('Query', 'Results', 'NoResolveLinks')
$hasAllParams = $true
foreach ($param in $expectedParams) {
    if (-not $searchCmd.Parameters.ContainsKey($param)) {
        Write-Host "✗ Missing parameter: $param" -ForegroundColor Red
        $hasAllParams = $false
    }
}
if ($hasAllParams) {
    Write-Host "✓ All required parameters present" -ForegroundColor Green
} else {
    exit 1
}

Write-Host "`n[Test 5] Checking Save-LibGenBook parameters..." -ForegroundColor Yellow
$saveCmd = Get-Command Save-LibGenBook
$expectedParams = @('Url', 'OutputPath', 'Force')
$hasAllParams = $true
foreach ($param in $expectedParams) {
    if (-not $saveCmd.Parameters.ContainsKey($param)) {
        Write-Host "✗ Missing parameter: $param" -ForegroundColor Red
        $hasAllParams = $false
    }
}
if ($hasAllParams) {
    Write-Host "✓ All required parameters present" -ForegroundColor Green
}

# Test 6: Run Pester tests
Write-Host "`n[Test 6] Running Pester tests..." -ForegroundColor Yellow
$pesterResult = Invoke-Pester ./PSLibGen/Tests/PSLibGen.Tests.ps1 -PassThru -ExcludeTag Integration
if ($pesterResult.FailedCount -eq 0) {
    Write-Host "✓ All $($pesterResult.PassedCount) tests passed" -ForegroundColor Green
} else {
    Write-Host "✗ $($pesterResult.FailedCount) tests failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== All Validation Tests Passed! ===" -ForegroundColor Green
Write-Host "`nThe PSLibGen module is ready to use." -ForegroundColor Cyan
Write-Host "Try: Search-LibGen -Query 'your search term'" -ForegroundColor Gray
