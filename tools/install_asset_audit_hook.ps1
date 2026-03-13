param(
  [string]$RepoRoot='.'
)
$ErrorActionPreference='Stop'

$hookDir = Join-Path $RepoRoot '.git/hooks'
if(-not (Test-Path $hookDir)){
  throw '.git/hooks not found. Run from repository root.'
}

$hookPath = Join-Path $hookDir 'pre-commit'
$scriptLines=@(
  '#!/usr/bin/env pwsh',
  '$ErrorActionPreference = "Stop"',
  'powershell -ExecutionPolicy Bypass -File tools/audit_asset_duplicates.ps1 -RepoRoot . -ReportPath docs/reports/ASSET_DUPLICATION_AUDIT.md -Strict'
)
Set-Content -Path $hookPath -Value ($scriptLines -join [Environment]::NewLine) -Encoding UTF8
Write-Output "Installed pre-commit hook: $hookPath"
