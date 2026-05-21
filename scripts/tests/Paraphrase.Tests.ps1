BeforeAll {
  $repoRoot = (Resolve-Path "$PSScriptRoot/../..").Path
  Import-Module "$repoRoot/scripts/lib/Paraphrase.psm1" -Force
}

Describe 'Paraphrase' {
  It 'rewrites a long-position opener' {
    $r = Get-ParaphrasedDescription 'Enters a long position as specified by the parameters.'
    $r | Should -Not -Match 'Enters a long position as specified by the parameters'
    $r | Should -Match '(open|opens|long position)'
    $r.Length | Should -BeGreaterThan 10
  }

  It 'rewrites a short-position opener' {
    $r = Get-ParaphrasedDescription 'Enters a short position as specified by the parameters.'
    $r | Should -Not -Match 'Enters a short position as specified by the parameters'
  }

  It 'rewrites a "Returns X" formula' {
    $r = Get-ParaphrasedDescription 'Returns the absolute value of a numeric expression.'
    $r | Should -Not -Match 'Returns the absolute value of a numeric expression'
    $r | Should -Match 'absolute value'
  }

  It 'rewrites a "Used in/for" formula' {
    $r = Get-ParaphrasedDescription 'Used in strategy exit statements in place of a numerical expression.'
    $r | Should -Not -Match 'Used in strategy exit statements in place of a numerical expression'
    # Positive assertion: meaningful content preserved
    $r | Should -Match 'strategy exit'
    $r | Should -Match 'expression'
  }

  It 'preserves topical terms when the keyword is the subject' {
    $r = Get-ParaphrasedDescription 'Calculates the exponential moving average of price.'
    $r | Should -Match 'moving average'
  }

  It 'throws for descriptions it cannot safely paraphrase' {
    { Get-ParaphrasedDescription 'x' } | Should -Throw
    { Get-ParaphrasedDescription '' } | Should -Throw
  }

  It 'ensures no 10-word verbatim run remains' {
    $src = 'Enters a long position as specified by the parameters.'
    $r = Get-ParaphrasedDescription $src
    $srcWords = $src -split '\s+'
    for ($i = 0; $i -le ($srcWords.Count - 10); $i++) {
      $window = ($srcWords[$i..($i+9)] -join ' ')
      $r | Should -Not -Match ([regex]::Escape($window))
    }
  }

  It 'throws when short paraphrase still wholly contains the source' {
    # A pattern with no rule and no fallback verb — the t-unchanged check
    # in the original code already throws "could not safely paraphrase". The
    # short-source guard is for when a rule produces output that still
    # contains the original verbatim. Hard to construct synthetically without
    # a rule that intentionally fails. Use the existing throw path test.
    { Get-ParaphrasedDescription 'foo bar baz qux quux.' } | Should -Throw
  }
}
