# Patch - Compatibilidad gitignore con editores AI

## Motivación

Tras investigar la documentación oficial de cada editor, se encontró que:

1. **Cursor ignora archivos en `.gitignore`** — Los docs lo confirman textualmente. Como `.cursor/` estaba en `.gitignore`, Cursor no podía ver los skills en `.cursor/skills/`.
2. **CLAUDE.md era una copia completa de AGENTS.md** — Claude Code recomienda que si ya existe `AGENTS.md`, `CLAUDE.md` use `@AGENTS.md` (import syntax). Además, VS Code lee tanto AGENTS.md como CLAUDE.md, causando instrucciones duplicadas en el contexto.
3. **CURSOR.md no lo lee nadie** — Cursor lee `AGENTS.md` directamente, no `CURSOR.md`.
4. **`.github/` estaba gitignored** — Es un directorio estándar de GitHub; no debería ignorarse.
5. **Root files auto-generados no estaban gitignored** — `GEMINI.md`, `CODEX.md` son generados por el mirror; no deberían trackearse.

## Cambio

### 1. Reestructurar `.gitignore`

- Sacar `.github/` del gitignore (es config estándar de GitHub)
- Agregar root files auto-generados: `GEMINI.md`, `CODEX.md`
- Mantener los mirror dirs que NO tienen problemas de compatibilidad

### 2. Crear `.cursorignore`

Agregar `!.cursor/` para negar el gitignore y que Cursor pueda ver sus skills.

### 3. Cambiar CLAUDE.md a import

En vez de copiar todo el contenido de AGENTS.md, hacer que CLAUDE.md solo contenga `@AGENTS.md`. Esto sigue la recomendación oficial de Claude Code y evita duplicar instrucciones en VS Code.

### 4. Eliminar CURSOR.md de la generación

Cursor lee AGENTS.md, no CURSOR.md. Quitar la entrada del mapa `root_file_for_editor()` en ambos scripts (bash y PS1).

## Archivos

| Archivo | Acción | Detalle |
|---------|--------|---------|
| `.gitignore` | Modificado | Sacar `.github/`, agregar root files auto-generados |
| `.cursorignore` | Creado | Negar gitignore para `.cursor/` |
| `CLAUDE.md` | Modificado | Cambiar de copia completa a `@AGENTS.md` |
| `CURSOR.md` | Eliminado | Cursor lee AGENTS.md, no este archivo |
| `.agents/skills/sdd-init/scripts/mirror-agents.sh` | Modificado | Quitar cursor del mapa root_file_for_editor, CLAUDE genera import |
| `.agents/skills/sdd-init/scripts/mirror-agents.ps1` | Modificado | Mismo cambio que bash |

## Spec afectada
Ninguna — infraestructura del workflow.

## Decisiones

| # | Decision | Tipo | Justificacion |
|---|----------|------|---------------|
| D-01 | CLAUDE.md usa `@AGENTS.md` en vez de copia | Decisión de diseño | Recomendación oficial de Claude Code + evita duplicación en VS Code |
| D-02 | `.cursorignore` con negación en vez de sacar `.cursor/` del gitignore | Decisión de diseño | Mantiene el gitignore limpio sin trackear dirs auto-generados, y Cursor respeta `.cursorignore` con mayor prioridad |
| D-03 | CURSOR.md eliminado, no generado | Decisión de diseño | Cursor lee AGENTS.md directamente; CURSOR.md era dead code |

## Verificación
- [x] `CLAUDE.md` contiene `@AGENTS.md` (no una copia completa)
- [x] `.cursorignore` existe con `!.cursor/`
- [x] `.github/copilot-instructions.md` está gitignored (auto-generado), pero `.github/` como directorio no
- [x] `GEMINI.md` y `CODEX.md` están en gitignore
- [x] `CURSOR.md` no existe
- [x] `mirror-agents.sh` no genera CURSOR.md
- [x] `mirror-agents.ps1` no genera CURSOR.md
