# State - spec-2026-04-13-01-mirror-agents-editor-formats

## Fase Actual
verify

## Resumen
Mejorar el script `mirror-agents` para que genere el formato nativo correcto por editor (TOML para Gemini/Qwen, `.prompt.md` para GitHub, frontmatter enriquecido para Cursor), reemplazando la copia naïve actual que solo funciona para editores que leen `.md` estándar.

---

## Log de Fases (append-only - NO editar entradas anteriores)

### [2026-04-13 09:23] explore
- **Estado**: completado
- **Resumen**: Se mapearon los formatos reales de cada editor comparando los archivos generados por OpenSpec vs. lo que produce el script actual. Se identificaron las transformaciones necesarias por editor y las decisiones de diseño.
- **Decisiones**: Ninguna
- **Artefactos**: exploración inline
- **Siguiente**: propose

### [2026-04-13 09:28] propose
- **Estado**: completado
- **Resumen**: Propuesta escrita. Capability nueva `mirror-agents.format-transform` y capability modificada `mirror-agents.commands-copy`. Alcance acotado a los dos scripts (ps1 y sh).
- **Decisiones**: D-01, D-02, D-03
- **Artefactos**: proposal.md, state.md
- **Siguiente**: sdd-spec

### [2026-04-13 09:28] spec
- **Estado**: completado
- **Resumen**: Spec única `001-mirror-agents` con 6 requirements. Las dos capabilities de la propuesta se unificaron en una sola spec.
- **Decisiones**: D-04
- **Artefactos**: specs/001-mirror-agents/spec.md
- **Siguiente**: sdd-tasks

### [2026-04-13 09:32] tasks
- **Estado**: completado
- **Resumen**: 13 tareas en 4 fases.
- **Decisiones**: Ninguna nueva
- **Artefactos**: tasks.md
- **Siguiente**: sdd-apply

### [2026-04-13 10:20] apply
- **Estado**: completado
- **Resumen**: Implementación completa en ambos scripts. Corrección de encoding en PS1 (emojis → tags ASCII).
- **Decisiones**: Ninguna nueva
- **Artefactos**: mirror-agents.ps1, mirror-agents.sh, tasks.md
- **Siguiente**: sdd-verify

### [2026-04-13 10:23] verify (otro repo)
- **Estado**: completado
- **Resumen**: Verificación original en otro repositorio. 13 scenarios COMPLIANT.
- **Decisiones**: Ninguna
- **Artefactos**: verify-report.md (archivado)
- **Siguiente**: sdd-archive

### [2026-04-13 10:28] archive (otro repo)
- **Estado**: completado
- **Resumen**: Change archivado en el otro repo. Retro escrita, spec consolidada.
- **Decisiones**: Ninguna
- **Artefactos**: retro.md
- **Siguiente**: re-verify en repo template

### [2026-04-13] verify (re-verificacion en repo template)
- **Estado**: completado
- **Resumen**: Re-verificación en el repositorio template. Ejecución runtime de `mirror-agents.ps1 all` exitosa. 14 scenarios verificados (13 originales + 1 nuevo para vscode-no-skills). Spec renumerada de `008` a `001`. CMD-COPY-SKILLS corregido: `vscode` no recibe skills (solo commands como `.prompt.md`). Bash verificado solo estáticamente.
- **Decisiones**: D-05
- **Artefactos**: verify-report.md, state.md, specs/001-mirror-agents/spec.md (corregido)
- **Siguiente**: sdd-archive

---

## Decisiones (solo agregar filas)

| # | Decisión | Tipo | Req Afectado | Fase | Justificación |
|---|----------|------|--------------|------|---------------|
| D-01 | No generar `copilot-instructions.md` para GitHub | Decisión de diseño | CMD-GITHUB-NO-INSTRUCTIONS | propose | El usuario no lo necesita; solo generar `prompts/*.prompt.md` |
| D-02 | Frontmatter mínimo en fuente, enriquecimiento on-copy | Decisión de diseño | CMD-COPY-COMMANDS | propose | Mantiene una sola fuente de verdad limpia; cada editor recibe su wrapper |
| D-03 | Borrar `.github/skills/` sin regenerar | Decisión de diseño | CMD-GITHUB-SKILLS-CLEAN | propose | GitHub Copilot no tiene sistema de skills real; es ruido |
| D-04 | Capabilities unificadas en una sola spec `001-mirror-agents` | Decisión de diseño | todas | spec | El script es una unidad de comportamiento cohesiva |
| D-05 | Spec renumerada de `008` a `001` y CMD-COPY-SKILLS corregido para excluir `vscode` | Decisión de diseño | CMD-COPY-SKILLS | verify | `008` era numeración del otro repo; `vscode` no recibe skills en este repo (solo commands como `.prompt.md`) |

---

## Archivos Afectados

| Archivo | Acción | Req | Fase |
|---------|--------|-----|------|
| `.agents/skills/sdd-init/scripts/mirror-agents.ps1` | Modificado | CMD-COPY-COMMANDS | apply |
| `.agents/skills/sdd-init/scripts/mirror-agents.sh` | Modificado | CMD-COPY-COMMANDS | apply |
| `openspec/specs/001-mirror-agents/spec.md` | Creado | todas | spec |
