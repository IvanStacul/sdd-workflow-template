---
name: "OPSX: New"
description: "Crear un nuevo change completo (propuesta + specs + design + tasks)"
---

Crear un nuevo change. Si el usuario no dio nombre, preguntar.

Leer `.agents/orchestrator.md` para el protocolo de coordinación.

Secuencia: propose → spec → design (si aplica) → tasks.

En modo interactivo: pausar entre fases.
En modo auto: ejecutar todas sin pausa.

Invocar las skills en orden: `sdd-propose`, `sdd-spec`, `sdd-design` (si aplica), `sdd-tasks`.
