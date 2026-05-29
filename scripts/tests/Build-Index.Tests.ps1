BeforeAll {
  $repoRoot = (Resolve-Path "$PSScriptRoot/../..").Path
  Import-Module "$repoRoot/scripts/lib/Build-Index.psm1" -Force

  $script:tmp = "$repoRoot/scripts/.cache/test-build-index"
  Remove-Item $script:tmp -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Path "$script:tmp/details/Strategy_Orders" -Force | Out-Null
  New-Item -ItemType Directory -Path "$script:tmp/details/Math_and_Trig" -Force | Out-Null

  # Two minimal fixture .md files
  $buyMd = @"
# Buy

**Category:** Strategy_Orders
**Signature:** ``Buy [("EntryLabel")] [TradeSize] EntryType ;``

Opens a long position.
"@
  $absMd = @"
# AbsValue

**Category:** Math_and_Trig
**Signature:** ``AbsValue( x )``

Yields the absolute value of x.
"@

  Set-Content "$script:tmp/details/Strategy_Orders/Buy.md" -Value $buyMd -Encoding UTF8
  Set-Content "$script:tmp/details/Math_and_Trig/AbsValue.md" -Value $absMd -Encoding UTF8
}

AfterAll {
  Remove-Item $script:tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Describe 'Build-Index' {
  It 'produces a markdown file with one section per category, sorted' {
    $out = New-KeywordsIndex -DetailsRoot "$script:tmp/details" -OutputPath "$script:tmp/keywords-index.md"
    Test-Path $out | Should -BeTrue
    $body = Get-Content $out -Raw
    # Both categories must appear, alphabetically (Math_and_Trig before Strategy_Orders)
    $mathPos = $body.IndexOf('## Math_and_Trig')
    $stratPos = $body.IndexOf('## Strategy_Orders')
    $mathPos | Should -BeGreaterThan -1
    $stratPos | Should -BeGreaterThan -1
    $mathPos | Should -BeLessThan $stratPos
  }

  It 'renders each keyword as a table row with name + signature' {
    $body = Get-Content "$script:tmp/keywords-index.md" -Raw
    $body | Should -Match '\| `Buy` \| `Buy \[\("EntryLabel"\)\] \[TradeSize\] EntryType ;` \|'
    $body | Should -Match '\| `AbsValue` \| `AbsValue\( x \)` \|'
  }

  It 'skips empty category folders' {
    # Add an empty category folder
    New-Item -ItemType Directory -Path "$script:tmp/details/EmptyCat" -Force | Out-Null
    New-KeywordsIndex -DetailsRoot "$script:tmp/details" -OutputPath "$script:tmp/keywords-index.md"
    $body = Get-Content "$script:tmp/keywords-index.md" -Raw
    $body | Should -Not -Match '## EmptyCat'
  }

  It 'has a top-level heading and intro paragraph' {
    $body = Get-Content "$script:tmp/keywords-index.md" -Raw
    $body | Should -Match '^# PowerLanguage Keywords Index'
    $body | Should -Match '40 categories'
  }
}
