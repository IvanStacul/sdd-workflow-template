---
name: "SDD: Continue"
description: "Continuar un change existente desde donde quedo"
---

Continuar un change existente.

Si no se indica nombre:
1. Listar changes activos en `openspec/changes/` (excluir `archive/`).
2. Para cada uno, leer `state.md` y `Fase Actual`.
3. Mostrar al usuario cual puede continuar.

Leer `.agents/orchestrator.md` para determinar la siguiente fase segun el grafo de dependencias.

No usar solo `Fase Actual`: contrastar `state.md` con los artefactos reales del change antes de decidir.

Ejecutar la siguiente fase compatible.
