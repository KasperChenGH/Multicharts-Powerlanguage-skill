BeforeAll {
  $repoRoot = (Resolve-Path "$PSScriptRoot/../..").Path
  Import-Module "$repoRoot/scripts/lib/Generate-Example.psm1" -Force
}

Describe 'Generate-Example' {
  It 'builds an example for Buy from signature + params' {
    $parsed = @{
      Name = 'Buy'; Category = 'Strategy_Orders'
      Usage = 'Buy [("EntryLabel")] [TradeSize] EntryType ;'
      Parameters = @(
        @{ Name = 'EntryLabel'; Type = 'string';     Required = $false; Description = 'optional name' }
        @{ Name = 'TradeSize';  Type = 'numeric';    Required = $false; Description = 'optional size' }
        @{ Name = 'EntryType';  Type = 'expression'; Required = $true;  Description = 'placement' }
      )
    }
    $ex = New-KeywordExample $parsed
    $ex | Should -Match 'Buy\s*\(\s*"[A-Za-z_]+"\s*\)\s*1\s+Contract\s+Next\s+Bar'
  }

  It 'builds an example for a zero-param keyword (All)' {
    $parsed = @{
      Name = 'All'; Category = 'Strategy_Orders'
      Usage = 'All Contracts'
      Parameters = @()
    }
    $ex = New-KeywordExample $parsed
    $ex | Should -Match 'Sell\s+All\s+(Contracts|Shares)'
  }

  It 'falls back to commented usage line for skip-word keywords' {
    $parsed = @{
      Name = 'On'; Category = 'Skip_Words'
      Usage = 'optional connector keyword'
      Parameters = @()
    }
    $ex = New-KeywordExample $parsed
    $ex | Should -Match '^//\s'
    $ex | Should -Match 'On'
  }

  It 'builds an Average call when params suggest numeric series + length' {
    $parsed = @{
      Name = 'Average'; Category = 'Math_and_Trig'
      Usage = 'Average( Price, Length )'
      Parameters = @(
        @{ Name = 'Price';  Type = 'expression'; Required = $true; Description = 'price series' }
        @{ Name = 'Length'; Type = 'numeric';    Required = $true; Description = 'lookback bars' }
      )
    }
    $ex = New-KeywordExample $parsed
    $ex | Should -Match 'Value1\s*=\s*Average\(\s*Close\s*,\s*14\s*\)'
  }

  It 'builds a Plot1 call for plotting keywords' {
    $parsed = @{
      Name = 'Plot1'; Category = 'Plotting'
      Usage = 'Plot1( Value, "Name" )'
      Parameters = @(
        @{ Name = 'Value'; Type = 'numeric'; Required = $true; Description = 'value to plot' }
      )
    }
    $ex = New-KeywordExample $parsed
    $ex | Should -Match 'Plot1\(\s*Close'
  }

  It 'never references the SourceExampleBlock field' {
    $parsed = @{
      Name = 'TestFn'; Category = 'Math_and_Trig'
      Usage = 'TestFn( x )'
      Parameters = @(
        @{ Name = 'x'; Type = 'numeric'; Required = $true; Description = 'a value' }
      )
      SourceExampleBlock = 'COPYRIGHTED_VERBATIM_TEXT_THAT_MUST_NOT_APPEAR_IN_OUTPUT'
    }
    $ex = New-KeywordExample $parsed
    $ex | Should -Not -Match 'COPYRIGHTED_VERBATIM_TEXT_THAT_MUST_NOT_APPEAR_IN_OUTPUT'
  }
}
