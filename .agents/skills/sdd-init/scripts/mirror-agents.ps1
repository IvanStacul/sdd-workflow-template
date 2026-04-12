<#
.SYNOPSIS
    Genera copias (o symlinks) de .agents/ para editores específicos.

.DESCRIPTION
    Port PowerShell de mirror-agents.sh.
    Fuente de verdad: .agents/
    Genera mirrors en .claude/, .cursor/, .opencode/, etc.

.PARAMETER Editors
    Lista de editores a generar. Usar "all" para todos.

.PARAMETER Symlink
    Usar symlinks en lugar de copias para skills/ y commands/.
    Los root files siempre se copian.

.EXAMPLE
    .\mirror-agents.ps1 cursor claude opencode vscode
    .\mirror-agents.ps1 -Symlink cursor claude
    .\mirror-agents.ps1 all
#>
param(
    [switch]$Symlink,
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Editors
)

$ErrorActionPreference = "Stop"
$AgentsDir = ".agents"

$AllEditors = @("cursor", "claude", "opencode", "gemini", "codex", "qwen", "antigravity", "amazonq", "vscode")

$EditorConfig = @{
    cursor      = @{ TargetDir = ".cursor";   SkillsDir = "skills"; CommandsDir = "commands" }
    claude      = @{ TargetDir = ".claude";   SkillsDir = "skills"; CommandsDir = "commands" }
    opencode    = @{ TargetDir = ".opencode"; SkillsDir = "skills"; CommandsDir = "command" }
    gemini      = @{ TargetDir = ".gemini";   SkillsDir = "skills"; CommandsDir = "commands" }
    codex       = @{ TargetDir = ".codex";    SkillsDir = "skills"; CommandsDir = $null }
    qwen        = @{ TargetDir = ".qwen";     SkillsDir = "skills"; CommandsDir = "commands" }
    antigravity = @{ TargetDir = ".agent";    SkillsDir = "skills"; CommandsDir = "workflows" }
    amazonq     = @{ TargetDir = ".amazonq";  SkillsDir = "skills"; CommandsDir = $null }
}

# Mapa de editores que necesitan archivo raíz
# Nota: Cursor lee AGENTS.md directamente, no necesita root file.
$RootFiles = @{
    claude = "CLAUDE.md"
    gemini = "GEMINI.md"
    codex  = "CODEX.md"
}

function Show-Usage {
    Write-Host "Uso: .\mirror-agents.ps1 [-Symlink] <editor1> [editor2] ..."
    Write-Host ""
    Write-Host "Opciones:"
    Write-Host "  -Symlink     Usar symlinks en lugar de copias para skills/ y commands/"
    Write-Host "               (los root files siempre se copian)"
    Write-Host ""
    Write-Host "Editores soportados:"
    Write-Host "  cursor       -> .cursor/ (lee AGENTS.md directo)"
    Write-Host "  claude       -> .claude/ + CLAUDE.md (import @AGENTS.md)"
    Write-Host "  opencode     -> .opencode/"
    Write-Host "  gemini       -> .gemini/ + GEMINI.md"
    Write-Host "  codex        -> .codex/ + CODEX.md"
    Write-Host "  qwen         -> .qwen/"
    Write-Host "  antigravity  -> .agent/"
    Write-Host "  amazonq      -> .amazonq/"
    Write-Host "  vscode       -> .github/copilot-instructions.md"
    Write-Host "  all          -> todos los anteriores"
    exit 0
}

function Copy-OrLink {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path $Source)) { return }

    # Limpiar destino previo
    if (Test-Path $Destination) {
        Remove-Item -Recurse -Force $Destination
    }

    if ($Symlink) {
        $resolvedSource = (Resolve-Path $Source).Path
        New-Item -ItemType SymbolicLink -Path $Destination -Target $resolvedSource | Out-Null
    } else {
        Copy-Item -Recurse -Force $Source $Destination
    }
}

function New-RootFile {
    param([string]$Editor)

    if (-not $RootFiles.ContainsKey($Editor)) { return }
    if (-not (Test-Path "AGENTS.md")) { return }

    $rootFile = $RootFiles[$Editor]

    if ($Editor -eq "claude") {
        "@AGENTS.md" | Set-Content $rootFile -Encoding UTF8
        Write-Host "  ✓ $rootFile (import @AGENTS.md)"
    } else {
        Copy-Item "AGENTS.md" $rootFile -Force
        Write-Host "  ✓ $rootFile (desde AGENTS.md)"
    }
}

function Invoke-MirrorEditor {
    param([string]$Editor)

    if ($Editor -eq "vscode") {
        if (-not (Test-Path ".github")) {
            New-Item -ItemType Directory -Path ".github" -Force | Out-Null
        }
        if (-not (Test-Path ".github/copilot-instructions.md")) {
            "Lee y seguí las instrucciones de AGENTS.md en la raíz del proyecto." | Set-Content ".github/copilot-instructions.md" -Encoding UTF8
            Write-Host "  ✓ .github/copilot-instructions.md creado"
        } else {
            Write-Host "  ℹ .github/copilot-instructions.md ya existe"
        }
        return
    }

    if (-not $EditorConfig.ContainsKey($Editor)) {
        Write-Host "  ⚠ Editor desconocido: $Editor"
        return
    }

    $config = $EditorConfig[$Editor]
    $targetDir = $config.TargetDir
    $skillsDir = $config.SkillsDir
    $commandsDir = $config.CommandsDir

    Write-Host "[mirror] $Editor -> $targetDir/"

    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    if (Test-Path "$AgentsDir/skills") {
        Copy-OrLink -Source "$AgentsDir/skills" -Destination "$targetDir/$skillsDir"
        $modeLabel = if ($Symlink) { "symlink" } else { "copia" }
        Write-Host "  ✓ skills ($modeLabel)"
    }

    if ($commandsDir -and (Test-Path "$AgentsDir/commands")) {
        Copy-OrLink -Source "$AgentsDir/commands" -Destination "$targetDir/$commandsDir"
        $modeLabel = if ($Symlink) { "symlink" } else { "copia" }
        Write-Host "  ✓ commands ($modeLabel)"
    }

    # Generar archivo raíz si corresponde
    New-RootFile -Editor $Editor
}

# --- Main ---

if ($Help -or $Editors.Count -eq 0) { Show-Usage }

if (-not (Test-Path $AgentsDir)) {
    Write-Host "[error] No se encontró $AgentsDir/"
    exit 1
}

if ($Editors[0] -eq "all") {
    $Editors = $AllEditors
}

foreach ($editor in $Editors) {
    Invoke-MirrorEditor -Editor $editor
}

Write-Host ""
Write-Host "[done] Mirrors generados."
