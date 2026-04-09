---
name: sdd-apply
description: >
  Implementar tareas del plan de trabajo, marcando progreso en tasks.md.
  Trigger: Cuando el usuario quiere implementar tareas de un change.
metadata:
  version: "1.0"
---

## Purpose

Implementar las tareas pendientes del plan de trabajo. Leer specs como fuente de verdad de QUÉ, design como guía de CÓMO, y marcar cada tarea como completada.

Sos un EJECUTOR — implementá el código directamente. NO lances subagentes.

## What You Receive

- Nombre del change
- Opcionalmente: tareas específicas a implementar (ej: "tareas 2.1 y 2.2")

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

Leer OBLIGATORIAMENTE:
- `openspec/changes/{change-name}/tasks.md` — el plan de trabajo
- `openspec/changes/{change-name}/specs/` — las specs (fuente de verdad de comportamiento)
- `openspec/changes/{change-name}/design.md` (si existe)
- `docs/known-issues.md` — verificar bugs conocidos relevantes

Consultar:
- `_shared/abstraction-guide.md` — antes de crear archivos/funciones

### Step 2: Seleccionar tareas

Si el usuario especificó tareas → usar esas.
Si no → tomar las siguientes tareas pendientes `[ ]` cuyas dependencias estén completadas `[x]`.

### Step 3: Implementar

Para cada tarea:

1. Leer el requirement referenciado en la spec
2. Leer los archivos listados en la tarea (si ya existen)
3. Implementar siguiendo la spec y el design
4. Verificar que el criterio de la tarea se cumple

**Si TDD está habilitado** (`openspec/config.yaml` → `tdd: true`):
1. Escribir test que falla primero
2. Implementar código mínimo para que pase
3. Refactorizar si es necesario

### Step 4: Marcar progreso

En `tasks.md`, cambiar `[ ]` por `[x]` para cada tarea completada.

### Step 5: Persistir

Seguir **Sección C** de `_shared/phase-common.md`.

IMPORTANTE: registrar cada archivo creado/modificado en la tabla "Archivos Afectados" de `state.md` con el requirement que implementa.

### Step 6: Retornar resumen

```markdown
## Tareas Implementadas

**Change**: {change-name}
**Lote**: {tareas implementadas}

| Tarea | Estado | Archivos |
|-------|--------|----------|
| {N.N} | ✅ Completada | `path/to/file` |

### Progreso total
{N}/{M} tareas completadas

### Siguiente paso
{Más tareas pendientes → sdd-apply | Todas completas → sdd-verify}
```

## Rules

- SIEMPRE leer la spec antes de implementar — la spec es la fuente de verdad
- SIEMPRE consultar `_shared/abstraction-guide.md` antes de decidir estructura
- SIEMPRE consultar `docs/known-issues.md` para evitar bugs repetidos
- Marcar `[x]` en tasks.md SOLO cuando la tarea está realmente completa
- Registrar CADA archivo en la tabla de archivos afectados de state.md
- Si una tarea no se puede completar, marcar como `[~]` y documentar el bloqueo
- Si durante la implementación se descubre que la spec tiene un error, DETENERSE y reportar
- Seguir convenciones de código existentes del proyecto
- Aplicar reglas de `openspec/config.yaml` sección `rules.apply` si existen
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
