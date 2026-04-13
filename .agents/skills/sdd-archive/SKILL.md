---
name: sdd-archive
description: "Cerrar un change, escribir retro obligatoria, propagar bugs o lecciones y sincronizar delta specs a la fuente de verdad. Usar cuando el usuario ejecuta /sdd:archive después de verify."
metadata:
  version: "2.0"
---

## Purpose

Cerrar el ciclo SDD de un change: escribir la retro obligatoria, sincronizar las delta specs a `openspec/specs/`, propagar bugs y lecciones, y mover el change a `openspec/changes/archive/`.

Esta fase es la que transforma trabajo en curso en audit trail útil para cambios futuros. Si se hace mal, se pierde trazabilidad o se corrompe la fuente de verdad.

Sos un EJECUTOR - archiva directamente. NO lances subagentes.

## Inputs

- Nombre del change (opcional si hay uno solo activo).

Si no se específica nombre, buscar changes activos en `openspec/changes/`. Si hay exactamente uno, usarlo. Si hay varios, preguntar cuál. Siempre anunciar qué change se está archivando antes de empezar.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change y devolver el envelope comun al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/verify-report.md`
- `openspec/changes/{change-name}/tasks.md`
- `openspec/changes/{change-name}/specs/` - todos los delta specs del change
- `openspec/changes/{change-name}/state.md`
- `docs/known-issues.md` si existe
- `docs/workflow-changelog.md` si existe

Si `openspec/config.yaml` define `rules.archive`, tratarlas como reglas locales de esta fase. Pueden agregar pasos de cierre, formatos de retro o checks extra antes de archivar; complementan esta skill, no la reemplazan.

## Steps

### Step 1: Verificar precondiciones

Detenerse si `verify-report.md` contiene `CRITICAL`. Un change con `CRITICAL` no se archiva.

Si quedan tareas `[ ]` o `[~]`, presentar un warning estructurado antes de pedir confirmación:

```
## Warning: tareas incompletas

**Pendientes**: {N} tareas `[ ]`
**Bloqueadas**: {M} tareas `[~]`

Archivar con trabajo pendiente significa que esas tareas se pierden del flujo activo.

**Opciones**:
1. Continuar archivando (las tareas quedan documentadas en la retro)
2. Cancelar y volver a apply
```

También verificar que existan los artefactos mínimos de cierre:

- `verify-report.md`
- `state.md`
- delta specs del change, si el change modificaba comportamiento especificado

### Step 2: Escribir retro obligatoria

La retro NO es opcional. Crear o actualizar `openspec/changes/{change-name}/retro.md` usando `assets/retro.template.md`.

Nombrar el template en este punto es importante: esta fase depende de ese asset para que la retro no quede reducida a texto libre sin bugs, lecciones o mejoras accionables.

La retro debe incluir como mínimo:

- que salio bien
- que salio mal
- bugs encontrados
- lecciones aprendidas
- mejoras propuestas al workflow
- decisiones a preservar desde `state.md`

### Step 3: Propagar bugs, lecciones y mejoras

Actualizar `docs/known-issues.md` y `docs/workflow-changelog.md` si existen.

Propagación esperada:

- cada bug relevante de la retro debe quedar registrado en `docs/known-issues.md`
- las lecciones deben registrarse con un tipo útil (`Arquitectura`, `Flujo`, `Negocio`, `Tooling` o similar)
- las mejoras al workflow deben quedar en `docs/workflow-changelog.md`

Si una mejora al flujo es concreta, de bajo riesgo y claramente correcta:

1. evaluar si afecta un `SKILL.md`, un template o un archivo de `_shared/`
2. respetar la politica forward-only de templates
3. aplicar el cambio y registrar la entrada como `aplicada`

Si la mejora es compleja, riesgosa o requiere criterio humano:

- dejarla como `propuesta`
- no forzar el cambio durante archive

Si `docs/known-issues.md` o `docs/workflow-changelog.md` no existen, no bloquear el archive solo por eso. Reportarlo como observación y continuar.

### Step 4: Sincronizar delta specs a specs consolidadas

Antes de sincronizar, mostrar un preview de qué va a cambiar:

```
## Sync de delta specs

- `{capability-1}`: {N} requirements agregados, {M} modificados, {K} eliminados
- `{capability-2}`: spec nueva (no existe consolidada)

¿Procedo con la sincronización?
```

Esperar confirmación. Luego, para cada delta spec en `openspec/changes/{change-name}/specs/`:

#### Si la spec consolidada YA existe

Mergear con cuidado:

- `ADDED Requirements` -> agregar al final de `Requirements`
- `MODIFIED Requirements` -> reemplazar el requirement completo que coincida por nombre
- `REMOVED Requirements` -> eliminar el requirement que coincida

Reglas del merge:

- matchear requirements por nombre (`### Requirement: {nombre}`)
- preservar requirements no mencionados en el delta
- mantener formato markdown correcto
- mergear `Edge Cases` sin perder los existentes utiles

#### Si la spec consolidada NO existe

El delta spec funciona como spec inicial -> copiarla a `openspec/specs/{NNN-capability}/spec.md`.

Esta parte debe ser cuidadosa porque `sdd-spec` ya exige bloques completos para `MODIFIED`. Archive no debe reconstruir comportamiento por inferencia.

### Step 5: Registrar fase final en `state.md`

Antes de mover el directorio del change:

- actualizar `state.md` siguiendo `_shared/phase-common.md`
- registrar la retro y la sincronización de specs como parte del cierre

Una vez archivado el change, ese directorio pasa a ser inmutable.

### Step 6: Mover el change a archive

Mover `openspec/changes/{change-name}/` a `openspec/changes/archive/{change-name}/`.

No agregar fecha extra: el nombre del change ya incluye su prefijo con fecha.

### Step 7: Resumen de cierre

Mostrar un resumen estructurado del archive:

```
## Archive completo

**Change**: {change-name}
**Archivado en**: openspec/changes/archive/{change-name}/
**Specs sincronizadas**: {lista de capabilities sincronizadas, o "sin delta specs"}
**Bugs propagados**: {N a known-issues, o "ninguno"}
**Mejoras al workflow**: {N registradas, K aplicadas, o "ninguna"}
```

## Persistence

Escribir o actualizar, antes de mover:

- `openspec/specs/.../spec.md`
- `openspec/changes/{change-name}/retro.md`
- `openspec/changes/{change-name}/state.md`
- `docs/known-issues.md` si existe o si se decide crearlo
- `docs/workflow-changelog.md` si existe o si se decide crearlo

Luego mover el change al archive.

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/archive/{change-name}/retro.md
  - openspec/specs/.../spec.md
next: "ninguno"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

## Rules

- NUNCA archivar un change con `CRITICAL` en `verify-report.md`.
- La retro es OBLIGATORIA.
- SIEMPRE sincronizar delta specs ANTES de mover a archive.
- Al mergear, preservar requirements no mencionados en el delta.
- Los bugs relevantes de la retro deben propagarse a `docs/known-issues.md`.
- Las mejoras al flujo deben registrarse en `docs/workflow-changelog.md`.
- Mejoras concretas y de bajo riesgo se pueden aplicar directamente.
- Mejoras complejas quedan como `propuesta` para revision humana.
- Templates forward-only: cambios a templates NO migran artefactos existentes.
- El archive es INMUTABLE: no modificar changes archivados.

## Optional Modules

- No hay módulos obligatorios.
