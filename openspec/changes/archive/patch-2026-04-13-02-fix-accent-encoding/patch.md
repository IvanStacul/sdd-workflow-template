# Patch - Corregir tildes y acentos faltantes en archivos del workflow

## Motivación
Los archivos `.agents/**/*.md`, `docs/*.md` y los mirror files (`AGENTS.md`, `CODEX.md`, `GEMINI.md`) tienen palabras en español escritas sin tildes de forma inconsistente. Algunas líneas usan acentos correctos ("implementación") y otras no ("implementacion"). Esto genera confusión al transferir archivos entre repos y problemas de lectura con herramientas que asumen codificación distinta a UTF-8.

## Cambio
Corrección masiva de tildes faltantes en ~310 ocurrencias de palabras españolas a lo largo de 38 archivos Markdown del workflow SDD. Las correcciones incluyen:

- Terminaciones -ción: validación, descripción, implementación, configuración, sección, decisión, etc.
- Palabras con ñ: diseño
- Esdrújulas: módulo, único, público, código, técnico, específica, etc.
- Palabras con tilde: todavía, también, después, según, más, guía, etc.
- Contextuales: "está" (verbo) vs "esta" (demostrativo)

No se modifica lógica, estructura ni comportamiento del workflow. Solo corrección ortográfica.

## Archivos

| Archivo | Acción | Detalle |
|---------|--------|---------|
| `.agents/commands/sdd/continue.md` | Modificado | según |
| `.agents/commands/sdd/domain-brief.md` | Modificado | todavía |
| `.agents/commands/sdd/ff.md` | Modificado | ejecución, según |
| `.agents/commands/sdd/new.md` | Modificado | técnico |
| `.agents/commands/sdd/patch.md` | Modificado | descripción, único |
| `.agents/commands/sdd/propose.md` | Modificado | descripción |
| `.agents/orchestrator.md` | Modificado | decisión, mínima, después, Situación |
| `.agents/personality.md` | Modificado | decisión, todavía, técnico, según, Cómo |
| `.agents/rules.md` | Modificado | Verificación, información, Interacción, Código, según, resolución, explícita, pública |
| `.agents/skills/_shared/abstraction-guide.md` | Modificado | útil |
| `.agents/skills/_shared/openspec-convention.md` | Modificado | verificación, sección, Exploración, Diseño, único, técnico, código, válido |
| `.agents/skills/_shared/phase-common.md` | Modificado | observación |
| `.agents/skills/_shared/skill-resolver.md` | Modificado | módulo, genérica, específica, código, inyección, resolución, faltó |
| `.agents/skills/interface-design/SKILL.md` | Modificado | decisión |
| `.agents/skills/interface-design/references/critique.md` | Modificado | decisión |
| `.agents/skills/interface-design/references/example.md` | Modificado | Decisión |
| `.agents/skills/sdd-apply/SKILL.md` | Modificado | implementación, módulo, única, está |
| `.agents/skills/sdd-apply/strict-tdd.md` | Modificado | implementación, Módulo, mínimo, mínima, desviación |
| `.agents/skills/sdd-archive/SKILL.md` | Modificado | específica, mínimo, mínimos, También, después, Propagación, observación, sincronización |
| `.agents/skills/sdd-design/SKILL.md` | Modificado | diseño, técnicas, técnico |
| `.agents/skills/sdd-explore/SKILL.md` | Modificado | exploración, recomendación, más, explícitamente |
| `.agents/skills/sdd-init/SKILL.md` | Modificado | configuración, decisión, sección, módulo, documentación, según, código, válida, autónoma, detección, inyección |
| `.agents/skills/sdd-init/assets/agents-section.template.md` | Modificado | único |
| `.agents/skills/sdd-init/assets/known-issues.template.md` | Modificado | Descripción, Solución, Prevención, Acción, Lección, título |
| `.agents/skills/sdd-init/assets/workflow-changelog.template.md` | Modificado | justificación, Descripción, propagación |
| `.agents/skills/sdd-onboard/SKILL.md` | Modificado | validación, explicación, único, público, pedagógico, según, técnico, código, automatización, teórica |
| `.agents/skills/sdd-patch/SKILL.md` | Modificado | validación, descripción, decisión, Justificación, módulo, público, práctica |
| `.agents/skills/sdd-propose/SKILL.md` | Modificado | implementación |
| `.agents/skills/sdd-spec/SKILL.md` | Modificado | implementación, separación, acción, explícitamente, huérfanas, número, crítico |
| `.agents/skills/sdd-tasks/SKILL.md` | Modificado | implementación, verificación, explicación, sección, explícitamente |
| `.agents/skills/sdd-tasks/assets/tasks.template.md` | Modificado | línea |
| `.agents/skills/sdd-verify/SKILL.md` | Modificado | implementación, Verificación, módulo, explícito, explícitada, guía |
| `.agents/skills/sdd-verify/strict-tdd-verify.md` | Modificado | implementación, Módulo, mínimos |
| `docs/known-issues.md` | Modificado | Descripción, Solución, Prevención, Acción, Lección, Estadísticas, Métrica, título |
| `docs/workflow-changelog.md` | Modificado | configuración, justificación, Descripción, También, propagación |
| `docs/workflow-guide.md` | Modificado | técnico, guía, públicos |
| `docs/workflow-sources.md` | Modificado | guía, públicos |
| `AGENTS.md` | Modificado | único |
| `CODEX.md` | Modificado | único |
| `GEMINI.md` | Modificado | único |

## Spec afectada
Ninguna — cambio puramente ortográfico.

## Verificación
- [x] No quedan palabras sin tilde en el listado de reemplazos (dry-run da 0 pendientes)
- [x] Los archivos siguen siendo UTF-8 válido (BOM preservado donde existía)
- [x] No se modificaron bloques de código, claves YAML ni identificadores técnicos
- [x] Script idempotente: re-ejecución produce 0 cambios adicionales
