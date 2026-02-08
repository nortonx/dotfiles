# setup.ps1 — Windows bootstrap for dotfiles (Claude Code only)
# Run from PowerShell: .\setup.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Dotfiles = $PSScriptRoot
$ClaudeHome = Join-Path $env:USERPROFILE ".claude"

function Info($msg)  { Write-Host "[OK]  $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[!!]  $msg" -ForegroundColor Yellow }
function Err($msg)   { Write-Host "[ERR] $msg" -ForegroundColor Red }

# ── Ensure ~/.claude/ exists ───────────────────────────────────────
if (-not (Test-Path $ClaudeHome)) {
    New-Item -ItemType Directory -Path $ClaudeHome | Out-Null
    Info "Created $ClaudeHome"
}

# ── Helper: create junction (directories) with backup ──────────────
function Link-Dir($src, $dst) {
    # Already correctly linked
    if ((Test-Path $dst) -and ((Get-Item $dst).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        $target = (Get-Item $dst).Target
        if ($target -eq $src) {
            Info "Already linked: $dst"
            return
        }
    }

    # Back up existing directory
    if (Test-Path $dst) {
        $bak = "${dst}.bak"
        Warn "Backing up $dst -> $bak"
        Rename-Item $dst $bak
    }

    # Create directory junction (no admin required)
    cmd /c mklink /J "$dst" "$src" | Out-Null
    Info "Linked: $dst -> $src"
}

# ── Claude Code directories ───────────────────────────────────────
Write-Host ""
Write-Host "=== Claude Code ==="

$commandsSrc = Join-Path $Dotfiles "claude\commands"
$commandsDst = Join-Path $ClaudeHome "commands"
Link-Dir $commandsSrc $commandsDst

$agentsSrc = Join-Path $Dotfiles "claude\agents"
$agentsDst = Join-Path $ClaudeHome "agents"
Link-Dir $agentsSrc $agentsDst

# ── Generate merged settings.json ─────────────────────────────────
Write-Host ""
Write-Host "=== Generating Claude Code settings.json ==="

$basePath    = Join-Path $Dotfiles "claude\settings.json"
$overlayPath = Join-Path $Dotfiles "claude\settings.windows.json"
$outputPath  = Join-Path $ClaudeHome "settings.json"

# Back up existing settings.json
if (Test-Path $outputPath) {
    $bak = "${outputPath}.bak"
    Warn "Backing up $outputPath -> $bak"
    Copy-Item $outputPath $bak
}

# Deep merge: base + windows overlay
function Merge-Json($base, $overlay) {
    foreach ($prop in $overlay.PSObject.Properties) {
        $name = $prop.Name
        $val  = $prop.Value
        if ($base.PSObject.Properties[$name] -and
            $val -is [PSCustomObject] -and
            $base.$name -is [PSCustomObject]) {
            Merge-Json $base.$name $val
        } else {
            $base | Add-Member -NotePropertyName $name -NotePropertyValue $val -Force
        }
    }
    return $base
}

$base    = Get-Content $basePath -Raw | ConvertFrom-Json
$overlay = Get-Content $overlayPath -Raw | ConvertFrom-Json
$merged  = Merge-Json $base $overlay
$merged | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8
Info "Generated: $outputPath"

Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host "  Claude Code commands and agents are now linked."
