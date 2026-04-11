---
name: "SDD: FF"
description: "Fast-forward: ejecutar todas las fases pendientes sin pausa"
---

Fast-forward de un change: ejecutar TODAS las fases pendientes hasta `archive`.

Si no se indica nombre, listar changes activos y preguntar.

Leer `.agents/orchestrator.md`. Forzar modo `auto` para esta ejecucion.

Resolver cada siguiente fase usando artefactos + `state.md`, no solo el nombre de la fase actual.

Ejecutar cada fase compatible en orden segun el grafo de dependencias.
Detenerse solo si una fase retorna `status: blocked`.
