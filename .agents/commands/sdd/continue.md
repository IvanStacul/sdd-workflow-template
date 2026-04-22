---
name: "SDD: Continue"
description: "Continuar un change existente desde donde quedo"
---

Continuar un change existente.

Si no se indica nombre:
1. Listar changes activos en `openspec/changes/` (excluir `archive/`).
2. Para cada uno, leer `state.md` y `Fase Actual`.
3. Mostrar al usuario cual puede continuar.

Leer `.agents/orchestrator.md` para determinar la siguiente fase según el grafo de dependencias.
Si el change ya tiene `impact-map.md`, releerlo antes de decidir la fase siguiente y continuar actualizando ese mismo artefacto.

No usar solo `Fase Actual`: contrastar `state.md` con los artefactos reales del change antes de decidir.
No recrear `impact-map.md` si ya existe; solo refinarlo o registrar explícitamente que sigue sin cambios.

Ejecutar la siguiente fase compatible.
