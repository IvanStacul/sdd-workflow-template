#!/usr/bin/env bash
set -euo pipefail

# mirror-agents.sh — Genera copias de .agents/ para editores específicos
#
# Uso:
#   bash .agents/skills/sdd-init/scripts/mirror-agents.sh cursor claude opencode
#   bash .agents/skills/sdd-init/scripts/mirror-agents.sh all

AGENTS_DIR=".agents"

usage() {
    echo "Uso: $0 <editor1> [editor2] ..."
    echo ""
    echo "Editores soportados:"
    echo "  cursor       → .cursor/skills/ + .cursor/commands/"
    echo "  claude       → .claude/skills/ + .claude/commands/"
    echo "  opencode     → .opencode/skills/ + .opencode/command/"
    echo "  gemini       → .gemini/skills/ + .gemini/commands/"
    echo "  codex        → .codex/skills/"
    echo "  qwen         → .qwen/skills/ + .qwen/commands/"
    echo "  antigravity  → .agent/skills/ + .agent/workflows/"
    echo "  amazonq      → .amazonq/skills/"
    echo "  vscode       → (solo requiere .github/copilot-instructions.md)"
    echo "  all          → todos los anteriores"
    exit 1
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
        rm -rf "${target_dir:?}/${skills_dir}"
        cp -r "${AGENTS_DIR}/skills" "${target_dir}/${skills_dir}"
        echo "  ✓ skills"
    fi

    if [ -n "$commands_dir" ] && [ -d "${AGENTS_DIR}/commands" ]; then
        rm -rf "${target_dir:?}/${commands_dir}"
        cp -r "${AGENTS_DIR}/commands" "${target_dir}/${commands_dir}"
        echo "  ✓ commands"
    fi
}

if [ $# -eq 0 ]; then usage; fi
if [ ! -d "$AGENTS_DIR" ]; then
    echo "[error] No se encontró ${AGENTS_DIR}/"
    exit 1
fi

editors=("$@")
[[ "${editors[0]}" == "all" ]] && editors=(cursor claude opencode gemini codex qwen antigravity amazonq vscode)

for editor in "${editors[@]}"; do
    mirror_editor "$editor"
done

echo ""
echo "[done] Mirrors generados."
