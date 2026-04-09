---
name: sdd-archive
description: >
  Archivar un change completado. Retro obligatoria, merge de delta specs,
  propagación de bugs/lecciones, y mejora continua del flujo.
  Trigger: Después de verificar un change exitosamente.
metadata:
  version: "1.0"
---

## Purpose

Cerrar el ciclo SDD de un change. Hacer retro, mergear deltas specs a las specs principales, propagar lecciones, y mover a archive. Es la fase más importante para la mejora continua.

Sos un EJECUTOR. NO lances subagentes.

## What You Receive

- Nombre del change

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

Leer OBLIGATORIAMENTE:
- `openspec/changes/{change-name}/verify-report.md`
- `openspec/changes/{change-name}/specs/` — todos los delta specs
- `openspec/changes/{change-name}/state.md` — log completo de fases, decisiones, archivos
- `docs/known-issues.md`
- `docs/workflow-changelog.md`

### Step 2: Verificar precondiciones

- Si verify-report tiene issues CRÍTICOS → DETENERSE. No archivar.
- Si hay tareas pendientes `[ ]` → ADVERTIR y preguntar si continuar.

### Step 3: Retro OBLIGATORIA

La retro NO es opcional. Escribir `retro.md` en el directorio del change.

Usar template de `assets/retro.template.md`:

```markdown
# Retro — {change-name}

## ¿Qué salió bien?
- {aspecto positivo del proceso}

## ¿Qué salió mal?
- {problema encontrado}

## ¿Qué aprendimos?

### Bugs encontrados
| ID | Bug | Causa raíz | Prevención |
|----|-----|-----------|------------|

### Lecciones
| ID | Lección | Tipo | Acción sugerida |
|----|---------|------|-----------------|
{Tipo: Arquitectura | Flujo | Negocio | Tooling}

## Mejoras al flujo
| Propuesta | Skill/Archivo afectado | Prioridad |
|-----------|----------------------|-----------|

## Decisiones a preservar
{Decisiones importantes del state.md que deben quedar como referencia}
```

### Step 4: Propagar bugs y lecciones

#### A `docs/known-issues.md`:
- Agregar cada bug de la retro en formato estándar (ver template del archivo)
- Agregar lecciones en la tabla correspondiente según tipo

#### A `docs/workflow-changelog.md`:
- Si la retro propone mejoras al flujo, agregar entrada con estado `propuesta`

#### A skills (mejora continua):
Si una mejora al flujo es CONCRETA y de bajo riesgo:
1. Evaluar si el cambio afecta un SKILL.md o un archivo de `_shared/`
2. Verificar la política de templates (forward-only: solo afecta artefactos nuevos)
3. Aplicar el cambio Y marcar la entrada en workflow-changelog como `aplicada`

Si la mejora es COMPLEJA o RIESGOSA:
- Dejar como `propuesta` en workflow-changelog
- Advertir al usuario para que lo revise manualmente

### Step 5: Sync delta specs a specs principales

Para cada delta spec en `openspec/changes/{change-name}/specs/`:

#### Si la spec principal EXISTE (`openspec/specs/{NNN-capability}/spec.md`):

```
PARA CADA sección en el delta:
├── ADDED Requirements → Append al final de Requirements
├── MODIFIED Requirements → Reemplazar el requirement que coincida por nombre
└── REMOVED Requirements → Eliminar el requirement que coincida
```

**Merge cuidadoso**:
- Matchear requirements por nombre (`### Requirement: {nombre}`)
- PRESERVAR requirements que no están en el delta
- Mantener formato Markdown correcto
- Mergear la sección Edge Cases (agregar nuevos, actualizar existentes)

#### Si la spec principal NO EXISTE:

El delta spec ES una spec completa → copiar directamente a `openspec/specs/{NNN-capability}/spec.md`.

### Step 6: Mover a archive

```bash
mv openspec/changes/{change-name} openspec/changes/archive/{change-name}
```

Notar: el change-name YA incluye la fecha como prefijo (`spec-YYYY-MM-DD-NN-slug`), así que no se agrega fecha extra al archivar.

### Step 7: Persistir

Seguir **Sección C** de `_shared/phase-common.md`.

### Step 8: Retornar resumen

```markdown
## Change Archivado

**Change**: {change-name}
**Archivado en**: `openspec/changes/archive/{change-name}/`

### Specs sincronizadas
| Capability | Acción | Detalle |
|-----------|--------|---------|
| {NNN-nombre} | Creada/Actualizada | {N added, M modified, K removed} |

### Retro
- Bugs registrados: {N}
- Lecciones registradas: {N}
- Mejoras al flujo: {N propuestas, N aplicadas}

### Propagación
- known-issues.md: {✅ actualizado | ℹ️ sin cambios}
- workflow-changelog.md: {✅ actualizado | ℹ️ sin cambios}
- Skills modificadas: {lista o "Ninguna"}

### Ciclo SDD completo ✅
```

## Rules

- NUNCA archivar un change con issues CRÍTICOS en verify-report
- La retro es OBLIGATORIA — no saltearla nunca
- SIEMPRE sincronizar delta specs ANTES de mover a archive
- Al mergear, PRESERVAR requirements que no están en el delta
- Los bugs de la retro DEBEN propagarse a known-issues.md
- Las mejoras al flujo se registran en workflow-changelog.md
- Mejoras concretas y de bajo riesgo se aplican directamente a los skills
- Mejoras complejas quedan como `propuesta` para revisión humana
- Templates forward-only: cambios a templates NO migran artefactos existentes
- El archive es INMUTABLE — nunca modificar changes archivados
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
