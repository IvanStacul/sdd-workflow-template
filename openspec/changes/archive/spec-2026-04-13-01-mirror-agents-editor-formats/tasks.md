# Tareas - spec-2026-04-13-01-mirror-agents-editor-formats

> **Specs**: [specs/](./specs/)

## Convenciones

- **Estados**: `[ ]` pendiente · `[~]` en progreso · `[x]` completada
- **Refs**: cada tarea referencia el requirement que implementa

---

## PHASE 1 - Función de transformación de formato

> Extraer la lógica de transformación `.md → formato-editor` como función reutilizable en ambos scripts. Se usa en 5+ editores con variantes, por lo que justifica una función dedicada (abstraction-guide: lógica idéntica en 2+ lugares).

- [x] 1.1 Implementar función `transform_command` en `mirror-agents.sh` que acepta `(source_file, editor)` y escribe el archivo transformado en el destino `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`
  - **Depende de**: -
  - **Criterio**: la función extrae frontmatter (`name`, `description`) y body del `.md` fuente; aplica el wrapper correcto según editor; escribe el archivo con extensión adecuada en el path destino

- [x] 1.2 Implementar función `Transform-Command` en `mirror-agents.ps1` con la misma lógica que 1.1 `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: -
  - **Criterio**: misma firma y comportamiento que 1.1; funciona en PowerShell sin dependencias externas

---

## PHASE 2 - Wrappers por editor

> Implementar el wrapper específico de cada formato dentro de la función de transformación.

- [x] 2.1 Wrapper TOML para Gemini y Qwen: generar `description = "..."` y `prompt = """..."""` `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: un archivo `.md` de `.agents/commands/sdd/apply.md` produce un `.toml` válido en `.gemini/commands/sdd/apply.toml` y `.qwen/commands/sdd/apply.toml`; el body está completo dentro de `prompt = """`

- [x] 2.2 Wrapper `.prompt.md` para GitHub/VSCode: generar frontmatter con solo `description:` y body sin cambios `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: un archivo `.agents/commands/sdd/apply.md` produce `.github/prompts/sdd-apply.prompt.md` con frontmatter `description:` y body completo; el nombre de archivo usa el path relativo aplanado con `-` (ej. `sdd/apply.md` → `sdd-apply.prompt.md`)

- [x] 2.3 Wrapper Cursor: enriquecer frontmatter con `name: /sdd-{cmd}`, `id: sdd-{cmd}`, `category: Workflow` `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: `.cursor/commands/sdd/apply.md` tiene frontmatter con `name`, `id`, `category` y `description`; el `id` se deriva del subdirectorio + nombre (ej. `sdd-apply`)

- [x] 2.4 Wrapper Claude: agregar `category: Workflow` y `tags: [workflow, sdd]` al frontmatter existente `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: `.claude/commands/sdd/apply.md` tiene `name`, `description`, `category` y `tags` en el frontmatter

- [x] 2.5 Wrapper OpenCode: solo `description:` en frontmatter, directorio destino singular `command/` `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: `.opencode/command/sdd/apply.md` contiene solo `description:` en frontmatter y body completo

- [x] 2.6 Wrapper Antigravity (passthrough): copiar `.md` con frontmatter mínimo sin transformación `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: `.agent/workflows/sdd/apply.md` tiene el mismo contenido que el fuente, sin modificación

---

## PHASE 3 - Limpieza y comportamiento especial de GitHub

- [x] 3.1 Actualizar el bloque `vscode` en ambos scripts: borrar `prompts/` y `skills/` antes de regenerar; no crear `copilot-instructions.md` `[CMD-CLEAN, CMD-GITHUB-NO-INSTRUCTIONS, CMD-GITHUB-SKILLS-CLEAN]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 2.2
  - **Criterio**: después de correr el script con `vscode`, `.github/prompts/` contiene los `.prompt.md` generados; `.github/skills/` no existe; `.github/copilot-instructions.md` no es creado si no existía previamente

- [x] 3.2 Reemplazar la lógica de copia naïve de `commands/` por llamadas a `transform_command` en el loop principal de `mirror_editor` / `Invoke-MirrorEditor` `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.agents/skills/sdd-init/scripts/mirror-agents.sh`, `.agents/skills/sdd-init/scripts/mirror-agents.ps1`
  - **Depende de**: 1.1, 1.2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6
  - **Criterio**: el script no usa `cp -r` / `Copy-Item -Recurse` para el directorio de commands; en su lugar itera archivos `.md` y llama a `transform_command` por cada uno

---

## PHASE 4 - Verificación manual

- [x] 4.1 Correr el script completo con el editor `gemini` y verificar que los `.toml` son válidos `[CMD-COPY-COMMANDS]`
  - **Archivos**: `.gemini/commands/`
  - **Depende de**: 3.2
  - **Criterio**: todos los archivos en `.gemini/commands/sdd/` tienen extensión `.toml`; se puede abrir uno y confirmar `description = "..."` y `prompt = """..."""` con body completo

- [x] 4.2 Correr el script con el editor `vscode` y verificar comportamiento de GitHub `[CMD-CLEAN, CMD-GITHUB-NO-INSTRUCTIONS, CMD-GITHUB-SKILLS-CLEAN]`
  - **Archivos**: `.github/prompts/`
  - **Depende de**: 3.1, 3.2
  - **Criterio**: `.github/prompts/` contiene archivos `sdd-*.prompt.md`; `.github/skills/` no existe; `.github/copilot-instructions.md` intacto si ya existía (o ausente si no existía)

- [x] 4.3 Correr el script con `all` y verificar que los mirrors del resto de editores siguen funcionando `[CMD-COPY-COMMANDS, CMD-ROOT-FILES]`
  - **Archivos**: `.cursor/`, `.claude/`, `.opencode/`, `.qwen/`, `.agent/`
  - **Depende de**: 3.2
  - **Criterio**: cada directorio de editor tiene su `commands/sdd/` con el formato correcto; `CLAUDE.md` contiene `@AGENTS.md`; `GEMINI.md` es copia de `AGENTS.md`
