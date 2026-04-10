---
name: "OPSX: Continue"
description: "Continuar un change existente desde donde quedó"
---

Continuar un change existente.

Si no se indica nombre:
1. Listar changes activos en `openspec/changes/` (excluir archive/)
2. Para cada uno, leer state.md → "Fase Actual"
3. Mostrar al usuario y preguntar cuál continuar

Leer `.agents/orchestrator.md` para determinar la siguiente fase según el grafo de dependencias.

Ejecutar la siguiente fase pendiente.
