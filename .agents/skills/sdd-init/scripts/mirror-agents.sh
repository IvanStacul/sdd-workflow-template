#!/usr/bin/env bash
set -euo pipefail

# mirror-agents.sh — Genera copias (o symlinks) de .agents/ para editores específicos
#
# Uso:
#   bash .agents/skills/sdd-init/scripts/mirror-agents.sh cursor claude opencode
#   bash .agents/skills/sdd-init/scripts/mirror-agents.sh --symlink cursor claude
#   bash .agents/skills/sdd-init/scripts/mirror-agents.sh all

AGENTS_DIR=".agents"
USE_SYMLINK="false"

usage() {
    echo "Uso: $0 [--symlink] <editor1> [editor2] ..."
    echo ""
    echo "Opciones:"
    echo "  --symlink    Usar symlinks en lugar de copias para skills/ y commands/"
    echo "               (los root files siempre se copian)"
    echo ""
    echo "Editores soportados:"
    echo "  cursor       → .cursor/ (lee AGENTS.md directo)"
    echo "  claude       → .claude/ + CLAUDE.md (import @AGENTS.md)"
    echo "  opencode     → .opencode/"
    echo "  gemini       → .gemini/ + GEMINI.md (si AGENTS.md existe)"
    echo "  codex        → .codex/ + CODEX.md (si AGENTS.md existe)"
    echo "  qwen         → .qwen/"
    echo "  antigravity  → .agent/"
    echo "  amazonq      → .amazonq/"
    echo "  vscode       → .github/copilot-instructions.md"
    echo "  all          → todos los anteriores"
    exit 1
}

# Mapa de editores a sus archivos raíz.
# Solo los editores que leen un archivo raíz .md tienen entrada aquí.
# Nota: Cursor lee AGENTS.md directamente, no necesita root file.
root_file_for_editor() {
    local editor="$1"
    case "$editor" in
        claude)  echo "CLAUDE.md" ;;
        gemini)  echo "GEMINI.md" ;;
        codex)   echo "CODEX.md" ;;
        *)       echo "" ;;
    esac
}

# Genera el archivo raíz para un editor.
# Claude usa import syntax (@AGENTS.md); el resto copia contenido.
generate_root_file() {
    local editor="$1"
    local root_file
    root_file=$(root_file_for_editor "$editor")

    if [ -z "$root_file" ]; then return; fi
    if [ ! -f "AGENTS.md" ]; then return; fi

    if [ "$editor" = "claude" ]; then
        echo "@AGENTS.md" > "$root_file"
        echo "  ✓ $root_file (import @AGENTS.md)"
    else
        cp "AGENTS.md" "$root_file"
        echo "  ✓ $root_file (desde AGENTS.md)"
    fi
}

# Copia o enlaza un directorio según el modo.
mirror_dir() {
    local src="$1"
    local dest="$2"

    if [ ! -d "$src" ]; then return; fi

    # Limpiar destino previo (sea copia o symlink)
    rm -rf "$dest"

    if [ "$USE_SYMLINK" = "true" ]; then
        # Symlink relativo desde el directorio padre del destino
        local dest_parent dest_name src_abs
        dest_parent=$(dirname "$dest")
        dest_name=$(basename "$dest")
        src_abs=$(cd "$src" && pwd)
        local rel_path
        rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_abs', os.path.abspath('$dest_parent')))" 2>/dev/null || echo "$src_abs")
        ln -s "$rel_path" "$dest"
    else
        cp -r "$src" "$dest"
    fi
}

mirror_editor() {
    local editor="$1"
    local target_dir skills_dir commands_dir

    case "$editor" in
        cursor)      target_dir=".cursor";   skills_dir="skills"; commands_dir="commands" ;;
        claude)      target_dir=".claude";   skills_dir="skills"; commands_dir="commands" ;;
        opencode)    target_dir=".opencode"; skills_dir="skills"; commands_dir="command" ;;
        gemini)      target_dir=".gemini";   skills_dir="skills"; commands_dir="commands" ;;
        codex)       target_dir=".codex";    skills_dir="skills"; commands_dir="" ;;
        qwen)        target_dir=".qwen";     skills_dir="skills"; commands_dir="commands" ;;
        antigravity) target_dir=".agent";    skills_dir="skills"; commands_dir="workflows" ;;
        amazonq)     target_dir=".amazonq";  skills_dir="skills"; commands_dir="" ;;
        vscode)
            mkdir -p .github
            if [ ! -f ".github/copilot-instructions.md" ]; then
                echo "Lee y seguí las instrucciones de AGENTS.md en la raíz del proyecto." > .github/copilot-instructions.md
                echo "  ✓ .github/copilot-instructions.md creado"
            else
                echo "  ℹ .github/copilot-instructions.md ya existe"
            fi
            return
            ;;
        *)
            echo "  ⚠ Editor desconocido: $editor"
            return 1
            ;;
    esac

    echo "[mirror] $editor → $target_dir/"
    mkdir -p "$target_dir"

    if [ -d "${AGENTS_DIR}/skills" ]; then
        mirror_dir "${AGENTS_DIR}/skills" "${target_dir}/${skills_dir}"
        local mode_label="copia"
        [ "$USE_SYMLINK" = "true" ] && mode_label="symlink"
        echo "  ✓ skills ($mode_label)"
    fi

    if [ -n "$commands_dir" ] && [ -d "${AGENTS_DIR}/commands" ]; then
        mirror_dir "${AGENTS_DIR}/commands" "${target_dir}/${commands_dir}"
        local mode_label="copia"
        [ "$USE_SYMLINK" = "true" ] && mode_label="symlink"
        echo "  ✓ commands ($mode_label)"
    fi

    # Generar archivo raíz si corresponde
    generate_root_file "$editor"
}

# --- Parse args ---

if [ $# -eq 0 ]; then usage; fi

# Extraer flags antes de los editores
editors=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --symlink) USE_SYMLINK="true"; shift ;;
        --help|-h) usage ;;
        *) editors+=("$1"); shift ;;
    esac
done

if [ ${#editors[@]} -eq 0 ]; then usage; fi
if [ ! -d "$AGENTS_DIR" ]; then
    echo "[error] No se encontró ${AGENTS_DIR}/"
    exit 1
fi

[[ "${editors[0]}" == "all" ]] && editors=(cursor claude opencode gemini codex qwen antigravity amazonq vscode)

for editor in "${editors[@]}"; do
    mirror_editor "$editor"
done

echo ""
echo "[done] Mirrors generados."
