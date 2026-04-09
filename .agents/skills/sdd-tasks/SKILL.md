---
name: sdd-tasks
description: >
  Descomponer specs y diseño en tareas implementables con dependencias.
  Trigger: Después de spec (y opcionalmente design) para crear el plan de trabajo.
metadata:
  version: "1.0"
---

## Purpose

Tomar las specs y el diseño y producir una lista de tareas implementables, agrupadas por fase, con dependencias claras. Cada tarea debe ser completable en una sesión.

Sos un EJECUTOR. NO lances subagentes.

## What You Receive

- Nombre del change
- Specs + Design (si existe) ya creados

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

Leer OBLIGATORIAMENTE:
- `openspec/changes/{change-name}/specs/` — todas las specs
- `openspec/changes/{change-name}/design.md` (si existe)

Consultar:
- `_shared/abstraction-guide.md` — para decidir qué archivos/funciones crear

### Step 2: Escribir tasks.md

Usar el template de `assets/tasks.template.md`.

#### Estructura de tareas

```markdown
# Tareas — {Nombre del Change}

> **Specs**: [specs/](./specs/)
> **Design**: [design.md](./design.md)

## Convenciones
- **Estados**: `[ ]` pendiente · `[~]` en progreso · `[x]` completada
- **Refs**: cada tarea referencia el requirement que implementa

---

## PHASE 1 — {Nombre de la fase}

- [ ] 1.1 {Descripción de la tarea} `[REQ-XX]`
  - **Archivos**: `path/to/file.ext`
  - **Depende de**: —
  - **Criterio**: {cuándo está completa — verificable}

- [ ] 1.2 {Descripción} `[REQ-XX]`
  - **Archivos**: `path/to/file.ext`
  - **Depende de**: 1.1
  - **Criterio**: {verificable}

## PHASE 2 — {Nombre}

- [ ] 2.1 {Descripción} `[REQ-XX]`
  - **Archivos**: `path/to/file.ext`, `path/to/other.ext`
  - **Depende de**: 1.1, 1.2
  - **Criterio**: {verificable}
```

### Step 3: Persistir

Seguir **Sección C** de `_shared/phase-common.md`.

### Step 4: Retornar resumen

```markdown
## Tareas Creadas

**Change**: {change-name}

| Fase | Tareas | Estimación |
|------|--------|------------|
| {nombre} | {N} | {sesiones estimadas} |

**Total**: {N} tareas en {N} fases

### Siguiente paso
sdd-apply para comenzar la implementación.
```

## Rules

- Cada tarea DEBE referenciar el requirement que implementa `[REQ-XX]`
- Cada tarea DEBE listar los archivos que se crean/modifican
- Cada tarea DEBE tener un criterio verificable
- Las tareas deben ser PEQUEÑAS — completables en una sesión
- Consultar `_shared/abstraction-guide.md` para decidir estructura de archivos
- Si el cambio es muy grande (>20 tareas), recomendar dividir en múltiples changes
- El formato de checkbox `- [ ]` es OBLIGATORIO — sdd-apply parsea este formato
- Aplicar reglas de `openspec/config.yaml` sección `rules.tasks` si existen
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
