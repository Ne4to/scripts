Write-Host $env:SHOW_STAT
Write-Host $env:MIN_SIZE_KB

if ([System.Boolean]::Parse($env:SHOW_STAT)) {
  Get-ChildItem -Recurse -File |
    Group-Object Extension |
    ForEach-Object {
      $GroupStat = @{};

      $_.Group |
        Measure-Object Length -Sum |
        ForEach-Object {
            $GroupStat[$_.Property] = $_.Sum
        };

      [PSCustomObject]@{
          Count = $_.Count;
          Extension = $_.Name;
          TotalSize = $GroupStat["Length"]
      }
    } |
    Sort-Object TotalSize -Descending |
    Format-Table  -AutoSize `
      Count,
      @{Label = "Total Size"; Expression = {([long]($_.TotalSize)).ToString("N0")}; Alignment = "Right" },
      Extension
} else {
  Write-Host "Min size: $env:MIN_SIZE_KB Kb"

  Get-ChildItem -Recurse -File |
    Where-Object Length -gt $MinSize |
    Select-Object -Property FullName,Length |
    Sort-Object Length |
    Format-Table -Wrap @{Label = "Size(Kb)"; Expression = {[int]($_.Length / 1024)}},@{Label = "FullName"; Expression = {$_.FullName}} |
    Out-String -Width 220
}

