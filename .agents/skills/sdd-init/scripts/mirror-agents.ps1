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
    Usar symlinks en lugar de copias para skills/.
    Los commands siempre se transforman.

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

$RootFiles = @{
    claude = "CLAUDE.md"
    gemini = "GEMINI.md"
    codex  = "CODEX.md"
}

function Show-Usage {
    Write-Host "Uso: .\mirror-agents.ps1 [-Symlink] <editor1> [editor2] ..."
    Write-Host ""
    Write-Host "Opciones:"
    Write-Host "  -Symlink     Usar symlinks en lugar de copias para skills/"
    Write-Host "               (commands/ siempre se transforma, nunca se enlaza)"
    Write-Host ""
    Write-Host "Editores soportados:"
    Write-Host "  cursor       -> .cursor/ (lee AGENTS.md directo)"
    Write-Host "  claude       -> .claude/ + CLAUDE.md (import @AGENTS.md)"
    Write-Host "  opencode     -> .opencode/"
    Write-Host "  gemini       -> .gemini/ + GEMINI.md | commands como .toml"
    Write-Host "  codex        -> .codex/ + CODEX.md (solo skills)"
    Write-Host "  qwen         -> .qwen/ | commands como .toml"
    Write-Host "  antigravity  -> .agent/"
    Write-Host "  amazonq      -> .amazonq/"
    Write-Host "  vscode       -> .github/prompts/ (solo .prompt.md)"
    Write-Host "  all          -> todos los anteriores"
    exit 0
}

function Copy-OrLink {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path $Source)) { return }
    if (Test-Path $Destination) { Remove-Item -Recurse -Force $Destination }
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
        Write-Host "  [OK] $rootFile (import `@AGENTS.md)"
    } else {
        Copy-Item "AGENTS.md" $rootFile -Force
        Write-Host "  [OK] $rootFile (desde AGENTS.md)"
    }
}

function Get-FrontmatterValue {
    param([string]$Content, [string]$Key)
    if ($Content -match "(?s)^---\r?\n(.*?)\r?\n---\r?\n") {
        $fm = $Matches[1]
        $regex = '(?m)^' + [regex]::Escape($Key) + ':\s*"?([^"\r\n]+)"?\s*$'
        if ($fm -match $regex) {
            return $Matches[1].Trim()
        }
    }
    return ""
}

function Get-Body {
    param([string]$Content)
    if ($Content -match "(?s)^---\r?\n.*?\r?\n---\r?\n(.*)") {
        return $Matches[1].TrimStart()
    }
    return $Content
}

function Transform-Command {
    param([string]$SourceFile, [string]$DestDir, [string]$Editor)

    $content = Get-Content $SourceFile -Raw -Encoding UTF8
    $name = Get-FrontmatterValue -Content $content -Key "name"
    $description = Get-FrontmatterValue -Content $content -Key "description"
    $body = Get-Body -Content $content

    $relPath = (Resolve-Path -Relative $SourceFile).Replace("$AgentsDir\commands\", "").Replace("\", "/")
    if ($relPath.StartsWith("./")) { $relPath = $relPath.Substring(2) }
    $baseNoExt = $relPath -replace "(?i)\.md$", ""
    $slug = $baseNoExt -replace "/", "-"

    $destPath = ""
    $outContent = ""
    $q = '"'

    switch ($Editor) {
        { $_ -in "gemini", "qwen" } {
            $destPath = Join-Path $DestDir "$baseNoExt.toml"
            $outContent = "description = $q$description$q`n`nprompt = $q$q$q`n$body`n$q$q$q"
        }
        "vscode" {
            $destPath = Join-Path $DestDir "$slug.prompt.md"
            $outContent = "---`ndescription: $description`n---`n`n$body"
        }
        "cursor" {
            $destPath = Join-Path $DestDir $relPath
            $outContent = "---`nname: /$slug`nid: $slug`ncategory: Workflow`ndescription: $description`n---`n`n$body"
        }
        "claude" {
            $destPath = Join-Path $DestDir $relPath
            $outContent = "---`nname: $q$name$q`ndescription: $description`ncategory: Workflow`ntags: [workflow, sdd]`n---`n`n$body"
        }
        "opencode" {
            $destPath = Join-Path $DestDir $relPath
            $outContent = "---`ndescription: $description`n---`n`n$body"
        }
        "antigravity" {
            $destPath = Join-Path $DestDir $relPath
            $outContent = $content
        }
    }

    if ($destPath) {
        $parent = Split-Path $destPath -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        $outContent | Set-Content $destPath -Encoding UTF8 -NoNewline
        Add-Content $destPath "`n" -NoNewline
    }
}

function Invoke-MirrorCommands {
    param([string]$DestDir, [string]$Editor)
    
    if (Test-Path $DestDir) { Remove-Item -Recurse -Force $DestDir }
    if (-not (Test-Path "$AgentsDir/commands")) { return }

    $files = Get-ChildItem -Path "$AgentsDir/commands" -Filter "*.md" -Recurse -File
    foreach ($file in $files) {
        Transform-Command -SourceFile $file.FullName -DestDir $DestDir -Editor $Editor
    }
    Write-Host "  [OK] commands (transformados para $Editor)"
}

function Invoke-MirrorEditor {
    param([string]$Editor)

    if ($Editor -eq "vscode") {
        Write-Host "[mirror] vscode -> .github/"
        if (-not (Test-Path ".github")) { New-Item -ItemType Directory -Path ".github" -Force | Out-Null }
        
        # Limpiar prompts y skills
        if (Test-Path ".github/prompts") { Remove-Item -Recurse -Force ".github/prompts" }
        if (Test-Path ".github/skills") { Remove-Item -Recurse -Force ".github/skills" }
        
        New-Item -ItemType Directory -Path ".github/prompts" -Force | Out-Null
        
        # Transform commands
        if (Test-Path "$AgentsDir/commands") {
            $files = Get-ChildItem -Path "$AgentsDir/commands" -Filter "*.md" -Recurse -File
            foreach ($file in $files) {
                Transform-Command -SourceFile $file.FullName -DestDir ".github/prompts" -Editor "vscode"
            }
            Write-Host "  [OK] prompts/ (.prompt.md generados)"
        }
        return
    }

    if (-not $EditorConfig.ContainsKey($Editor)) {
        Write-Host "  [WARN] Editor desconocido: $Editor"
        return
    }

    $config = $EditorConfig[$Editor]
    $targetDir = $config.TargetDir
    $skillsDir = $config.SkillsDir
    $commandsDir = $config.CommandsDir

    Write-Host "[mirror] $Editor -> $targetDir/"

    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }

    if (Test-Path "$AgentsDir/skills") {
        Copy-OrLink -Source "$AgentsDir/skills" -Destination "$targetDir/$skillsDir"
        $modeLabel = if ($Symlink) { "symlink" } else { "copia" }
        Write-Host "  [OK] skills ($modeLabel)"
    }

    if ($commandsDir -and (Test-Path "$AgentsDir/commands")) {
        Invoke-MirrorCommands -DestDir "$targetDir/$commandsDir" -Editor $Editor
    }

    New-RootFile -Editor $Editor
}

# --- Main ---

if ($Help -or $Editors.Count -eq 0) { Show-Usage }

if (-not (Test-Path $AgentsDir)) {
    Write-Host "[error] No se encontró $AgentsDir/"
    exit 1
}

if ($Editors[0] -eq "all") { $Editors = $AllEditors }

foreach ($editor in $Editors) {
    Invoke-MirrorEditor -Editor $editor
}

Write-Host ""
Write-Host "[done] Mirrors generados."
