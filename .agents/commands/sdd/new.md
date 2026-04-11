---
name: "SDD: New"
description: "Crear un nuevo change completo"
---

Crear un nuevo change.

Leer `.agents/orchestrator.md` para el protocolo de coordinacion.

Secuencia esperada: `sdd-propose` -> `sdd-spec` -> pasar por `sdd-design` como gate tecnico -> `sdd-tasks`.
Si `sdd-design` determina que no hace falta `design.md`, igual deja al change listo para continuar sin ese artefacto.

En modo interactivo: pausar entre fases.
En modo auto: ejecutar todas sin pausa.
