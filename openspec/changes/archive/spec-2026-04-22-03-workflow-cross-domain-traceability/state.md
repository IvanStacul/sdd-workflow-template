# State - spec-2026-04-22-03-workflow-cross-domain-traceability

## Fase Actual
archive

## Resumen
Agregar una capability nueva del workflow para análisis de impacto cruzado mediante un artefacto `impact-map.md` reusable entre fases. El change define triggers de uso, referencias tipadas sin loops recursivos, verificación de cobertura y propagación de lecciones sin romper la regla forward-only.

---

## Log de Fases (append-only - NO editar entradas anteriores)

### [2026-04-22 16:30] propose
- **Estado**: completado
- **Resumen**: Propuesta escrita para introducir análisis de impacto cruzado como capability nueva del workflow. Se eligió `impact-map.md` como fuente de verdad y se acotó el alcance a artefactos y skills del template.
- **Decisiones**: D-01, D-02, D-03
- **Artefactos**: proposal.md, state.md
- **Siguiente**: sdd-spec

### [2026-04-22 16:36] spec
- **Estado**: completado
- **Resumen**: Spec nueva `002-cross-reference-analysis` con requirements sobre artefacto, criterios de uso, integración por fases, mecanismo anti-loop y verify/archive.
- **Decisiones**: D-04
- **Artefactos**: specs/002-cross-reference-analysis/spec.md
- **Siguiente**: sdd-design

### [2026-04-22 16:43] design
- **Estado**: completado
- **Resumen**: Gate técnico positivo. El change necesita `design.md` porque modifica varias fases del workflow y requiere decisiones estructurales sobre ubicación del artefacto y semántica de referencias.
- **Decisiones**: D-05, D-06
- **Artefactos**: design.md
- **Siguiente**: sdd-tasks

### [2026-04-22 16:49] tasks
- **Estado**: completado
- **Resumen**: Plan de implementación en 4 fases para introducir `impact-map.md`, conectar propose/spec/design/tasks/verify/archive y documentar adopción forward-only.
- **Decisiones**: Ninguna nueva
- **Artefactos**: tasks.md
- **Siguiente**: sdd-apply

### [2026-04-22 16:50] apply
- **Estado**: completado con observaciones
- **Resumen**: Primer batch de implementación completado. La convención y el orquestador ya reconocen `impact-map.md`, existe un template base en `sdd-propose/assets/` y quedaron documentadas las reglas de referencias tipadas y anti-loop.
- **Decisiones**: Ninguna nueva
- **Artefactos**: .agents/skills/_shared/openspec-convention.md, .agents/orchestrator.md, .agents/skills/sdd-propose/assets/impact-map.template.md, .agents/skills/_shared/phase-common.md, tasks.md
- **Siguiente**: sdd-apply

### [2026-04-22 16:51] apply
- **Estado**: completado con observaciones
- **Resumen**: Segundo batch de implementación completado. `sdd-propose` ahora clasifica y persiste `impact-map.md`, `/sdd:new` y `/sdd:continue` preservan el mismo artefacto y `sdd-spec` lo usa para cerrar cobertura por dominios, contratos, flows y edge cases.
- **Decisiones**: Ninguna nueva
- **Artefactos**: .agents/skills/sdd-propose/SKILL.md, .agents/orchestrator.md, .agents/commands/sdd/new.md, .agents/commands/sdd/continue.md, .agents/skills/sdd-spec/SKILL.md, tasks.md
- **Siguiente**: sdd-apply

### [2026-04-22 16:52] apply
- **Estado**: completado con observaciones
- **Resumen**: Tercer batch de implementación completado. `sdd-design` usa `impact-map.md` como señal de transversalidad, `sdd-tasks` convierte cruces `in-scope` en tareas observables y `phase-common` exige reconciliación entre mapa, spec, design y tasks.
- **Decisiones**: Ninguna nueva
- **Artefactos**: .agents/skills/sdd-design/SKILL.md, .agents/skills/sdd-design/assets/design.template.md, .agents/skills/sdd-tasks/SKILL.md, .agents/skills/sdd-tasks/assets/tasks.template.md, .agents/skills/_shared/phase-common.md, tasks.md
- **Siguiente**: sdd-apply

### [2026-04-22 16:53] apply
- **Estado**: completado
- **Resumen**: Implementación del change completada. `sdd-verify` y `sdd-archive` ya verifican y propagan cobertura cross-domain, la documentación pública explica `impact-map.md` y quedaron ejemplos estáticos para clasificación obligatoria y omisión justificada.
- **Decisiones**: Ninguna nueva
- **Artefactos**: .agents/skills/sdd-verify/SKILL.md, .agents/skills/sdd-archive/SKILL.md, README.md, docs/workflow-guide.md, .agents/commands/sdd/propose.md, .agents/commands/sdd/verify.md, .agents/commands/sdd/archive.md, docs/known-issues.md, docs/workflow-changelog.md, docs/examples/impact-map-required.md, docs/examples/impact-map-optional.md, tasks.md
- **Siguiente**: sdd-verify

### [2026-04-22 17:02] verify
- **Estado**: bloqueado
- **Resumen**: Verificación ejecutada con evidencia estática. `sdd-verify` y artefactos del workflow están implementados, pero el change activo no contiene `impact-map.md` ni una clasificación persistida, así que falta la fuente de verdad requerida para cobertura cross-domain.
- **Decisiones**: Ninguna nueva
- **Artefactos**: verify-report.md, state.md
- **Siguiente**: sdd-apply

### [2026-04-22 17:07] apply
- **Estado**: completado
- **Resumen**: Batch correctivo post-verify. Se materializó `impact-map.md` en el change activo y se persistió la clasificación `obligatorio` en `proposal.md` para reconciliar artefactos antes de rerun de verify.
- **Decisiones**: Ninguna nueva
- **Artefactos**: impact-map.md, proposal.md, state.md
- **Siguiente**: sdd-verify

### [2026-04-22 17:10] verify
- **Estado**: completado con observaciones
- **Resumen**: Rerun de verify exitoso. El change ya contiene `impact-map.md`, clasificación persistida y cobertura cross-domain consistente entre proposal, spec, design, tasks y artefactos del workflow. Solo quedan warnings no bloqueantes por falta de runtime evidence configurada y una pregunta abierta residual en `design.md`.
- **Decisiones**: Ninguna nueva
- **Artefactos**: verify-report.md, state.md
- **Siguiente**: sdd-archive

### [2026-04-22 17:53] archive
- **Estado**: completado
- **Resumen**: Retro obligatoria escrita, bug reusable propagado a `docs/known-issues.md` y delta spec sincronizada como nueva spec consolidada `openspec/specs/002-cross-reference-analysis/spec.md`. El change queda listo para moverse a `archive/` preservando `impact-map.md` y el resto del audit trail.
- **Decisiones**: Ninguna nueva
- **Artefactos**: retro.md, docs/known-issues.md, openspec/specs/002-cross-reference-analysis/spec.md, state.md
- **Siguiente**: none

---

## Decisiones (solo agregar filas)

| # | Decisión | Tipo | Req Afectado | Fase | Justificación |
|---|----------|------|--------------|------|---------------|
| D-01 | El análisis cruzado vive en `impact-map.md` como artefacto separado y no repartido entre varios documentos | Decisión de diseño | XREF-01 | propose | Permite reusar la misma fuente de verdad desde propose hasta archive sin duplicar contexto |
| D-02 | Las referencias del mapa usan tipos, relaciones, status y tags explícitos | Decisión de diseño | XREF-04 | propose | Hace verificable el análisis y evita listas ambiguas de impactos |
| D-03 | La práctica se clasifica como obligatoria, recomendada u opcional según transversalidad y riesgo | Regla de negocio | XREF-02 | propose | Reduce omisiones en cambios grandes sin cargar fixes chicos con burocracia innecesaria |
| D-04 | La capability nueva se modela como `002-cross-reference-analysis` y no como delta de una spec existente | Decisión de diseño | XREF-01 | spec | El repo no tiene una spec consolidada vigente para este comportamiento del workflow |
| D-05 | El gate técnico crea `design.md` por tratarse de una mejora cross-cutting del workflow | Decisión de diseño | XREF-03 | design | El change modifica múltiples fases y necesita cerrar decisiones estructurales antes de taskear |
| D-06 | `verify` exige cobertura por dominio o contrato in-scope con mínimos razonables y `archive` propaga hallazgos generales respetando forward-only | Restricción técnica | XREF-05, XREF-06 | design | Estandariza evidencia sin reescribir historial ni aprobar cambios con huecos de impacto cruzado |

---

## Archivos Afectados

| Archivo | Acción | Req | Fase |
|---------|--------|-----|------|
| `.agents/skills/_shared/openspec-convention.md` | Modificado | XREF-01, XREF-04 | apply |
| `.agents/orchestrator.md` | Modificado | XREF-01 | apply |
| `.agents/skills/sdd-propose/assets/impact-map.template.md` | Creado | XREF-01 | apply |
| `.agents/skills/_shared/phase-common.md` | Modificado | XREF-04 | apply |
| `.agents/skills/sdd-propose/SKILL.md` | Modificado | XREF-02 | apply |
| `.agents/orchestrator.md` | Modificado | XREF-03 | apply |
| `.agents/commands/sdd/new.md` | Modificado | XREF-03 | apply |
| `.agents/commands/sdd/continue.md` | Modificado | XREF-03 | apply |
| `.agents/skills/sdd-spec/SKILL.md` | Modificado | XREF-03 | apply |
| `.agents/skills/sdd-design/SKILL.md` | Modificado | XREF-03 | apply |
| `.agents/skills/sdd-design/assets/design.template.md` | Modificado | XREF-03 | apply |
| `.agents/skills/sdd-tasks/SKILL.md` | Modificado | XREF-03 | apply |
| `.agents/skills/sdd-tasks/assets/tasks.template.md` | Modificado | XREF-03 | apply |
| `.agents/skills/_shared/phase-common.md` | Modificado | XREF-04 | apply |
| `.agents/skills/sdd-verify/SKILL.md` | Modificado | XREF-05 | apply |
| `.agents/skills/sdd-archive/SKILL.md` | Modificado | XREF-06 | apply |
| `README.md` | Modificado | XREF-06 | apply |
| `docs/workflow-guide.md` | Modificado | XREF-06 | apply |
| `.agents/commands/sdd/propose.md` | Modificado | XREF-06 | apply |
| `.agents/commands/sdd/verify.md` | Modificado | XREF-06 | apply |
| `.agents/commands/sdd/archive.md` | Modificado | XREF-06 | apply |
| `docs/known-issues.md` | Modificado | XREF-06 | apply |
| `docs/workflow-changelog.md` | Modificado | XREF-06 | apply |
| `docs/examples/impact-map-required.md` | Creado | XREF-02 | apply |
| `docs/examples/impact-map-optional.md` | Creado | XREF-02 | apply |
| `openspec/changes/spec-2026-04-22-03-workflow-cross-domain-traceability/impact-map.md` | Creado | XREF-01, XREF-03 | apply |
| `openspec/changes/spec-2026-04-22-03-workflow-cross-domain-traceability/proposal.md` | Modificado | XREF-02, XREF-03 | apply |
| `openspec/changes/spec-2026-04-22-03-workflow-cross-domain-traceability/retro.md` | Creado | XREF-06 | archive |
| `docs/known-issues.md` | Modificado | XREF-06 | archive |
| `openspec/specs/002-cross-reference-analysis/spec.md` | Creado | todas | archive |