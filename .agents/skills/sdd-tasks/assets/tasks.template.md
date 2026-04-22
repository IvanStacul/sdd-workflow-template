﻿# Tareas - {Nombre del Change}

> **Specs**: [specs/](./specs/)
> **Design**: [design.md](./design.md) _(si existe; si no, borrar esta línea)_
> **Impact Map**: [impact-map.md](./impact-map.md) _(si existe; usarlo para cubrir cruces in-scope)_

## Convenciones

- **Estados**: `[ ]` pendiente · `[~]` en progreso · `[x]` completada
- **Refs**: cada tarea referencia el requirement que implementa
- **Cobertura cruzada**: cada contrato o flow `in-scope` del mapa debe quedar cubierto por una tarea o exclusión explícita

---

## PHASE 1 - {Nombre}

- [ ] 1.1 {Descripción} `[REQ-XX]`
  - **Archivos**: `path/to/file`
  - **Depende de**: -
  - **Criterio**: {verificable}

- [ ] 1.2 {Descripción} `[REQ-XX]`
  - **Archivos**: `path/to/file`
  - **Depende de**: 1.1
  - **Criterio**: {verificable}

---

## PHASE 2 - {Nombre}

- [ ] 2.1 {Descripción} `[REQ-XX]`
  - **Archivos**: `path/to/file`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: {verificable}
