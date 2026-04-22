# Tareas - spec-2026-04-22-03-workflow-cross-domain-traceability

> **Specs**: [specs/](./specs/)
> **Design**: [design.md](./design.md)

## Convenciones

- **Estados**: `[ ]` pendiente · `[~]` en progreso · `[x]` completada
- **Refs**: cada tarea referencia el requirement que implementa

---

## PHASE 1 - Convención y artefacto base

- [x] 1.1 Extender la convención OpenSpec para registrar `impact-map.md` como artefacto del change `[XREF-01]`
  - **Archivos**: `.agents/skills/_shared/openspec-convention.md`, `.agents/orchestrator.md`
  - **Depende de**: -
  - **Criterio**: la estructura oficial del change y el grafo de dependencias mencionan cuándo aparece `impact-map.md` y qué fases lo leen

- [x] 1.2 Crear el template base de `impact-map.md` con secciones mínimas y taxonomía de referencias `[XREF-01]`
  - **Archivos**: `.agents/skills/sdd-propose/assets/impact-map.template.md` o path equivalente compartido
  - **Depende de**: 1.1
  - **Criterio**: el template incluye dominio principal, dominios secundarios, referencias tipadas, contratos, downstream flows, edge cases, exclusiones y evidencia esperada

- [x] 1.3 Documentar formato de referencias tipadas, status y tags para evitar loops `[XREF-04]`
  - **Archivos**: `.agents/skills/_shared/openspec-convention.md`, `.agents/skills/_shared/phase-common.md`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: la convención deja explícito cómo deduplicar targets y cómo registrar seguimientos sin nesting recursivo

---

## PHASE 2 - Integración con propose, continue y spec

- [x] 2.1 Actualizar `sdd-propose` para clasificar el change como obligatorio, recomendado u opcional y crear `impact-map.md` cuando aplique `[XREF-02]`
  - **Archivos**: `.agents/skills/sdd-propose/SKILL.md`
  - **Depende de**: 1.2, 1.3
  - **Criterio**: la skill define triggers claros y obliga a justificar la omisión cuando el análisis no se crea

- [x] 2.2 Actualizar el flujo de `/sdd:new` y `/sdd:continue` para releer y preservar el mismo `impact-map.md` `[XREF-03]`
  - **Archivos**: `.agents/orchestrator.md`, `.agents/commands/sdd/new.md`, `.agents/commands/sdd/continue.md`
  - **Depende de**: 2.1
  - **Criterio**: el orquestador y los comandos documentan que el mapa se crea una vez y luego se continúa, sin duplicados

- [x] 2.3 Actualizar `sdd-spec` para contrastar el mapa contra capabilities, deltas y edge cases `[XREF-03]`
  - **Archivos**: `.agents/skills/sdd-spec/SKILL.md`
  - **Depende de**: 2.1, 2.2
  - **Criterio**: la skill exige leer `impact-map.md` y cubrir o justificar dominios, contratos y flows listados

---

## PHASE 3 - Gate técnico y plan de implementación

- [x] 3.1 Actualizar `sdd-design` para usar el mapa como señal de cambio cross-cutting y registrar decisiones estructurales derivadas `[XREF-03]`
  - **Archivos**: `.agents/skills/sdd-design/SKILL.md`, `.agents/skills/sdd-design/assets/design.template.md`
  - **Depende de**: 2.3
  - **Criterio**: design puede justificar mejor cuándo hace falta diseño porque el mapa ya expone contratos y cruces entre fases o módulos

- [x] 3.2 Actualizar `sdd-tasks` para convertir cruces in-scope en tareas verificables con contratos observables `[XREF-03]`
  - **Archivos**: `.agents/skills/sdd-tasks/SKILL.md`, `.agents/skills/sdd-tasks/assets/tasks.template.md`
  - **Depende de**: 3.1
  - **Criterio**: tasks exige cobertura para contratos o downstream flows listados en el mapa y no permite dejar cruces críticos sin tarea o exclusión

- [x] 3.3 Reforzar `phase-common` para que el análisis cruzado no quede desacoplado de evidencia y trazabilidad `[XREF-04]`
  - **Archivos**: `.agents/skills/_shared/phase-common.md`
  - **Depende de**: 1.3, 3.2
  - **Criterio**: la checklist compartida recuerda cobertura cruzada, exclusiones justificadas y reconciliación entre mapa, spec y tasks

---

## PHASE 4 - Verify, archive y documentación

- [x] 4.1 Actualizar `sdd-verify` para revisar cobertura por dominio secundario, contratos, edge cases y exclusiones `[XREF-05]`
  - **Archivos**: `.agents/skills/sdd-verify/SKILL.md`
  - **Depende de**: 2.3, 3.2
  - **Criterio**: verify falla o devuelve observaciones cuando el mapa contradice proposal/spec/design/tasks o no tiene cobertura suficiente

- [x] 4.2 Actualizar `sdd-archive` para propagar hallazgos reutilizables a `docs/known-issues.md` y `docs/workflow-changelog.md` `[XREF-06]`
  - **Archivos**: `.agents/skills/sdd-archive/SKILL.md`, `docs/known-issues.md`, `docs/workflow-changelog.md`
  - **Depende de**: 4.1
  - **Criterio**: archive documenta cuándo un hallazgo de impacto cruzado se transforma en lección del workflow o cambio permanente

- [x] 4.3 Documentar la práctica nueva en la interfaz pública y en la guía operativa, respetando forward-only `[XREF-06]`
  - **Archivos**: `README.md`, `docs/workflow-guide.md`, `.agents/commands/sdd/propose.md`, `.agents/commands/sdd/verify.md`, `.agents/commands/sdd/archive.md`
  - **Depende de**: 4.1, 4.2
  - **Criterio**: la documentación explica cuándo aplica el mapa, cómo convive con changes viejos y cómo se verifica

- [x] 4.4 Crear evidencia estática de ejemplo para un change obligatorio y uno opcional `[XREF-02]`
  - **Archivos**: `openspec/changes/` en fixtures de documentación o ejemplos equivalentes
  - **Depende de**: 2.1, 4.3
  - **Criterio**: existe al menos un ejemplo operativo que muestre clasificación obligatoria y otro que muestre omisión justificada