<#
  dsh-thinkflux uninstaller (Windows PowerShell 5.1+).

  Removes the bundle from <profile>\package.json and deletes
  <profile>\node_modules\dsh-thinkflux. Backups are kept.

  Examples:
    .\uninstall.ps1
    .\uninstall.ps1 -ProfilePath "D:\dsh\profiles\desktop" -NoRestart
#>
[CmdletBinding()]
param(
  [string]$ProfilePath = '',
  [string]$ProfileName = '',
  [switch]$NoRestart,
  [switch]$Restart
)

$ErrorActionPreference = 'Stop'
$PluginName = 'dsh-thinkflux'

function Write-Step([string]$Text) { Write-Host "==> $Text" -ForegroundColor Cyan }
function Write-Ok([string]$Text) { Write-Host "    $Text" -ForegroundColor Green }
function Write-Warn([string]$Text) { Write-Host "    $Text" -ForegroundColor Yellow }

function Resolve-Profile {
  $candidates = New-Object System.Collections.Generic.List[string]
  if ($ProfilePath) { $candidates.Add($ProfilePath) }
  if ($env:DSH_PROFILE_DIR) { $candidates.Add($env:DSH_PROFILE_DIR) }
  if ($env:DSH_HOME) {
    $name = if ($ProfileName) { $ProfileName } elseif ($env:DSH_PROFILE) { $env:DSH_PROFILE } else { 'desktop' }
    $candidates.Add((Join-Path $env:DSH_HOME "profiles\$name"))
  }
  if ($env:USERPROFILE) {
    $name = if ($ProfileName) { $ProfileName } elseif ($env:DSH_PROFILE) { $env:DSH_PROFILE } else { 'desktop' }
    $candidates.Add((Join-Path $env:USERPROFILE ".dsh\profiles\$name"))
  }
  foreach ($candidate in $candidates) {
    if (-not $candidate) { continue }
    if (-not (Test-Path -LiteralPath $candidate)) { continue }
    if (Test-Path -LiteralPath (Join-Path $candidate 'package.json')) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }
  throw '未找到 DSH profile，请用 -ProfilePath 指定。'
}

function Find-DshExe {
  $proc = Get-Process -Name 'DeepSeek Harness' -ErrorAction SilentlyContinue | Where-Object { $_.Path } | Select-Object -First 1
  if ($proc -and $proc.Path) { return $proc.Path }
  foreach ($guess in @(
      (Join-Path $env:LOCALAPPDATA 'Programs\DeepSeek Harness\DeepSeek Harness.exe'),
      (Join-Path $env:ProgramFiles 'DeepSeek Harness\DeepSeek Harness.exe'))) {
    if ($guess -and (Test-Path -LiteralPath $guess)) { return $guess }
  }
  return $null
}

function Restart-Dsh {
  $exe = Find-DshExe
  if (-not $exe) { Write-Warn '没找到 DeepSeek Harness.exe，请手动重启。'; return }
  $helper = Join-Path ([System.IO.Path]::GetTempPath()) 'dsh-thinkflux-restart.ps1'
  $escaped = $exe.Replace("'", "''")
  @"
Start-Sleep -Seconds 4
Get-Process -Name 'DeepSeek Harness' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process -FilePath '$escaped'
"@ | Set-Content -LiteralPath $helper -Encoding UTF8
  Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $helper) -WindowStyle Hidden
  Write-Ok '已在后台安排重启。'
}

$profileDir = Resolve-Profile
Write-Step "profile: $profileDir"
$pjPath = Join-Path $profileDir 'package.json'
$json = Get-Content -LiteralPath $pjPath -Raw -Encoding UTF8 | ConvertFrom-Json
$backup = "$pjPath.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item -LiteralPath $pjPath -Destination $backup

if ($json.dependencies -and $json.dependencies.PSObject.Properties.Name -contains $PluginName) {
  $json.dependencies.PSObject.Properties.Remove($PluginName)
}
if ($json.dsh -and $json.dsh.profile -and $json.dsh.profile.bundles) {
  $bundles = @($json.dsh.profile.bundles) | Where-Object { $_ -ne $PluginName }
  $json.dsh.profile | Add-Member -MemberType NoteProperty -Name bundles -Value @($bundles) -Force
}
$json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $pjPath -Encoding UTF8
try {
  Get-Content -LiteralPath $pjPath -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
} catch {
  Copy-Item -LiteralPath $backup -Destination $pjPath -Force
  throw "package.json 校验失败，已回滚：$($_.Exception.Message)"
}
Write-Ok "已从 package.json 移除（备份：$backup）"

$dest = Join-Path (Join-Path $profileDir 'node_modules') $PluginName
if (Test-Path -LiteralPath $dest) {
  $trash = "$dest.removed-$(Get-Date -Format 'yyyyMMddHHmmss')"
  Move-Item -LiteralPath $dest -Destination $trash
  Write-Ok "已移走 $dest → $trash"
} else {
  Write-Warn "未找到 $dest（可能已卸载）"
}

Write-Host ''
Write-Host '卸载完成，重启 DeepSeek Harness 后生效。' -ForegroundColor Green
if ($Restart) {
  Restart-Dsh
} elseif (-not $NoRestart) {
  $answer = Read-Host '现在重启 DeepSeek Harness？[y/N]'
  if ($answer -match '^(y|yes|是)$') { Restart-Dsh }
  else { Write-Host '请稍后手动重启。' }
}
