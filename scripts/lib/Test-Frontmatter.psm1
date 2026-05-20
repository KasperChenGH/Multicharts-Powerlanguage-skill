function Test-SkillFrontmatter {
  param([Parameter(Mandatory)][string] $Path)

  $content = Get-Content $Path -Raw
  if ($content -notmatch '(?ms)\A---\s*\r?\n(.+?)\r?\n---\s*(\r?\n|\z)') {
    return @{ Valid = $false; Reason = 'no YAML frontmatter delimiters at start of file' }
  }
  $yaml = $Matches[1]

  $name = if ($yaml -match '(?m)^\s*name:\s*(\S+)\s*$') { $Matches[1] } else { $null }
  $desc = if ($yaml -match '(?ms)^\s*description:\s*(.+?)(?=(\r?\n[^\s]\w*:)|\z)') { $Matches[1].Trim() } else { $null }

  if (-not $name) { return @{ Valid = $false; Reason = 'missing name' } }
  if (-not $desc) { return @{ Valid = $false; Reason = 'missing description' } }
  if ($desc -notmatch '^Use when ') {
    return @{ Valid = $false; Reason = "description must start with 'Use when '; got: $($desc.Substring(0, [Math]::Min(40, $desc.Length)))..." }
  }

  # name must match parent folder name
  $folder = Split-Path -Leaf (Split-Path $Path -Parent)
  if ($name -ne $folder) {
    return @{ Valid = $false; Reason = "name '$name' must match folder '$folder'" }
  }

  return @{ Valid = $true; Name = $name; Description = $desc }
}

Export-ModuleMember -Function Test-SkillFrontmatter
