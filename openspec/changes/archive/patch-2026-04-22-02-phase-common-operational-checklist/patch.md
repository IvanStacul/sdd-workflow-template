# Patch - checklist operativa compartida en phase-common

## Motivacion
El patch anterior dejo guardrails importantes distribuidos en varias skills, pero todavia faltaba una capa comun que los recordara desde el protocolo compartido. Si esas reglas no viven tambien en `_shared/phase-common.md`, cada skill nueva o reescrita puede volver a omitirlas.

## Cambio
Se agrega una checklist operativa compartida en `_shared/phase-common.md` para recordar cinco guardrails transversales: materializar cortes de scope, exigir contrato/validacion minima en slices riesgosos, no adelantar `state.md`, hacer visible el drift entre spec/codigo/decisiones y reconciliar decisiones antes de consolidar specs.

Tambien se actualiza la documentacion permanente para que la mejora quede registrada tanto en workflow-changelog como en la leccion ya existente de known-issues.

## Archivos

| Archivo | Accion | Detalle |
|---------|--------|---------|
| `.agents/skills/_shared/phase-common.md` | Modificado | Agrega checklist compartida de guardrails operativos para todas las fases que cargan phase-common |
| `docs/known-issues.md` | Modificado | Amplia la accion tomada de L-W-02 para incluir la centralizacion en phase-common |
| `docs/workflow-changelog.md` | Modificado | Registra la nueva mejora aplicada al workflow |

## Spec afectada
Ninguna

## Decisiones
| # | Decision | Tipo | Justificacion |
|---|----------|------|---------------|
| D-01 | Centralizar estas guardas en `phase-common` y no repetirlas skill por skill | Decision de diseño | `phase-common` ya es el protocolo comun de las fases y lo leen 8 skills, asi que es el punto de herencia mas barato para fijar memoria operativa compartida |

## Verificacion
- [x] Revisar el diff focalizado de `phase-common.md`, `docs/known-issues.md` y `docs/workflow-changelog.md`
- [x] Archivar el patch en `openspec/changes/archive/patch-2026-04-22-02-phase-common-operational-checklist/`