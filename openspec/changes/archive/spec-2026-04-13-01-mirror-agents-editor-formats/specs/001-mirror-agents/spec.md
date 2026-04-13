# Mirror Agents Script

**Namespace**: -

## Purpose

Describe el comportamiento del script `mirror-agents` (disponible en `.sh` y `.ps1`): cómo propaga la fuente de verdad de `.agents/` a los directorios de cada editor, qué formatos genera por editor y cómo limpia los targets antes de copiar.

## Requirements

### Requirement: CMD-CLEAN — Limpieza previa antes de copiar

El script MUST eliminar el directorio `skills/` y el directorio `commands/` (o su equivalente por editor) del target antes de regenerarlos. Esto garantiza que archivos eliminados de la fuente no persistan en el mirror.

Para el editor `github/vscode`, el script MUST eliminar `prompts/` y `skills/` dentro de `.github/` antes de regenerar. No MUST eliminar otras carpetas de `.github/` (ej. workflows).

#### Scenario: Limpieza de skills en cursor

- GIVEN que `.cursor/skills/` existe con archivos previos
- WHEN el script corre con el editor `cursor`
- THEN `.cursor/skills/` es eliminada y recreada con el contenido actual de `.agents/skills/`

#### Scenario: Limpieza de prompts en github

- GIVEN que `.github/prompts/` existe con archivos previos
- WHEN el script corre con el editor `vscode`
- THEN `.github/prompts/` y `.github/skills/` son eliminadas; `.github/prompts/` es recreada con los comandos transformados

---

### Requirement: CMD-COPY-SKILLS — Copia de skills sin transformación

El script MUST copiar `.agents/skills/` al directorio de skills del editor destino sin transformar el formato. La estructura de carpetas y archivos se preserva tal cual.

Todos los editores reciben una copia de skills EXCEPTO `vscode`, que solo recibe commands (como `.prompt.md` en `.github/prompts/`). `codex` y `amazonq` reciben skills pero no commands.

#### Scenario: Skills copiadas a cursor

- GIVEN que `.agents/skills/sdd-apply/SKILL.md` existe
- WHEN el script corre con el editor `cursor`
- THEN `.cursor/skills/sdd-apply/SKILL.md` existe con el mismo contenido

#### Scenario: Codex recibe skills pero no commands

- GIVEN que `.agents/skills/` y `.agents/commands/` existen
- WHEN el script corre con el editor `codex`
- THEN `.codex/skills/` es una copia de `.agents/skills/`; no se crea ningún directorio de commands en `.codex/`

---

### Requirement: CMD-COPY-COMMANDS — Copia de commands con transformación por editor

El script MUST copiar `.agents/commands/` al directorio de commands del editor transformando el formato del archivo según la convención del editor.

El directorio de commands varía por editor:

| Editor | Directorio | Formato |
|--------|-----------|---------|
| cursor | `commands/` | `.md` con frontmatter enriquecido (`name`, `id`, `category`, `description`) |
| claude | `commands/` | `.md` con frontmatter estándar (`name`, `description`, `category`, `tags`) |
| opencode | `command/` (singular) | `.md` con solo `description:` en frontmatter |
| gemini | `commands/` | `.toml` con `description` y `prompt = """..."""` |
| qwen | `commands/` | `.toml` con `description` y `prompt = """..."""` |
| antigravity | `workflows/` | `.md` con frontmatter mínimo (sin transformación) |
| github/vscode | `prompts/` | `.prompt.md` con solo `description:` en frontmatter |

#### Scenario: Comando copiado a gemini como TOML

- GIVEN que `.agents/commands/sdd/apply.md` existe con frontmatter `name` y `description` y un body de markdown
- WHEN el script corre con el editor `gemini`
- THEN `.gemini/commands/sdd/apply.toml` existe con la estructura:
  ```
  description = "..."
  
  prompt = """
  {body del .md sin el bloque de frontmatter}
  """
  ```

#### Scenario: Comando copiado a github como .prompt.md

- GIVEN que `.agents/commands/sdd/apply.md` existe con frontmatter `name` y `description`
- WHEN el script corre con el editor `vscode`
- THEN `.github/prompts/sdd-apply.prompt.md` existe con la estructura:
  ```
  ---
  description: ...
  ---
  
  {body del .md sin el bloque de frontmatter}
  ```

#### Scenario: Comando copiado a cursor con frontmatter enriquecido

- GIVEN que `.agents/commands/sdd/apply.md` existe con frontmatter `name: "SDD: Apply"` y `description: "..."`
- WHEN el script corre con el editor `cursor`
- THEN `.cursor/commands/sdd/apply.md` existe con frontmatter que incluye al menos `name`, `id`, `category` y `description`; el `id` se deriva del subdirectorio y nombre del archivo (ej. `sdd-apply`)

#### Scenario: Comando copiado a opencode con directorio singular

- GIVEN que `.agents/commands/sdd/apply.md` existe
- WHEN el script corre con el editor `opencode`
- THEN `.opencode/command/sdd/apply.md` existe (carpeta singular `command`, no `commands`)

---

### Requirement: CMD-GITHUB-NO-INSTRUCTIONS — GitHub no genera copilot-instructions.md

El script MUST NOT crear ni sobrescribir `.github/copilot-instructions.md` al correr con el editor `vscode`.

#### Scenario: copilot-instructions.md no se genera

- GIVEN que `.github/copilot-instructions.md` no existe
- WHEN el script corre con el editor `vscode`
- THEN `.github/copilot-instructions.md` no es creado

#### Scenario: copilot-instructions.md existente se preserva

- GIVEN que `.github/copilot-instructions.md` ya existe con contenido
- WHEN el script corre con el editor `vscode`
- THEN `.github/copilot-instructions.md` queda intacto

---

### Requirement: CMD-ROOT-FILES — Archivos raíz por editor

El script MUST generar el archivo raíz del editor cuando corresponda y AGENTS.md exista:

- `claude` → `CLAUDE.md` con contenido `@AGENTS.md` (import syntax)
- `gemini` → `GEMINI.md` con copia del contenido de `AGENTS.md`
- `codex` → `CODEX.md` con copia del contenido de `AGENTS.md`

Los demás editores no tienen archivo raíz generado por el script.

#### Scenario: Claude genera CLAUDE.md con import

- GIVEN que `AGENTS.md` existe en la raíz del proyecto
- WHEN el script corre con el editor `claude`
- THEN `CLAUDE.md` es creado (o sobrescrito) con el contenido `@AGENTS.md`

#### Scenario: Gemini genera GEMINI.md con copia

- GIVEN que `AGENTS.md` existe en la raíz del proyecto
- WHEN el script corre con el editor `gemini`
- THEN `GEMINI.md` es creado (o sobrescrito) con el mismo contenido de `AGENTS.md`

---

### Requirement: CMD-GITHUB-SKILLS-CLEAN — GitHub no regenera skills/

El script MUST eliminar `.github/skills/` si existe y MUST NOT recrearla. GitHub Copilot no tiene un sistema de skills nativo equivalente al de los demás editores.

#### Scenario: .github/skills/ es eliminada y no recreada

- GIVEN que `.github/skills/` existe
- WHEN el script corre con el editor `vscode`
- THEN `.github/skills/` es eliminada y no vuelve a crearse

## Edge Cases

| Caso | Comportamiento Esperado | Req Relacionado |
|------|-------------------------|-----------------| 
| `.agents/skills/` no existe | El paso de copia de skills se omite sin error; el resto del proceso continúa | CMD-COPY-SKILLS |
| `.agents/commands/` no existe | El paso de copia de commands se omite sin error | CMD-COPY-COMMANDS |
| Un archivo `.md` no tiene bloque frontmatter | El body es todo el archivo; `description` queda vacío en el output transformado | CMD-COPY-COMMANDS |
| El body del comando contiene `"""` (triple comilla) | En formato TOML, las comillas triples deben escaparse o el body debe envolverse en string alternativo | CMD-COPY-COMMANDS |
| `AGENTS.md` no existe al generar root files | El paso de root file se omite silenciosamente | CMD-ROOT-FILES |
| El directorio target no existe | El script lo crea con `mkdir -p` (o equivalente) antes de copiar | CMD-CLEAN |
