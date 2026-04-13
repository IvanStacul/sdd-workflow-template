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
    echo "  --symlink    Usar symlinks en lugar de copias para skills/"
    echo "               (commands/ siempre se transforma, nunca se enlaza)"
    echo ""
    echo "Editores soportados:"
    echo "  cursor       → .cursor/ (lee AGENTS.md directo)"
    echo "  claude       → .claude/ + CLAUDE.md (import @AGENTS.md)"
    echo "  opencode     → .opencode/ (directorio command/ singular)"
    echo "  gemini       → .gemini/ + GEMINI.md | commands como .toml"
    echo "  codex        → .codex/ + CODEX.md (solo skills)"
    echo "  qwen         → .qwen/ | commands como .toml"
    echo "  antigravity  → .agent/ (workflows/)"
    echo "  amazonq      → .amazonq/ (solo skills)"
    echo "  vscode       → .github/prompts/ (solo .prompt.md, sin copilot-instructions.md)"
    echo "  all          → todos los anteriores"
    exit 1
}

# ---------------------------------------------------------------------------
# Extrae el valor de una clave del frontmatter YAML de un archivo .md
# Uso: get_frontmatter_value <archivo> <clave>
# ---------------------------------------------------------------------------
get_frontmatter_value() {
    local file="$1"
    local key="$2"
    # Extrae líneas entre los dos --- del frontmatter y busca la clave
    awk '/^---$/{f++; next} f==1 && /^'"$key"':/{
        sub(/^'"$key"':[[:space:]]*/, "")
        gsub(/^["'"'"']|["'"'"']$/, "")
        print; exit
    }' "$file"
}

# ---------------------------------------------------------------------------
# Extrae el body de un .md (todo lo que está después del bloque frontmatter)
# Si no hay frontmatter, devuelve el archivo completo.
# Uso: get_body <archivo>
# ---------------------------------------------------------------------------
get_body() {
    local file="$1"
    awk 'BEGIN{f=0; d=0}
         /^---$/ && d==0 { d++; f=1; next }
         /^---$/ && d==1 { d++; f=0; next }
         d>=2 || d==0 && f==0 { print }
    ' "$file"
}

# ---------------------------------------------------------------------------
# Transforma un archivo .md fuente al formato nativo del editor destino
# y lo escribe en el path indicado.
#
# Uso: transform_command <source_file> <dest_dir> <editor>
#
# source_file: path al .md fuente (ej. .agents/commands/sdd/apply.md)
# dest_dir:    directorio raíz de commands del editor (ej. .cursor/commands)
# editor:      nombre del editor (cursor|claude|opencode|gemini|qwen|antigravity|vscode)
# ---------------------------------------------------------------------------
transform_command() {
    local source_file="$1"
    local dest_dir="$2"
    local editor="$3"

    # Obtener metadata del .md fuente
    local name description body rel_path
    name=$(get_frontmatter_value "$source_file" "name")
    description=$(get_frontmatter_value "$source_file" "description")
    body=$(get_body "$source_file")

    # Path relativo del archivo dentro de commands/ (ej. sdd/apply.md)
    rel_path="${source_file#${AGENTS_DIR}/commands/}"
    local base_noext="${rel_path%.md}"           # ej. sdd/apply
    local slug="${base_noext//\//-}"             # ej. sdd-apply

    case "$editor" in
        # ----------------------------------------------------------------
        # TOML — Gemini y Qwen
        # ----------------------------------------------------------------
        gemini|qwen)
            local dest_file="${dest_dir}/${base_noext}.toml"
            mkdir -p "$(dirname "$dest_file")"
            {
                echo "description = \"${description}\""
                echo ""
                echo "prompt = \"\"\""
                echo "${body}"
                echo "\"\"\""
            } > "$dest_file"
            ;;

        # ----------------------------------------------------------------
        # .prompt.md — GitHub / VSCode
        # El nombre de archivo es el path aplanado con guiones
        # ----------------------------------------------------------------
        vscode)
            local dest_file="${dest_dir}/${slug}.prompt.md"
            mkdir -p "$(dirname "$dest_file")"
            {
                echo "---"
                echo "description: ${description}"
                echo "---"
                echo ""
                echo "${body}"
            } > "$dest_file"
            ;;

        # ----------------------------------------------------------------
        # .md enriquecido — Cursor
        # Agrega name (/sdd-slug), id, category al frontmatter
        # ----------------------------------------------------------------
        cursor)
            local dest_file="${dest_dir}/${rel_path}"
            mkdir -p "$(dirname "$dest_file")"
            {
                echo "---"
                echo "name: /${slug}"
                echo "id: ${slug}"
                echo "category: Workflow"
                echo "description: ${description}"
                echo "---"
                echo ""
                echo "${body}"
            } > "$dest_file"
            ;;

        # ----------------------------------------------------------------
        # .md con category + tags — Claude
        # ----------------------------------------------------------------
        claude)
            local dest_file="${dest_dir}/${rel_path}"
            mkdir -p "$(dirname "$dest_file")"
            {
                echo "---"
                echo "name: \"${name}\""
                echo "description: ${description}"
                echo "category: Workflow"
                echo "tags: [workflow, sdd]"
                echo "---"
                echo ""
                echo "${body}"
            } > "$dest_file"
            ;;

        # ----------------------------------------------------------------
        # .md con solo description — OpenCode
        # ----------------------------------------------------------------
        opencode)
            local dest_file="${dest_dir}/${rel_path}"
            mkdir -p "$(dirname "$dest_file")"
            {
                echo "---"
                echo "description: ${description}"
                echo "---"
                echo ""
                echo "${body}"
            } > "$dest_file"
            ;;

        # ----------------------------------------------------------------
        # .md passthrough — Antigravity (workflows/)
        # Copia el archivo fuente sin modificar
        # ----------------------------------------------------------------
        antigravity)
            local dest_file="${dest_dir}/${rel_path}"
            mkdir -p "$(dirname "$dest_file")"
            cp "$source_file" "$dest_file"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# Itera sobre todos los .md de .agents/commands/ y los transforma
# Uso: mirror_commands <dest_commands_dir> <editor>
# ---------------------------------------------------------------------------
mirror_commands() {
    local dest_dir="$1"
    local editor="$2"

    rm -rf "$dest_dir"

    if [ ! -d "${AGENTS_DIR}/commands" ]; then return; fi

    while IFS= read -r -d '' file; do
        transform_command "$file" "$dest_dir" "$editor"
    done < <(find "${AGENTS_DIR}/commands" -name "*.md" -print0)

    echo "  ✓ commands (transformados para $editor)"
}

# ---------------------------------------------------------------------------
# Root files
# ---------------------------------------------------------------------------
root_file_for_editor() {
    local editor="$1"
    case "$editor" in
        claude)  echo "CLAUDE.md" ;;
        gemini)  echo "GEMINI.md" ;;
        codex)   echo "CODEX.md" ;;
        *)       echo "" ;;
    esac
}

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

# ---------------------------------------------------------------------------
# Copia o enlaza el directorio de skills
# ---------------------------------------------------------------------------
mirror_dir() {
    local src="$1"
    local dest="$2"

    if [ ! -d "$src" ]; then return; fi

    rm -rf "$dest"

    if [ "$USE_SYMLINK" = "true" ]; then
        local dest_parent src_abs rel_path
        dest_parent=$(dirname "$dest")
        src_abs=$(cd "$src" && pwd)
        rel_path=$(python3 -c "import os.path; print(os.path.relpath('$src_abs', os.path.abspath('$dest_parent')))" 2>/dev/null || echo "$src_abs")
        ln -s "$rel_path" "$dest"
    else
        cp -r "$src" "$dest"
    fi
}

# ---------------------------------------------------------------------------
# Lógica principal por editor
# ---------------------------------------------------------------------------
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
            echo "[mirror] vscode → .github/"
            mkdir -p .github
            # Limpiar prompts/ y skills/ antes de regenerar [CMD-CLEAN, CMD-GITHUB-SKILLS-CLEAN]
            rm -rf .github/prompts .github/skills
            mkdir -p .github/prompts
            # Transformar commands a .prompt.md [CMD-COPY-COMMANDS]
            if [ -d "${AGENTS_DIR}/commands" ]; then
                while IFS= read -r -d '' file; do
                    transform_command "$file" ".github/prompts" "vscode"
                done < <(find "${AGENTS_DIR}/commands" -name "*.md" -print0)
                echo "  ✓ prompts/ (.prompt.md generados)"
            fi
            # NO generar copilot-instructions.md [CMD-GITHUB-NO-INSTRUCTIONS]
            return
            ;;

        *)
            echo "  ⚠ Editor desconocido: $editor"
            return 1
            ;;
    esac

    echo "[mirror] $editor → $target_dir/"
    mkdir -p "$target_dir"

    # Skills — copia/symlink directa [CMD-COPY-SKILLS]
    if [ -d "${AGENTS_DIR}/skills" ]; then
        mirror_dir "${AGENTS_DIR}/skills" "${target_dir}/${skills_dir}"
        local mode_label="copia"
        [ "$USE_SYMLINK" = "true" ] && mode_label="symlink"
        echo "  ✓ skills ($mode_label)"
    fi

    # Commands — transformación por editor [CMD-COPY-COMMANDS]
    if [ -n "$commands_dir" ] && [ -d "${AGENTS_DIR}/commands" ]; then
        mirror_commands "${target_dir}/${commands_dir}" "$editor"
    fi

    # Root file [CMD-ROOT-FILES]
    generate_root_file "$editor"
}

# ---------------------------------------------------------------------------
# Parse args
# ---------------------------------------------------------------------------

if [ $# -eq 0 ]; then usage; fi

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
