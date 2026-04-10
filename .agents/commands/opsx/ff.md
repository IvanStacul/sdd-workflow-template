---
name: "OPSX: FF"
description: "Fast-forward: ejecutar todas las fases pendientes sin pausa"
---

Fast-forward de un change: ejecutar TODAS las fases pendientes hasta archive.

Si no se indica nombre, listar changes activos y preguntar.

Leer `.agents/orchestrator.md`. Forzar modo auto para esta ejecución.

Ejecutar cada fase pendiente en orden según el grafo de dependencias.
Detenerse SOLO si una fase retorna estado `blocked`.
