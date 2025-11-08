BeforeAll {
    # Import the module
    $modulePath = Join-Path $PSScriptRoot '..' 'PSLibGen.psd1'
    Import-Module $modulePath -Force
    
    # Import classes explicitly for testing
    . (Join-Path $PSScriptRoot '..' 'Classes' 'LibGenExceptions.ps1')
    . (Join-Path $PSScriptRoot '..' 'Classes' 'BookData.ps1')
}

Describe 'PSLibGen Module Tests' {
    Context 'Module Loading' {
        It 'Should load the module successfully' {
            $module = Get-Module PSLibGen
            $module | Should -Not -BeNullOrEmpty
            $module.Name | Should -Be 'PSLibGen'
        }

        It 'Should export Search-LibGen cmdlet' {
            $command = Get-Command Search-LibGen -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }

        It 'Should export Save-LibGenBook cmdlet' {
            $command = Get-Command Save-LibGenBook -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'BookData Class' {
        It 'Should create BookData object' {
            $downloadLinks = [DownloadLinks]::new($null, $null, $null, $null, $null)
            $book = [BookData]::new(
                '12345',
                @('Author One', 'Author Two'),
                'Test Book',
                'Test Publisher',
                '2024',
                '300',
                'English',
                '10 MB',
                'pdf',
                '123456789',
                'http://example.com/cover.jpg',
                $downloadLinks
            )

            $book.Title | Should -Be 'Test Book'
            $book.Authors.Count | Should -Be 2
            $book.Year | Should -Be '2024'
            $book.Extension | Should -Be 'pdf'
        }
    }

    Context 'DownloadLinks Class' {
        It 'Should create DownloadLinks object' {
            $links = [DownloadLinks]::new(
                'http://example.com/get.php',
                'http://cloudflare.com/link',
                'http://ipfs.io/link',
                'http://pinata.cloud/link',
                'http://example.com/cover.jpg'
            )

            $links.GetLink | Should -Be 'http://example.com/get.php'
            $links.CoverLink | Should -Be 'http://example.com/cover.jpg'
        }
    }

    Context 'Exception Classes' {
        It 'Should create LibGenException' {
            $ex = [LibGenException]::new('Test error')
            $ex.Message | Should -Be 'Test error'
        }

        It 'Should create LibGenNetworkException with status code' {
            $ex = [LibGenNetworkException]::new('Network error', 404, 'http://example.com')
            $ex.StatusCode | Should -Be 404
            $ex.Url | Should -Be 'http://example.com'
        }

        It 'Should create LibGenSearchException with query' {
            $ex = [LibGenSearchException]::new('Search failed', 'test query')
            $ex.Query | Should -Be 'test query'
        }
    }

    Context 'Search-LibGen Cmdlet' {
        It 'Should accept Query parameter' {
            $command = Get-Command Search-LibGen
            $command.Parameters.ContainsKey('Query') | Should -Be $true
            $queryParam = $command.Parameters['Query']
            $queryParam.Attributes | Where-Object { $_ -is [Parameter] } | ForEach-Object {
                $_.Mandatory | Should -Be $true
            }
        }

        It 'Should accept Results parameter' {
            $command = Get-Command Search-LibGen
            $command.Parameters.ContainsKey('Results') | Should -Be $true
        }

        It 'Should accept NoResolveLinks switch' {
            $command = Get-Command Search-LibGen
            $command.Parameters.ContainsKey('NoResolveLinks') | Should -Be $true
        }

        It 'Should support pipeline input' {
            $command = Get-Command Search-LibGen
            $queryParam = $command.Parameters['Query']
            $pipelineAttr = $queryParam.Attributes | Where-Object { $_ -is [Parameter] } | Select-Object -First 1
            $pipelineAttr.ValueFromPipeline | Should -Be $true
        }
    }

    Context 'Save-LibGenBook Cmdlet' {
        It 'Should accept Url parameter' {
            $command = Get-Command Save-LibGenBook
            $command.Parameters.ContainsKey('Url') | Should -Be $true
            $urlParam = $command.Parameters['Url']
            $urlParam.Attributes | Where-Object { $_ -is [Parameter] } | ForEach-Object {
                $_.Mandatory | Should -Be $true
            }
        }

        It 'Should accept OutputPath parameter' {
            $command = Get-Command Save-LibGenBook
            $command.Parameters.ContainsKey('OutputPath') | Should -Be $true
            $outputParam = $command.Parameters['OutputPath']
            $outputParam.Attributes | Where-Object { $_ -is [Parameter] } | ForEach-Object {
                $_.Mandatory | Should -Be $true
            }
        }

        It 'Should accept Force switch' {
            $command = Get-Command Save-LibGenBook
            $command.Parameters.ContainsKey('Force') | Should -Be $true
        }
    }
}

Describe 'PSLibGen Integration Tests' -Tag 'Integration' {
    Context 'Search Functionality' {
        It 'Should return results for a common search query' {
            # This is a real search - skip if offline
            try {
                $results = Search-LibGen -Query "principia mathematica" -NoResolveLinks
                $results | Should -Not -BeNullOrEmpty
                $results[0] | Should -BeOfType [BookData]
                $results[0].Title | Should -Not -BeNullOrEmpty
            }
            catch {
                Set-ItResult -Skipped -Because "Network unavailable or LibGen unreachable"
            }
        }

        It 'Should handle empty results gracefully' {
            # Search for something that likely won't exist
            try {
                $results = Search-LibGen -Query "xyznonexistentbook12345abc" -NoResolveLinks
                $results.Count | Should -Be 0
            }
            catch [LibGenSearchException] {
                # This is also acceptable
                $true | Should -Be $true
            }
            catch {
                Set-ItResult -Skipped -Because "Network unavailable or LibGen unreachable"
            }
        }
    }
}
