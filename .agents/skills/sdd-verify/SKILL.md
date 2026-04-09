---
name: sdd-verify
description: >
  Verificar que la implementación cumple con las specs. Comparar código vs escenarios.
  Trigger: Después de completar todas las tareas de un change.
metadata:
  version: "1.0"
---

## Purpose

Validar que la implementación cumple con las specs. Comparar cada scenario de cada spec contra el código implementado. Reportar discrepancias.

Sos un EJECUTOR. NO lances subagentes.

## What You Receive

- Nombre del change

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

Leer OBLIGATORIAMENTE:
- `openspec/changes/{change-name}/specs/` — todas las specs
- `openspec/changes/{change-name}/tasks.md` — verificar que todas las tareas estén `[x]`
- `openspec/changes/{change-name}/state.md` — tabla de archivos afectados

Consultar:
- `_shared/abstraction-guide.md` — para evaluar si las abstracciones son correctas

### Step 2: Verificar tareas

Si hay tareas pendientes `[ ]` o bloqueadas `[~]`, reportar como ADVERTENCIA.

### Step 3: Verificar specs vs código

Para CADA spec del change:
1. Leer la spec completa
2. Para CADA scenario, verificar en el código que se implementó correctamente
3. Para CADA edge case, verificar que está cubierto
4. Usar la tabla de archivos afectados de state.md como guía de dónde buscar

### Step 4: Ejecutar tests (si hay)

Si `openspec/config.yaml` tiene `test_command`:
- Ejecutar el comando
- Reportar resultado

### Step 5: Escribir verify-report.md

```markdown
# Verificación — {change-name}

## Resumen
- **Estado**: {✅ PASS | ⚠️ PASS con advertencias | ❌ FAIL}
- **Specs verificadas**: {N}
- **Scenarios verificados**: {N}
- **Edge cases verificados**: {N}

## Detalle por Spec

### {NNN-capability}

| Requirement | Scenarios | Edge Cases | Estado |
|------------|-----------|------------|--------|
| {nombre} | {N/N} ✅ | {N/N} ✅ | PASS |
| {nombre} | {N/N} ⚠️ | {N/N} ❌ | FAIL |

### Issues Encontrados

#### CRÍTICO — {descripción}
- **Spec**: {requirement y scenario}
- **Código**: `{path/to/file}:{línea}`
- **Problema**: {qué no cumple}

#### ADVERTENCIA — {descripción}
- **Detalle**: {qué podría mejorar}

#### SUGERENCIA — {descripción}
- **Detalle**: {mejora opcional}

## Tests
- **Comando**: `{test_command}`
- **Resultado**: {PASS/FAIL}
- **Cobertura**: {si aplica}

## Decisión
{Si hay CRÍTICOs → NO archivar. Si solo advertencias/sugerencias → puede archivar.}
```

### Step 6: Persistir

Seguir **Sección C** de `_shared/phase-common.md`.

### Step 7: Retornar resumen

Seguir **Sección F** de `_shared/phase-common.md`.

## Rules

- Verificar CADA scenario de CADA spec — no saltear ninguno
- Verificar CADA edge case documentado
- CRÍTICO = la spec no se cumple → bloquea archive
- ADVERTENCIA = funciona pero podría mejorar → no bloquea
- SUGERENCIA = mejora opcional → no bloquea
- Si se detecta código que viola `_shared/abstraction-guide.md`, reportar como ADVERTENCIA
- Si se detecta un bug conocido de `docs/known-issues.md` que no se evitó, reportar como ADVERTENCIA
- Aplicar reglas de `openspec/config.yaml` sección `rules.verify` si existen
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
