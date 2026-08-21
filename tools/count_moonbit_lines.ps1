param(
  [int]$RequireMinimum = 0
)

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$all = Get-ChildItem (Join-Path $root 'src'), (Join-Path $root 'cmd') -Recurse -File -Filter '*.mbt' |
  Where-Object {
    $_.FullName -notlike '*\_build\*' -and
    $_.FullName -notlike '*\.mooncakes\*'
  }
$production = @($all | Where-Object { $_.Name -notlike '*_test.mbt' })
$tests = @($all | Where-Object { $_.Name -like '*_test.mbt' })

function Count-MoonBitLines([System.IO.FileInfo]$file) {
  $count = 0
  foreach ($line in Get-Content -LiteralPath $file.FullName) {
    $trimmed = $line.Trim()
    if ($trimmed -ne '' -and $trimmed -notlike '/// *' -and $trimmed -notlike '//!*') {
      $count++
    }
  }
  return $count
}

$productionLines = 0
foreach ($file in $production) { $productionLines += Count-MoonBitLines $file }
$testLines = 0
foreach ($file in $tests) { $testLines += Count-MoonBitLines $file }
$totalLines = $productionLines + $testLines

Write-Output "production_noncomment=$productionLines production_files=$($production.Count) test_noncomment=$testLines test_files=$($tests.Count) total_noncomment=$totalLines"
if ($RequireMinimum -gt 0 -and $productionLines -lt $RequireMinimum) {
  Write-Error "production MoonBit source is below the required minimum: $productionLines < $RequireMinimum"
  exit 1
}
