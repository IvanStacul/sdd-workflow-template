---
name: sdd-apply
description: "Implementar tareas de un change leyendo specs como fuente de verdad y usando tasks.md como continuidad entre lotes. Usar cuando el usuario ejecuta /sdd:apply o cuando el orquestador lanza implementacion."
metadata:
  version: "2.0"
---

## Purpose

Implementar las tareas pendientes del change respetando specs, design, reglas del proyecto y el plan definido en `tasks.md`.

`tasks.md` y `state.md` son la continuidad oficial entre lotes. Esta fase no depende de memoria conversacional: tiene que poder retomarse solo leyendo esos archivos.

Sos un EJECUTOR - implementá el código directamente. NO lances subagentes.

## Inputs

- Nombre del change (opcional si hay uno solo activo).
- Opcionalmente, tareas específicas a implementar (por ejemplo `1.2` y `2.1`) o un lote puntual.

Si no se especifica nombre, buscar changes activos en `openspec/changes/`. Si hay exactamente uno, usarlo. Si hay varios, preguntar cuál. Siempre anunciar qué change se está usando antes de empezar.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change y devolver el envelope común al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/tasks.md` - el plan de trabajo
- `openspec/changes/{change-name}/specs/` - la fuente de verdad del comportamiento del change
- `openspec/changes/{change-name}/design.md` si existe
- `openspec/changes/{change-name}/state.md`
- `docs/known-issues.md` si existe - para evitar repetir bugs ya conocidos
- `_shared/abstraction-guide.md`

Si `openspec/config.yaml` define `rules.apply`, tratarlas como reglas locales de esta fase. Pueden agregar restricciones de implementacion, quality gates o formas de registrar evidencia; complementan esta skill, no la reemplazan.

## Steps

### Step 1: Resolver el lote

Si el usuario especificó tareas, usar exactamente esas tareas.

Si no especificó tareas, tomar las primeras tareas pendientes `- [ ]` cuyas dependencias ya estén completadas `- [x]`.

La continuidad entre lotes se resuelve SOLO con:

- `tasks.md` para saber que ya está hecho, que está pendiente y que está bloqueado
- `state.md` para entender decisiones, archivos afectados y contexto acumulado

No inventes un lote nuevo ignorando dependencias ni empieces por tareas marcadas `[~]` sin entender antes por qué quedaron bloqueadas.

### Step 2: Resolver modo de testing

Leer desde config:

- `testing.strict_tdd`
- `testing.test_command`

Usar fallback legacy solo si faltan esas claves:

- `tdd`
- `test_command`

Esto define si la fase tiene que cargar reglas extra de TDD estricto antes de escribir código.

### Step 3: Cargar modulo local si aplica

Si `testing.strict_tdd: true`, cargar `strict-tdd.md` antes de implementar.

Si esta en `false`, no cargar reglas extra y seguir el flujo normal de implementacion.

### Step 4: Implementar cada tarea

Para cada tarea del lote, comunicar progreso antes de empezar:

```
Tarea 3/7: {descripción breve}
```

Luego:

1. leer el requirement referenciado en la spec
2. leer `design.md` si esa tarea depende de decisiones estructurales
3. leer los archivos listados en la tarea si ya existen
4. implementar siguiendo la spec como fuente de verdad del QUE
5. verificar que el criterio de la tarea se cumple
6. marcar `[x]` solo cuando la tarea este realmente completa

**Cuando una tarea se bloquea**, no reportar en abstracto. Presentar opciones concretas:

```
## Pausa en tarea {N}: {descripción}

**Problema**: {qué pasó}

**Opciones**:
1. {opción A}
2. {opción B}
3. Otra dirección

¿Cómo seguimos?
```

Marcar `[~]` y documentar el motivo en `tasks.md`.

**Si la spec está mal, es ambigua o incompleta**: no improvisar comportamiento fuera de la spec. Detener la tarea y sugerir qué artefacto necesita actualizarse (spec, design, proposal). El usuario decide si actualizar ahora o diferir.

### Step 5: Registrar avance

Actualizar:

- `tasks.md` para reflejar el estado real de cada tarea del lote
- `state.md` siguiendo `_shared/phase-common.md`
- la tabla de archivos afectados dentro de `state.md`

Registrar cada archivo creado o modificado con el requirement correspondiente. Ese rastro lo usan despues `verify` y `archive`.

### Step 6: Resumen de sesión

Antes de cerrar, mostrar qué se hizo en este batch:

```
## Progreso: {change-name}

**Completadas en este batch**: {N}
- [x] {tarea completada 1}
- [x] {tarea completada 2}

**Progreso total**: {completadas}/{total}
**Bloqueadas**: {lista si hay, o "ninguna"}
```

### Step 7: Determinar el siguiente paso

Al cerrar la fase:

- si todavia quedan tareas pendientes o bloqueadas, el siguiente paso sigue siendo `sdd-apply`
- si todas las tareas relevantes del change quedaron completas, el siguiente paso es `sdd-verify`

## Persistence

Escribir o actualizar:

- `openspec/changes/{change-name}/tasks.md`
- `openspec/changes/{change-name}/state.md`

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/{change-name}/tasks.md
  - openspec/changes/{change-name}/state.md
next: "sdd-apply o sdd-verify"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

## Rules

- SIEMPRE leer la spec antes de implementar; la spec es la fuente de verdad.
- No implementar tareas no asignadas en el lote actual.
- Usar `tasks.md` y `state.md` como unica continuidad entre lotes.
- Consultar `docs/known-issues.md` si existe antes de repetir patrones riesgosos.
- Cargar reglas extra locales solo si `testing.strict_tdd: true`.
- Marcar `[x]` en `tasks.md` solo cuando la tarea este realmente completa.
- Si una tarea queda bloqueada, usar `[~]` y documentar el motivo.
- Si la spec es incorrecta o incompleta, detenerse y sugerir qué artefacto actualizar.
- Comunicar progreso visible: qué tarea se está implementando y resumen al cerrar el batch.

## Optional Modules

- `testing.strict_tdd`: activa `strict-tdd.md`.
