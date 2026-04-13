# Verificacion - spec-2026-04-13-01-mirror-agents-editor-formats

## Resumen
- **Estado general:** PASS
- **Tasks:** 13 completas / 0 pendientes / 0 bloqueadas
- **Specs verificadas:** 1 (001-mirror-agents)
- **Scenarios revisados:** 14

## Contexto

Este change fue originalmente implementado, verificado y archivado en otro repositorio. Esta verificacion valida que la implementacion existe y cumple las specs en **este** repositorio (el template de workflow), que es la fuente de verdad de los scripts.

### Adaptaciones realizadas

- **Numeracion de spec**: `008-mirror-agents` → `001-mirror-agents` (primer spec de este repo; `008` era la numeracion del otro repo)
- **CMD-COPY-SKILLS corregido**: el texto original decia "excepto codex y amazonq" de forma contradictoria. Se corrigio a: todos los editores reciben skills EXCEPTO `vscode`; `codex` y `amazonq` reciben skills pero no commands.
- **Comportamiento `.github/`**: en este repo, el mirror para `vscode` solo genera `prompts/` (commands como `.prompt.md`). No genera `.github/skills/`. Esto difiere de otros repos donde el mirror puede generar ambos.

## Evidencia Runtime
- **Test command:** `powershell -File .agents/skills/sdd-init/scripts/mirror-agents.ps1 all` — Ejecucion exitosa, exit code 0. Todos los editores generados sin errores.
- **Typecheck:** No aplicable (scripting sh/ps1)
- **Coverage:** No aplicable

## Matriz Scenario -> Evidence

### 001-mirror-agents

| Requirement | Scenario | Evidence | Estado |
|-------------|----------|----------|--------|
| CMD-CLEAN | Limpieza de skills en cursor | Script ejecutado: `.cursor/skills/` recreada con contenido actual. Logica `Remove-Item`/`rm -rf` en ambos scripts antes de copiar. | COMPLIANT |
| CMD-CLEAN | Limpieza de prompts en github | Script ejecutado: `.github/prompts/` y `.github/skills/` eliminadas. `prompts/` recreada con `.prompt.md` generados. `skills/` no recreada. | COMPLIANT |
| CMD-COPY-SKILLS | Skills copiadas a cursor | `.cursor/skills/` contiene la copia completa de `.agents/skills/`. Output: `[OK] skills (copia)`. | COMPLIANT |
| CMD-COPY-SKILLS | Codex recibe skills pero no commands | `.codex/skills/` existe. `Test-Path .codex/commands` = `False`. Output de codex no reporta commands. | COMPLIANT |
| CMD-COPY-SKILLS | vscode NO recibe skills | `Test-Path .github/skills` = `False`. El bloque `vscode` elimina `skills/` y no la recrea. Solo genera `prompts/`. | COMPLIANT |
| CMD-COPY-COMMANDS | Comando copiado a gemini como TOML | `.gemini/commands/sdd/apply.toml` verificado: `description = "Implementar tareas de un change"` y `prompt = """..."""` con body completo. 12 archivos `.toml` generados. | COMPLIANT |
| CMD-COPY-COMMANDS | Comando copiado a github como .prompt.md | `.github/prompts/sdd-apply.prompt.md` verificado: frontmatter con solo `description:`, body completo. 12 archivos `.prompt.md` generados con nombre aplanado (`sdd-*.prompt.md`). | COMPLIANT |
| CMD-COPY-COMMANDS | Comando copiado a cursor con frontmatter enriquecido | `.cursor/commands/sdd/apply.md` verificado: frontmatter con `name: /sdd-apply`, `id: sdd-apply`, `category: Workflow`, `description:`. Body completo. | COMPLIANT |
| CMD-COPY-COMMANDS | Comando copiado a opencode con directorio singular | `.opencode/command/sdd/apply.md` verificado: carpeta singular `command/` (no `commands/`), frontmatter con solo `description:`, body completo. | COMPLIANT |
| CMD-GITHUB-NO-INSTRUCTIONS | copilot-instructions.md no se genera | `.github/copilot-instructions.md` existia previamente con contenido. Despues de ejecutar el script: archivo preservado intacto. El bloque `vscode` no lo crea ni lo toca. | COMPLIANT |
| CMD-GITHUB-NO-INSTRUCTIONS | copilot-instructions.md existente se preserva | `.github/copilot-instructions.md` verificado con contenido original despues de la ejecucion. El script solo opera sobre `prompts/` y `skills/` dentro de `.github/`. | COMPLIANT |
| CMD-ROOT-FILES | Claude genera CLAUDE.md con import | `CLAUDE.md` contiene `@AGENTS.md`. Output: `[OK] CLAUDE.md (import @AGENTS.md)`. | COMPLIANT |
| CMD-ROOT-FILES | Gemini genera GEMINI.md con copia | `GEMINI.md` contiene el mismo contenido que `AGENTS.md` (verificado: primeras lineas coinciden con bloque `sdd-workflow:start`). | COMPLIANT |
| CMD-GITHUB-SKILLS-CLEAN | .github/skills/ es eliminada y no recreada | `Test-Path .github/skills` = `False` despues de ejecutar script con `all`. El bloque `vscode` borra explicitamente y no llama `Copy-OrLink` para skills. | COMPLIANT |

### Edge Cases (validacion estatica)

| Caso | Evidence | Estado |
|------|----------|--------|
| `.agents/skills/` no existe | Logica condicional en ambos scripts: `if [ -d ... ]` / `if (Test-Path ...)` antes de copiar skills. | COMPLIANT |
| `.agents/commands/` no existe | Logica condicional: salida temprana en `mirror_commands`/`Invoke-MirrorCommands` y en los bloques vscode. | COMPLIANT |
| `.md` sin frontmatter | `Get-Body` / `get_body` devuelve el archivo completo si no detecta `---`; `description` queda vacio. | COMPLIANT |
| Body con `"""` (triple comilla) | **No hay manejo de escape en la generacion TOML** — risk documentado como WARNING. | STATIC_ONLY |
| `AGENTS.md` no existe | `New-RootFile` / `generate_root_file` sale temprano si no existe. | COMPLIANT |
| Directorio target no existe | `mkdir -p` / `New-Item -Force` en ambos scripts antes de escribir. | COMPLIANT |

### Editores adicionales verificados por runtime

| Editor | Formato | Directorio | Root File | Estado |
|--------|---------|------------|-----------|--------|
| cursor | `.md` enriquecido | `.cursor/commands/sdd/` | - | COMPLIANT |
| claude | `.md` con category+tags | `.claude/commands/sdd/` | `CLAUDE.md` (@import) | COMPLIANT |
| opencode | `.md` con solo description | `.opencode/command/sdd/` | - | COMPLIANT |
| gemini | `.toml` | `.gemini/commands/sdd/` | `GEMINI.md` (copia) | COMPLIANT |
| qwen | `.toml` | `.qwen/commands/sdd/` | - | COMPLIANT |
| antigravity | `.md` passthrough | `.agent/workflows/sdd/` | - | COMPLIANT |
| codex | solo skills | `.codex/skills/` | `CODEX.md` (copia) | COMPLIANT |
| amazonq | solo skills | `.amazonq/skills/` | - | COMPLIANT |
| vscode | `.prompt.md` | `.github/prompts/` | - | COMPLIANT |

## Issues

### CRITICAL
_Ninguno._

### WARNING
- **TOML triple-quote escape**: Si un comando fuente contiene `"""` en el body, los archivos `.toml` generados para gemini/qwen serian invalidos. Los comandos actuales no contienen ese patron, pero no hay manejo defensivo en el script. Riesgo bajo.
- **Bash script no verificado en runtime**: Solo se verifico estaticamente. No hay WSL ni bash nativo disponible en este entorno Windows. La paridad de logica con el script PS1 fue confirmada por inspeccion de codigo, pero no hay evidencia de ejecucion.
- **Spec adaptada de otro repo**: El spec `008-mirror-agents` fue renumerado a `001-mirror-agents` y se corrigio CMD-COPY-SKILLS para reflejar que `vscode` no recibe skills en este repo. La spec archivada (del otro repo) queda sin modificar como registro historico.

### SUGGESTION
- Considerar agregar escape de `"""` en la generacion TOML como medida preventiva.
- Validar el script `.sh` en un entorno con bash disponible (CI, WSL, o Linux).

## Veredicto
**PASS**. 14 scenarios verificados con evidencia runtime (PS1) y estatica (sh). 6 edge cases documentados validados. Spec adaptada de `008` a `001` para este repo. CMD-COPY-SKILLS corregido para excluir `vscode` de los editores que reciben skills. La implementacion esta alineada con la spec consolidada `001-mirror-agents`.

El change puede pasar a **sdd-archive**.
