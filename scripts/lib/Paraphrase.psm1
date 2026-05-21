function Get-ParaphrasedDescription {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string] $SourceText)

  if ([string]::IsNullOrWhiteSpace($SourceText) -or $SourceText.Length -lt 8) {
    throw "Get-ParaphrasedDescription: input too short ('$SourceText')"
  }

  $t = $SourceText.Trim()
  $orig = $t

  # Ordered rule-based rewrites for stock MCT phrasings.
  $rules = @(
    @{ From = '^Enters a long position as specified by the parameters\.?$';       To = 'Opens a long position with the size and timing given by the parameters.' }
    @{ From = '^Enters a short position as specified by the parameters\.?$';      To = 'Opens a short position with the size and timing given by the parameters.' }
    @{ From = '^Closes? (an? )?long position as specified.*$';                    To = 'Exits the current long position per the parameters.' }
    @{ From = '^Closes? (an? )?short position as specified.*$';                   To = 'Exits the current short position per the parameters.' }
    @{ From = '^Returns the (.+?) of (.+?)\.?$';                                  To = 'Yields the $1 of $2.' }
    @{ From = '^Calculates the (.+?)\.?$';                                        To = 'Computes the $1.' }
    @{ From = '^Used in (.+?)\.?$';                                               To = 'Appears inside $1.' }
    @{ From = '^Used for (.+?)\.?$';                                              To = 'Helps when $1.' }
    @{ From = '^Specifies (.+?)\.?$';                                             To = 'Sets $1.' }
    @{ From = '^Generates? (.+?)\.?$';                                            To = 'Produces $1.' }
    @{ From = '^The (.+?) function returns (.+?)\.?$';                            To = 'Returns $2 (function: $1).' }
  )

  $changed = $false
  foreach ($rule in $rules) {
    if ($t -match $rule.From) {
      $t = [regex]::Replace($t, $rule.From, $rule.To)
      $changed = $true
      break
    }
  }

  if (-not $changed) {
    if ($t.Length -lt 20) {
      throw "Get-ParaphrasedDescription: text too short for safe paraphrase: '$SourceText'"
    }
    $t = $t -replace '\bReturns\b','Provides'
    $t = $t -replace '\bPerforms\b','Invokes'
    $t = $t -replace '\bExecutes\b','Runs'
    $t = $t -replace '\bAllows\b','Enables'
    if ($t -eq $orig) {
      throw "Get-ParaphrasedDescription: could not safely paraphrase: '$SourceText'"
    }
  }

  # Final defense: no 10-consecutive-word verbatim run remains.
  # Edge case: source too short for the 10-word window check.
  # Require the paraphrase to not literally contain the whole source.
  $origWords = $orig -split '\s+'
  if ($origWords.Count -lt 10) {
    $normOrig = ($orig -replace '\s+', ' ').Trim().ToLowerInvariant()
    $normNew  = ($t    -replace '\s+', ' ').Trim().ToLowerInvariant()
    if ($normNew -like "*$normOrig*") {
      throw "Get-ParaphrasedDescription: source too short and paraphrase still contains the entire source verbatim: '$SourceText'"
    }
  }

  # Existing 10-word window check follows ...
  for ($i = 0; $i -le ($origWords.Count - 10); $i++) {
    $window = ($origWords[$i..($i+9)] -join ' ')
    if ($t -like "*$window*") {
      throw "Get-ParaphrasedDescription: 10-word verbatim run remains: '$window' (from: '$SourceText')"
    }
  }

  return $t
}

Export-ModuleMember -Function Get-ParaphrasedDescription
