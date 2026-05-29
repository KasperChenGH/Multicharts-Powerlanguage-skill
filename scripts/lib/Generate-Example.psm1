function New-KeywordExample {
  [CmdletBinding()]
  param([Parameter(Mandatory)][hashtable] $Parsed)

  $name   = $Parsed.Name
  $cat    = $Parsed.Category
  $params = if ($Parsed.Parameters) { $Parsed.Parameters } else { @() }

  # Skip words / pure language constructs
  if ($cat -eq 'Skip_Words') {
    return "// $name is used inside other constructs; see the Usage line above."
  }

  switch ($cat) {
    'Strategy_Orders' {
      if ($name -in @('Buy','Sell','SellShort','BuyToCover')) {
        return "$name ( ""${name}_Demo"" ) 1 Contract Next Bar Market;"
      }
      if ($name -eq 'All')      { return 'Sell All Contracts Next Bar Market;' }
      if ($name -eq 'Market')   { return 'Buy ( "Demo" ) 1 Contract Next Bar Market;' }
      if ($name -eq 'Limit')    { return 'Buy ( "Demo" ) 1 Contract Next Bar 100 Limit;' }
      if ($name -eq 'Stop')     { return 'Buy ( "Demo" ) 1 Contract Next Bar 100 Stop;' }
      if ($name -in @('Contract','Contracts'))  { return 'Buy ( "Demo" ) 2 Contracts Next Bar Market;' }
      if ($name -in @('Share','Shares'))         { return 'Buy ( "Demo" ) 100 Shares Next Bar Market;' }
      if ($name -eq 'SetStopLoss') { return 'SetStopLoss( 50 );' }
      return "// $name -- see Usage line above"
    }
    'Math_and_Trig' {
      if ($params.Count -eq 0)                           { return "Value1 = $name;" }
      if ($params.Count -eq 1 -and $params[0].Type -eq 'numeric') { return "Value1 = $name( Close );" }
      return "Value1 = $name( Close, 14 );"
    }
    'Plotting' {
      if ($name -match '^Plot\d') { return "$name( Close, ""$name demo"" );" }
      return "// $name -- see Usage line above"
    }
    'Date_and_Time_routines' {
      if ($params.Count -eq 0) { return "Value1 = $name;" }
      return "Value1 = $name( Date );"
    }
    'Declaration' {
      return "// $name appears in declarations, e.g. Inputs: x( 0 ); Variables: y( 0 );"
    }
    'Comparison_and_Loops' {
      return "// $name is used in expressions, e.g. If Close > Open Then ... ;"
    }
    'Colors' {
      return "Plot1( Close ); SetPlotColor( 1, $name );"
    }
    'Sessions' {
      if ($params.Count -eq 0) { return "Value1 = $name;" }
      return "Value1 = $name( Date );"
    }
    default {
      if ($params.Count -eq 0) { return "Value1 = $name;" }
      $argv = @()
      foreach ($p in $params | Select-Object -First 3) {
        $argv += switch ($p.Type) {
          'numeric'   { '14' }
          'string'    { '"demo"' }
          'truefalse' { 'True' }
          default     { 'Close' }
        }
      }
      return "Value1 = $name( $($argv -join ', ') );"
    }
  }
}

Export-ModuleMember -Function New-KeywordExample
