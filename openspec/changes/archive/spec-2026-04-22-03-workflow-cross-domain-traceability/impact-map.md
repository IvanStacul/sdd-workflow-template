# Impact Map - spec-2026-04-22-03-workflow-cross-domain-traceability

## Clasificacion

- **Nivel**: `obligatorio`
- **Justificacion**: el change modifica templates del workflow, integra múltiples fases (`propose`, `spec`, `design`, `tasks`, `verify`, `archive`) y cambia contratos compartidos de la interfaz `/sdd:*`.
- **Dominio principal**: `workflow-core`

## Dominios Secundarios

| Dominio | Motivo | Status |
|---------|--------|--------|
| `change-authoring` | define cómo `propose`, `spec`, `design` y `tasks` consumen el análisis cruzado | `secondary` |
| `verification` | `verify` debe contrastar cobertura cross-domain contra artefactos del change | `secondary` |
| `archive-propagation` | `archive` propaga lecciones y preserva `impact-map.md` como audit trail | `secondary` |
| `public-command-interface` | `/sdd:new`, `/sdd:propose`, `/sdd:continue`, `/sdd:verify` y `/sdd:archive` cambian expectativas operativas | `secondary` |

## Referencias Tipadas

| target | target_type | relation | status | reason | tags |
|--------|-------------|----------|--------|--------|------|
| `openspec/changes/spec-2026-04-22-03-workflow-cross-domain-traceability/proposal.md` | `artifact` | `updates` | `primary` | la propuesta define alcance y justificación del análisis cruzado | `cross-phase, source-of-truth` |
| `openspec/changes/spec-2026-04-22-03-workflow-cross-domain-traceability/specs/002-cross-reference-analysis/spec.md` | `spec` | `constrains` | `in-scope` | la spec fija requisitos XREF-01 a XREF-06 que todo wiring debe cumplir | `requirements, verify-critical` |
| `openspec/changes/spec-2026-04-22-03-workflow-cross-domain-traceability/design.md` | `artifact` | `constrains` | `in-scope` | el diseño define por qué `impact-map.md` vive separado y cómo se valida cobertura | `design-decision` |
| `.agents/orchestrator.md` | `artifact` | `updates` | `in-scope` | el orquestador decide cuándo se relee y preserva el mismo mapa | `cross-phase, command-routing` |
| `.agents/skills/sdd-propose/SKILL.md` | `artifact` | `emits` | `in-scope` | `sdd-propose` clasifica el cambio y crea o justifica el mapa | `authoring, workflow-skill` |
| `.agents/skills/sdd-spec/SKILL.md` | `artifact` | `consumes` | `in-scope` | `sdd-spec` debe cubrir o justificar dominios, contratos y flows del mapa | `authoring, workflow-skill` |
| `.agents/skills/sdd-design/SKILL.md` | `artifact` | `consumes` | `in-scope` | `sdd-design` usa el mapa como señal de transversalidad y boundaries | `design, workflow-skill` |
| `.agents/skills/sdd-tasks/SKILL.md` | `artifact` | `consumes` | `in-scope` | `sdd-tasks` convierte cruces in-scope en tareas observables | `planning, workflow-skill` |
| `.agents/skills/sdd-verify/SKILL.md` | `artifact` | `verified-by` | `in-scope` | `verify` revisa cobertura del mapa y detecta contradicciones | `verification, verify-critical` |
| `.agents/skills/sdd-archive/SKILL.md` | `artifact` | `depends-on` | `in-scope` | `archive` preserva el mapa y decide qué hallazgos propaga a docs | `archive, workflow-skill` |
| `.agents/commands/sdd/propose.md` | `artifact` | `updates` | `in-scope` | el comando público debe reflejar creación o justificación del mapa | `public-command` |
| `.agents/commands/sdd/verify.md` | `artifact` | `updates` | `in-scope` | el comando público debe recordar cobertura cross-domain | `public-command` |
| `.agents/commands/sdd/archive.md` | `artifact` | `updates` | `in-scope` | el comando público debe preservar el artefacto y propagar hallazgos reutilizables | `public-command` |
| `docs/known-issues.md` | `artifact` | `emits` | `watch-only` | recibe lecciones reutilizables pero no cambia contrato del workflow por sí mismo | `docs, downstream` |
| `docs/workflow-changelog.md` | `artifact` | `emits` | `watch-only` | documenta adopción permanente de la práctica | `docs, downstream` |

## Contratos o Interfaces Afectadas

| Contrato | Tipo | Cambio esperado | Evidencia asociada |
|----------|------|-----------------|--------------------|
| `/sdd:new` -> `sdd-propose` | `workflow-interface` | si clasificación es `obligatorio` o `recomendado`, crea o actualiza `impact-map.md` | `.agents/orchestrator.md`, `.agents/commands/sdd/new.md`, `.agents/skills/sdd-propose/SKILL.md` |
| `/sdd:continue` | `workflow-interface` | relee y preserva mismo `impact-map.md` en vez de crear paralelos | `.agents/orchestrator.md`, `.agents/commands/sdd/continue.md` |
| `/sdd:verify` | `workflow-interface` | valida cobertura por dominios, contratos, flows, edge cases y exclusiones | `.agents/skills/sdd-verify/SKILL.md`, `verify-report.md` |
| `/sdd:archive` | `workflow-interface` | preserva `impact-map.md` y propaga hallazgos reusables | `.agents/skills/sdd-archive/SKILL.md`, `docs/known-issues.md`, `docs/workflow-changelog.md` |

## Downstream Flows

| Flow | Disparador | Impacto esperado | Status |
|------|------------|------------------|--------|
| `sdd-propose -> sdd-spec -> sdd-design -> sdd-tasks` | change nuevo o continuado con análisis cruzado | el mismo mapa concentra cruces y evita reinventar contexto | `in-scope` |
| `sdd-apply -> sdd-verify` | implementación terminada | verify usa el mapa para detectar cobertura faltante o contradicciones | `in-scope` |
| `sdd-verify -> sdd-archive` | change listo para cierre | archive conserva el mapa y decide qué hallazgos pasan a docs permanentes | `in-scope` |
| `docs/examples/*` | documentación pública de la práctica | muestra clasificación obligatoria y omisión justificada sin afectar contrato runtime | `watch-only` |

## Edge Cases Cross-Domain

| Caso | Dominios o artefactos involucrados | Mitigacion o seguimiento |
|------|------------------------------------|--------------------------|
| El change implementa el wiring del workflow pero olvida crear su propio `impact-map.md` | `proposal.md`, `tasks.md`, `verify-report.md`, `impact-map.md` | `verify` debe bloquear archivo faltante aunque el resto del wiring exista |
| Un cambio local usa referencias externas sin acceso al repo remoto | `impact-map.md`, `spec.md`, `verify-report.md` | registrar `external-reference` textual y justificar cobertura estática disponible |
| Un target downstream empieza como `watch-only` y luego se vuelve obligatorio | `impact-map.md`, `tasks.md`, `state.md` | actualizar misma referencia con nuevo `status`, razón y evidencia; no duplicar target |
| Un dominio secundario se revisa y queda fuera de scope | `impact-map.md`, `verify-report.md` | dejar exclusión explícita con motivo y fecha para que verify no lo trate como omisión |

## Exclusiones Explicitas

| Target | Motivo | Fecha de revision |
|--------|--------|-------------------|
| `grafo visual automático / Mermaid` | fuera de alcance; el cambio es file-based y no depende de visualizaciones | `2026-04-22` |
| `reescritura retroactiva de changes archivados` | violaría regla forward-only del workflow | `2026-04-22` |
| `descubrimiento automático desde repos remotos` | fuera de alcance; el mapa admite referencias textuales sin integración externa | `2026-04-22` |

## Evidencia Esperada para Verify

- existencia de `impact-map.md` en el change activo con clasificación, dominios, referencias, contratos, flows, edge cases y exclusiones
- wiring consistente entre `proposal.md`, `spec.md`, `design.md`, `tasks.md`, `verify-report.md` y skills modificadas
- ejemplos estáticos para clasificación obligatoria y omisión justificada en `docs/examples/`
- ausencia de contradicciones entre mapa, spec, design y tasks

## Notas de Seguimiento

- Mantener una sola fila por combinación `target` + `relation`; actualizar `status`, `reason` y `tags` cuando cambie el alcance.
- Si un flujo downstream deriva en otro chequeo, enlazar target relacionado y resumir vínculo en `reason`; no copiar bloques completos de otros artefactos.
- `docs/known-issues.md` y `docs/workflow-changelog.md` quedan como `watch-only`/emisión hasta cierre del change; su actualización real se valida en `archive`.