# Fuentes del Workflow SDD

Este documento no explica como usar el workflow dia a dia. Para eso, la guía operativa es `docs/workflow-guide.md`.

Aca se resume que se adopta y que se descarta de las referencias externas que inspiraron este template.

## Matriz de adopcion

| Fuente | Se adopta | Se rechaza |
|--------|-----------|------------|
| OpenSpec | `openspec/specs/`, `openspec/changes/`, delta specs y `archive/` como merge a la fuente de verdad | Depender de CLI, perfiles globales o estado fuera del repo para entender el flujo |
| gentle-ai | Orquestacion capability-aware, coordinacion por fases, subagentes, personalidad y envelope comun de retorno | Memoria externa, almacenamiento hibrido y dependencias en backends |
| agent-skills | Anatomia de skills, quality gates, evidencia verificable y modulos opt-in | Reemplazar el workflow por un catalogo genérico de skills sin contrato entre fases |

## Consecuencias concretas en este template

- `.agents/` es la fuente de verdad operativa del workflow.
- La interfaz pública se expone como comandos `/sdd:*`.
- `propose`, `spec`, `design` y `tasks` siguen existiendo como fases internas, aunque no se documenten como comandos públicos separados.
- Todo el estado durable vive en archivos Markdown dentro del repo.
- `docs/` explica y contextualiza; no reemplaza el contrato operativo de `.agents/`.

## Modulos opcionales

Los modulos que pueden activarse por proyecto en `openspec/config.yaml` son:

- `testing.strict_tdd`
- `modules.skill_registry`
- `modules.model_routing`

Regla de producto: estos modulos agregan comportamiento, pero no cambian la estructura base del workflow y deben degradar con seguridad cuando estan desactivados.
