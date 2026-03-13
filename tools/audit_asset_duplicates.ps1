param(
  [string]$RepoRoot='.',
  [string]$ReportPath='docs/reports/ASSET_DUPLICATION_AUDIT.md',
  [switch]$Strict,
  [switch]$FailOnSuspicious
)
$ErrorActionPreference='Stop'

function Rel([string]$root,[string]$full){
  $rootFull=[System.IO.Path]::GetFullPath($root).TrimEnd('\\') + '\\'
  $uRoot=New-Object System.Uri($rootFull)
  $uFile=New-Object System.Uri([System.IO.Path]::GetFullPath($full))
  ($uRoot.MakeRelativeUri($uFile).ToString().Replace('\\','/')).TrimStart('.','/')
}

function Reason([string]$stem){
  if($stem -match '(_copy| copy)'){return 'contains copy marker'}
  if($stem -match '(_new|new$)'){return 'contains new marker'}
  if($stem -match '(_old|old$)'){return 'contains old marker'}
  if($stem -match '(_final|final$|final\d+$)'){return 'contains final marker'}
  if($stem -match '_v\d+$'){return 'contains version suffix (_vN)'}
  if($stem -match '(?:^|[_-])1$'){return 'numeric duplicate-like suffix (1)'}
  if($stem -match ' -\d+$'){return 'space-dash numeric suffix'}
  return 'name resembles a duplicate variant'
}

$repo=[System.IO.Path]::GetFullPath((Resolve-Path $RepoRoot))
$reportFull=[System.IO.Path]::GetFullPath((Join-Path $repo $ReportPath))
$reportDir=Split-Path -Parent $reportFull
if(-not (Test-Path $reportDir)){ New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }

$assetRoot=Join-Path $repo 'assets'
if(-not (Test-Path $assetRoot)){ throw 'assets/ not found' }
$visualExt=@('.png','.webp','.jpg','.jpeg','.svg')
$rows=@()
Get-ChildItem $assetRoot -Recurse -File | Where-Object { $visualExt -contains $_.Extension.ToLowerInvariant() } | ForEach-Object {
  $rel=Rel $repo $_.FullName
  $rows += [pscustomobject]@{
    RelPath=$rel
    ResPath=('res://'+$rel)
    Name=$_.Name
    Stem=[IO.Path]::GetFileNameWithoutExtension($_.Name)
    Size=[int64]$_.Length
    Hash=(Get-FileHash -Algorithm SHA256 -Path $_.FullName).Hash.ToLowerInvariant()
    Referenced=$false
  }
}

$refExt=@('.tscn','.tres','.gd','.res')
$rx=[regex]'res://[A-Za-z0-9_./\\-]+'
$refs=New-Object 'System.Collections.Generic.HashSet[string]'
Get-ChildItem $repo -Recurse -File | Where-Object { $refExt -contains $_.Extension.ToLowerInvariant() } | ForEach-Object {
  try {
    $txt=Get-Content -Raw $_.FullName -ErrorAction Stop
    foreach($m in $rx.Matches($txt)){ $null=$refs.Add($m.Value.Replace('\\','/')) }
  } catch {}
}
foreach($r in $rows){ $r.Referenced = $refs.Contains($r.ResPath) }

$exact=$rows | Group-Object Hash | Where-Object { $_.Count -gt 1 } | Sort-Object Count -Descending
$sameName=$rows | Group-Object Name | Where-Object { $_.Count -gt 1 } | Sort-Object Count -Descending
$susp=$rows | Where-Object { $_.Stem.ToLowerInvariant() -match '(_copy| copy|_final|final$|final\d+$|_new|new$|_old|old$|_v\d+$|(?:^|[_-])1$| -\d+$)' } | Sort-Object RelPath

$dupFiles=0; foreach($g in $exact){ $dupFiles += ($g.Count - 1) }
$refDupGroups=0; $unrefDupFiles=0
foreach($g in $exact){
  $items=@($g.Group)
  if((($items | Where-Object { $_.Referenced } | Measure-Object).Count) -gt 0){ $refDupGroups++ }
  $unrefDupFiles += (($items | Where-Object { -not $_.Referenced } | Measure-Object).Count)
}

$safe=New-Object System.Collections.Generic.List[object]
$manual=New-Object System.Collections.Generic.List[object]
foreach($g in $exact){
  $items=@($g.Group) | Sort-Object @{e={if($_.Referenced){0}else{1}}}, @{e={$_.RelPath.Length}}, RelPath
  $keep=$items[0]
  $refCount=(($items | Where-Object { $_.Referenced } | Measure-Object).Count)
  foreach($it in ($items | Select-Object -Skip 1)){
    if(-not $it.Referenced){
      $reason = if($refCount -eq 1){'only one referenced file in duplicate group'} else {'exact duplicate and unreferenced'}
      $safe.Add([pscustomobject]@{ Path=$it.RelPath; Keep=$keep.RelPath; Reason=$reason }) | Out-Null
    } else {
      $manual.Add([pscustomobject]@{ Path=$it.RelPath; Keep=$keep.RelPath; Reason='referenced duplicate; needs manual review' }) | Out-Null
    }
  }
}

$out=New-Object System.Collections.Generic.List[string]
$out.Add('# Asset Duplication Audit')
$out.Add('')
$out.Add('## Summary')
$out.Add("- total visual asset files scanned: **$($rows.Count)**")
$out.Add("- exact duplicate groups count: **$($exact.Count)**")
$out.Add("- duplicate files count: **$dupFiles**")
$out.Add("- same-name multi-path conflicts count: **$($sameName.Count)**")
$out.Add("- suspicious near-duplicate count: **$($susp.Count)**")
$out.Add("- referenced duplicate groups count: **$refDupGroups**")
$out.Add("- unreferenced duplicate files count: **$unrefDupFiles**")
$out.Add('')
$out.Add('## Exact duplicate groups')
if($exact.Count -eq 0){
  $out.Add('No exact duplicate groups found.')
} else {
  foreach($g in $exact){
    $items=@($g.Group) | Sort-Object RelPath
    $canonical=($items | Sort-Object @{e={if($_.Referenced){0}else{1}}}, @{e={$_.RelPath.Length}}, RelPath | Select-Object -First 1)
    $refInGroup=(($items | Where-Object { $_.Referenced } | Measure-Object).Count)
    $sizes=(($items | Select-Object -ExpandProperty Size | Sort-Object -Unique) -join ', ')
    $out.Add('')
    $out.Add("- hash: $($g.Name)")
    $out.Add("  - file size(s): $sizes bytes")
    $out.Add("  - referenced in group: $refInGroup / $($items.Count)")
    $out.Add("  - recommended canonical keep candidate: res://$($canonical.RelPath)")
    $out.Add('  - files:')
    foreach($it in $items){ $st=if($it.Referenced){'referenced'}else{'unreferenced'}; $out.Add("    - res://$($it.RelPath) ($st)") }
  }
}
$out.Add('')
$out.Add('## Same filename in multiple locations')
if($sameName.Count -eq 0){
  $out.Add('No same-filename multi-path conflicts found.')
} else {
  foreach($g in $sameName){
    $items=@($g.Group) | Sort-Object RelPath
    $identical=((($items | Select-Object -ExpandProperty Hash | Sort-Object -Unique).Count) -eq 1)
    $status=if($identical){'identical content'}else{'different content'}
    $out.Add('')
    $out.Add("- filename: $($g.Name) ($status)")
    foreach($it in $items){ $st=if($it.Referenced){'referenced'}else{'unreferenced'}; $out.Add("  - res://$($it.RelPath) ($st)") }
  }
}
$out.Add('')
$out.Add('## Suspicious near-duplicates')
if($susp.Count -eq 0){
  $out.Add('No suspicious near-duplicate names found with current rules.')
} else {
  foreach($it in $susp){ $st=if($it.Referenced){'referenced'}else{'unreferenced'}; $out.Add("- res://$($it.RelPath) - $(Reason $it.Stem.ToLowerInvariant()) ($st)") }
}
$out.Add('')
$out.Add('## Likely cleanup opportunities')
$out.Add('- Safe candidate duplicates not referenced anywhere:')
if($safe.Count -eq 0){ $out.Add('  - none') } else { foreach($c in ($safe | Sort-Object Path)){ $out.Add("  - res://$($c.Path) (exact duplicate of res://$($c.Keep); $($c.Reason))") } }
$out.Add('- Duplicates where only one path is referenced:')
$single=$safe | Where-Object { $_.Reason -eq 'only one referenced file in duplicate group' } | Sort-Object Path
if((($single | Measure-Object).Count) -eq 0){ $out.Add('  - none') } else { foreach($c in $single){ $out.Add("  - res://$($c.Path) (duplicate of res://$($c.Keep))") } }
$out.Add('- Duplicates that should be manually reviewed because referenced from scenes/resources/scripts:')
if($manual.Count -eq 0){ $out.Add('  - none') } else { foreach($c in ($manual | Sort-Object Path)){ $out.Add("  - res://$($c.Path) (also referenced; duplicate of res://$($c.Keep))") } }
$out.Add('')
$out.Add('## No-action guarantee')
$out.Add('This audit was read-only: no assets were deleted, renamed, moved, or rewired.')

[IO.File]::WriteAllLines($reportFull,$out)

$top=$safe | Sort-Object Path | Select-Object -First 10
$summary=[pscustomobject]@{
  report_path=$ReportPath
  total_visual_assets=$rows.Count
  exact_duplicate_groups=$exact.Count
  duplicate_files=$dupFiles
  same_name_multi_path=$sameName.Count
  suspicious_near_duplicates=$susp.Count
  referenced_duplicate_groups=$refDupGroups
  unreferenced_duplicate_files=$unrefDupFiles
  top_candidate_count=(($top|Measure-Object).Count)
}
$jsonSummaryPath=[System.IO.Path]::Combine($reportDir,'ASSET_DUPLICATION_AUDIT_SUMMARY.json')
$summary | ConvertTo-Json | Set-Content -Encoding UTF8 $jsonSummaryPath

$summary | ConvertTo-Json -Compress
if((($top|Measure-Object).Count) -gt 0){
  'TOP_CANDIDATES_START'
  foreach($c in $top){ "res://$($c.Path) -> keep res://$($c.Keep) ($($c.Reason))" }
  'TOP_CANDIDATES_END'
}

if($Strict){
  $shouldFail = ($exact.Count -gt 0) -or ($sameName.Count -gt 0) -or ($refDupGroups -gt 0) -or ($unrefDupFiles -gt 0)
  if($FailOnSuspicious -and $susp.Count -gt 0){ $shouldFail = $true }
  if($shouldFail){
    Write-Error ("Asset path canon violation. exact_duplicate_groups={0}, same_name_multi_path={1}, referenced_duplicate_groups={2}, unreferenced_duplicate_files={3}, suspicious_near_duplicates={4}" -f $exact.Count,$sameName.Count,$refDupGroups,$unrefDupFiles,$susp.Count)
    exit 2
  }
}
