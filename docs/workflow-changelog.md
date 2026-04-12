# Changelog del Workflow SDD

> Registro de mejoras al sistema de especificaciones y workflow.
> Estado de cada entrada: `propuesta` | `aplicada` | `descartada`.

---

## v1.0 - Inicial (2026-04-11)

**Estado**: aplicada

- Estructura base del flujo SDD.
- Skills: init, explore, propose, spec, design, tasks, apply, verify, archive, patch, domain-brief.
- Convenciones compartidas: phase-common, openspec-convention, abstraction-guide.
- Retro obligatoria en archive con propagacion a known-issues.
- `state.md` con log append-only.
- Namespaces como metadata, no carpetas.
- Templates forward-only: las mejoras no reescriben artefactos existentes.

---

## Heuristicas de init para AGENTS y multi-agent (2026-04-11)

**Estado**: aplicada
**Origen**: ajuste post-init del template
**Skill/archivo afectado**: `.agents/skills/sdd-init/SKILL.md`

Se corrigieron las heuristicas de `sdd-init` para que `agents_md_policy` no caiga en `section` por default cuando `AGENTS.md` no existe y no hay otro owner detectable. Tambien se formalizo que `agent_mode: multi` puede elegirse sin preguntar cuando hay evidencia real del editor, y que `modules.model_routing` solo debe activarse con aliases confirmados por configuracion o settings.

---

## Absorción de brainstorming en fases SDD (2026-04-11)

**Estado**: aplicada
**Origen**: revisión de skills — brainstorming duplicaba responsabilidades con fases SDD
**Skills/archivos afectados**: brainstorming (eliminada), visual-companion (nueva), rules.md, sdd-explore, sdd-propose

La skill `brainstorming` fue escrita para otro workflow ("superpowers") y duplicaba responsabilidades con `sdd-explore`, `sdd-propose`, `sdd-design`, `sdd-verify` y `sdd-tasks`. Se redistribuyó lo valioso:

- **Visual companion** → extraído a skill standalone `visual-companion` con scripts renombrados (sin referencias a "superpowers" ni "brainstorming"). Paths de sesión cambian de `.superpowers/brainstorm/` a `.visual-companion/sessions/`.
- **Patrones de diálogo** (una pregunta a la vez, preferir opción múltiple, validación incremental) → agregados como reglas duras en `rules.md` sección "Diálogo".
- **Evaluación de alcance temprana** → agregada como Step 1.5 en `sdd-explore` (detectar multi-sistema antes de profundizar). También reforzado en `sdd-propose` Step 4.
- **Anti-patrón "demasiado simple"** → descartado, las gates existentes en sdd-design ya lo cubren.
- **spec-document-reviewer-prompt.md** → descartado, `sdd-verify` ya cubre esa función.
- **refs a `docs/superpowers/specs/`** → eliminadas junto con la skill.

---

## Mejoras al mirror, gitignore y visibilidad del workflow (2026-04-11)

**Estado**: aplicada
**Origen**: operación del workflow en sesiones reales
**Archivos afectados**: `.gitignore`, `.agents/orchestrator.md`, `mirror-agents.sh`, `mirror-agents.ps1`

Tres mejoras de infraestructura detectadas al operar el workflow:

- **`.gitignore` completado** — se agregaron `.gemini/`, `.codex/`, `.qwen/`, `.agent/`, `.amazonq/`, `.visual-companion/`.
- **Resumen de progreso entre fases** — el orquestador ahora muestra un bloque compacto con emojis (✅/⏭️/👉/⬚) entre fases en modo interactivo.
- **Mirror extendido** — `mirror-agents.sh` ahora genera root files (`CLAUDE.md`, `CURSOR.md`, `GEMINI.md`, `CODEX.md`) desde `AGENTS.md`. Opción `--symlink` para usar symlinks en lugar de copias. Port nativo `mirror-agents.ps1` para Windows.

---

## Compatibilidad gitignore con editores AI (2026-04-12)

**Estado**: aplicada
**Origen**: investigación de docs oficiales de cada editor
**Archivos afectados**: `.gitignore`, `.cursorignore`, `CLAUDE.md`, `mirror-agents.sh`, `mirror-agents.ps1`

Se investigó cómo cada editor (VS Code, Claude Code, Cursor, OpenCode) maneja archivos en `.gitignore` para sus configuraciones propias. Hallazgos:

- **Cursor ignora archivos en `.gitignore` por defecto** — `.cursor/skills/` no era visible. Fix: `.cursorignore` con `!.cursor/`.
- **`CLAUDE.md` duplicaba contexto** — VS Code lee tanto `AGENTS.md` como `CLAUDE.md`. Claude Code recomienda import. Fix: `CLAUDE.md` ahora contiene `@AGENTS.md`.
- **`CURSOR.md` era dead code** — Cursor lee `AGENTS.md` directamente. Eliminado de la generación del mirror.
- **Root files auto-generados** — `GEMINI.md`, `CODEX.md`, `CLAUDE.md` agregados al gitignore como auto-generados.

---

<!-- Formato para entradas futuras:

## {Descripcion} ({YYYY-MM-DD})

**Estado**: {propuesta | aplicada | descartada}
**Origen**: retro de {change-name}
**Skill/archivo afectado**: {path}

{Descripcion y justificacion}

-->