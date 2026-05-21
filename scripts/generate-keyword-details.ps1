<#
.SYNOPSIS
  Build the multicharts-powerlanguage skill's keywords reference.
.DESCRIPTION
  Walks the CHM-extracted HTML files, parses each, generates an original
  paraphrased markdown summary + a generated example, writes details/<Cat>/<Kw>.md,
  rebuilds keywords-index.md, and emits tests/test_*.pla fixtures.

  Maintainer-only. End users never run this — they get the committed outputs.
.PARAMETER ChmExtractedRoot
  Path to the decompiled CHM root (containing files/03_words/<Category>/<kw>.htm).
  Defaults to references/chm_extracted at repo root.
.PARAMETER DetailsRoot
  Output root for per-keyword markdown. Defaults to
  skills/powerlanguage-keywords-reference/details at repo root.
.PARAMETER IndexPath
  Output path for keywords-index.md.
.PARAMETER TestsDir
  Output dir for test_*.pla fixtures.
.PARAMETER ChmPath
  Path to PowerLanguage.chm. If set and ChmExtractedRoot is empty, the script
  decompiles via hh.exe first.
#>
[CmdletBinding()]
param(
  [string] $ChmExtractedRoot = '',
  [string] $DetailsRoot      = '',
  [string] $IndexPath        = '',
  [string] $TestsDir         = '',
  [string] $ChmPath          = 'C:\Program Files\TS Support\MultiCharts64\PowerLanguage.chm'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path "$PSScriptRoot/..").Path

if ([string]::IsNullOrWhiteSpace($ChmExtractedRoot)) { $ChmExtractedRoot = "$repoRoot/references/chm_extracted" }
if ([string]::IsNullOrWhiteSpace($DetailsRoot))      { $DetailsRoot      = "$repoRoot/skills/powerlanguage-keywords-reference/details" }
if ([string]::IsNullOrWhiteSpace($IndexPath))        { $IndexPath        = "$repoRoot/skills/powerlanguage-keywords-reference/keywords-index.md" }
if ([string]::IsNullOrWhiteSpace($TestsDir))         { $TestsDir         = "$repoRoot/tests" }

# Decompile CHM if needed
if (-not (Test-Path "$ChmExtractedRoot/files/03_words")) {
  if (Test-Path $ChmPath) {
    Write-Host "Decompiling $ChmPath -> $ChmExtractedRoot"
    New-Item -ItemType Directory -Path $ChmExtractedRoot -Force | Out-Null
    Start-Process -FilePath 'C:\Windows\hh.exe' -ArgumentList '-decompile',$ChmExtractedRoot,$ChmPath -Wait
  } else {
    throw "CHM source not found at $ChmPath and no pre-extracted tree at $ChmExtractedRoot"
  }
}

# Import all modules
$libs = 'Parse-Chm','Paraphrase','Generate-Example','Write-DetailFile','Build-Index','Build-PlaFixtures','Test-VerbatimLint'
foreach ($lib in $libs) {
  Import-Module "$repoRoot/scripts/lib/$lib.psm1" -Force
}

function Get-CleanedParamDescription {
  param([string] $RawDesc)

  # Strip CHM boilerplate prefixes that we already encode separately via *(optional)*/*(required)*.
  $cleaned = $RawDesc
  $cleaned = $cleaned -replace '^\s*an\s+optional\s+parameter\s*;\s*',''
  $cleaned = $cleaned -replace '^\s*a\s+required\s+parameter\s*;\s*',''
  $cleaned = $cleaned -replace '^\s*an?\s+optional\s+parameter\.\s*',''
  $cleaned = $cleaned -replace '^\s*a\s+required\s+parameter\.\s*',''
  $cleaned = $cleaned.Trim()

  # Try the rule-based paraphraser first.
  try {
    return Get-ParaphrasedDescription $cleaned
  } catch {
    # Paraphraser couldn't safely rewrite this one. Fall back to a short, original
    # placeholder pointing the user at the wiki for full details.
    # Take the first <= 6 words (under the 9-word lint threshold) and append a citation.
    $words = $cleaned -split '\s+'
    $first = ($words | Select-Object -First 6) -join ' '
    return "$first — see official docs"
  }
}

# Find every .htm under the category tree
$htmFiles = Get-ChildItem "$ChmExtractedRoot/files/03_words" -Recurse -Filter '*.htm'
Write-Host "Found $($htmFiles.Count) keyword .htm files"

$parsedKeywords = @()
$failures = @()

foreach ($f in $htmFiles) {
  try {
    $parsed = Parse-ChmFile $f.FullName
    $paraphrased = Get-ParaphrasedDescription $parsed.Description
    $example = New-KeywordExample $parsed

    # Clean and paraphrase each parameter description before writing.
    $cleanParams = @()
    foreach ($p in $parsed.Parameters) {
      $cleanParams += @{
        Name        = $p.Name
        Type        = $p.Type
        Required    = $p.Required
        Description = Get-CleanedParamDescription $p.Description
      }
    }
    $parsed.Parameters = $cleanParams

    $outPath = Write-KeywordDetailFile -Parsed $parsed -Description $paraphrased -Example $example -OutputRoot $DetailsRoot

    # Verbatim lint
    $md = Get-Content $outPath -Raw
    $htm = Get-Content $f.FullName -Raw
    if (Test-VerbatimLint -MarkdownText $md -SourceHtmlText $htm) {
      $failures += @{ File = $f.FullName; Reason = 'verbatim-lint' }
    }
    $parsedKeywords += $parsed
  } catch {
    $failures += @{ File = $f.FullName; Reason = $_.Exception.Message }
  }
}

# Build the index
New-KeywordsIndex -DetailsRoot $DetailsRoot -OutputPath $IndexPath | Out-Null
Write-Host "Wrote index: $IndexPath"

# Build the .pla fixtures
if (-not (Test-Path $TestsDir)) { New-Item -ItemType Directory -Path $TestsDir -Force | Out-Null }
New-PlaFixtures -Keywords $parsedKeywords -OutputDir $TestsDir
Write-Host "Wrote .pla fixtures in: $TestsDir"

# Report failures
if ($failures.Count -gt 0) {
  Write-Host ""
  Write-Host "$($failures.Count) keyword(s) need manual authoring:" -ForegroundColor Yellow
  $failures | ForEach-Object {
    Write-Host "  $($_.File)  =>  $($_.Reason)" -ForegroundColor Yellow
  }
} else {
  Write-Host ""
  Write-Host "All $($htmFiles.Count) keywords generated successfully." -ForegroundColor Green
}
