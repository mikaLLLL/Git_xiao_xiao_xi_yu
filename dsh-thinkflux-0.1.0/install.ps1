<#
  dsh-thinkflux one-click installer (Windows PowerShell 5.1+).

  What it does:
    1. copies the runtime files into <profile>\node_modules\dsh-thinkflux
    2. adds "dsh-thinkflux" to <profile>\package.json dependencies + dsh.profile.bundles
    3. validates the patched JSON
    4. optionally restarts DeepSeek Harness

  The same thing as `plugin_manager install_bundle target=<this folder>`.
  The profile package.json is backed up before every change.

  Examples:
    .\install.ps1
    .\install.ps1 -ProfilePath "D:\dsh\profiles\desktop" -NoRestart
    .\install.ps1 -Restart
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
$Here = $PSScriptRoot
$RuntimeFiles = @('package.json', 'client.js', 'index.js', 'cordis.patch.yml', 'locale', 'icon.svg', 'LICENSE', 'NOTICE', 'README.md')

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
  if ($env:LOCALAPPDATA) {
    $name = if ($ProfileName) { $ProfileName } elseif ($env:DSH_PROFILE) { $env:DSH_PROFILE } else { 'desktop' }
    $candidates.Add((Join-Path $env:LOCALAPPDATA "dsh\profiles\$name"))
  }
  foreach ($candidate in $candidates) {
    if (-not $candidate) { continue }
    if (-not (Test-Path -LiteralPath $candidate)) { continue }
    if (Test-Path -LiteralPath (Join-Path $candidate 'package.json')) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
  }
  $tried = ($candidates | Select-Object -Unique) -join "`n  "
  throw ('未找到 DSH profile。请用 -ProfilePath 指定，例如：' + "`n  .\install.ps1 -ProfilePath 'D:\dsh\profiles\desktop'" + "`n已尝试：`n  " + $tried)
}

function Find-DshExe {
  $proc = Get-Process -Name 'DeepSeek Harness' -ErrorAction SilentlyContinue | Where-Object { $_.Path } | Select-Object -First 1
  if ($proc -and $proc.Path) { return $proc.Path }
  $guesses = @(
    (Join-Path $env:LOCALAPPDATA 'Programs\DeepSeek Harness\DeepSeek Harness.exe'),
    (Join-Path $env:ProgramFiles 'DeepSeek Harness\DeepSeek Harness.exe')
  )
  foreach ($guess in $guesses) {
    if ($guess -and (Test-Path -LiteralPath $guess)) { return $guess }
  }
  return $null
}

function Restart-Dsh {
  $exe = Find-DshExe
  if (-not $exe) {
    Write-Warn '没找到 DeepSeek Harness.exe，请手动重启。'
    return
  }
  $helper = Join-Path $profileDir '.dsh-thinkflux-restart.ps1'
  $escaped = $exe.Replace("'", "''")
  @"
Start-Sleep -Seconds 4
Get-Process -Name 'DeepSeek Harness' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process -FilePath '$escaped'
Remove-Item -LiteralPath `$PSCommandPath -Force -ErrorAction SilentlyContinue
"@ | Set-Content -LiteralPath $helper -Encoding UTF8
  Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $helper) -WindowStyle Hidden
  Write-Ok '已在后台安排重启，窗口约 6 秒后关闭并自动重开。'
}

# ---------------------------------------------------------------- profile
$profileDir = Resolve-Profile
Write-Step "profile: $profileDir"

if (-not (Test-Path -LiteralPath (Join-Path $Here 'client.js'))) {
  throw "install.ps1 必须和 client.js 放在同一目录。当前目录：$Here"
}

# ---------------------------------------------------------------- copy
$nodeModules = Join-Path $profileDir 'node_modules'
$dest = Join-Path $nodeModules $PluginName
New-Item -ItemType Directory -Force -Path $nodeModules | Out-Null
if (Test-Path -LiteralPath $dest) {
  $bak = "$dest.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
  Move-Item -LiteralPath $dest -Destination $bak
  Write-Warn "已存在旧版本，备份到 $bak"
}
New-Item -ItemType Directory -Force -Path $dest | Out-Null
foreach ($item in $RuntimeFiles) {
  $source = Join-Path $Here $item
  if (-not (Test-Path -LiteralPath $source)) { throw "安装包缺少文件：$item" }
  Copy-Item -LiteralPath $source -Destination $dest -Recurse -Force
}
Write-Ok "复制到 $dest"

# ---------------------------------------------------------------- package.json
$pjPath = Join-Path $profileDir 'package.json'
$stamp = Get-Date -Format 'yyyyMMddHHmmss'
$pjBackup = "$pjPath.bak-$stamp"
Copy-Item -LiteralPath $pjPath -Destination $pjBackup
Write-Ok "package.json 备份：$pjBackup"

$json = Get-Content -LiteralPath $pjPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $json.dependencies) {
  $json | Add-Member -MemberType NoteProperty -Name dependencies -Value ([pscustomobject]@{}) -Force
}
$json.dependencies | Add-Member -MemberType NoteProperty -Name $PluginName -Value "file:./node_modules/$PluginName" -Force

if (-not $json.dsh) {
  $json | Add-Member -MemberType NoteProperty -Name dsh -Value ([pscustomobject]@{}) -Force
}
if (-not $json.dsh.profile) {
  $json.dsh | Add-Member -MemberType NoteProperty -Name profile -Value ([pscustomobject]@{}) -Force
}
$bundles = @($json.dsh.profile.bundles)
if ($bundles -notcontains $PluginName) { $bundles += $PluginName }
$json.dsh.profile | Add-Member -MemberType NoteProperty -Name bundles -Value $bundles -Force

$json | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $pjPath -Encoding UTF8
try {
  Get-Content -LiteralPath $pjPath -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
} catch {
  Copy-Item -LiteralPath $pjBackup -Destination $pjPath -Force
  throw "package.json 校验失败，已回滚：$($_.Exception.Message)"
}
Write-Ok "已注册 bundle：$PluginName"

# ---------------------------------------------------------------- done
Write-Host ''
Write-Host '安装完成。重启 DeepSeek Harness 后：' -ForegroundColor Green
Write-Host '  - 设置 → THINKFLUX 出现配置页'
Write-Host '  - 左下出现「思考」面板，环带随 reasoning-delta 换字'
Write-Host ''
Write-Host ("卸载：.\uninstall.ps1 -ProfilePath '" + $profileDir + "'")

if ($Restart) {
  Restart-Dsh
} elseif (-not $NoRestart) {
  $answer = Read-Host '现在重启 DeepSeek Harness？[y/N]'
  if ($answer -match '^(y|yes|是)$') { Restart-Dsh }
  else { Write-Host '请稍后手动重启。' }
}