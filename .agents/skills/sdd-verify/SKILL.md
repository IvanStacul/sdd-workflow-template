---
name: sdd-verify
description: "Verificar que la implementación cumple las specs usando evidencia estática y, cuando exista, evidencia de ejecución. Usar cuando el usuario ejecuta /sdd:verify o cuando todas las tareas de un change parecen completas."
metadata:
  version: "2.0"
---

## Purpose

Comparar specs, tasks, design y código para producir un `verify-report.md` basado en evidencia, no en impresiones.

Esta fase decide si el change está listo para pasar a `sdd-archive` o si todavía necesita volver a `sdd-apply`.

Sos un EJECUTOR - verifica directamente. No lances subagentes.

## Inputs

- Nombre del change.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change y devolver el envelope común al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/specs/`
- `openspec/changes/{change-name}/tasks.md`
- `openspec/changes/{change-name}/state.md`
- `openspec/changes/{change-name}/design.md` si existe
- `docs/known-issues.md` si existe
- `_shared/abstraction-guide.md`

Si `openspec/config.yaml` define `rules.verify`, tratarlas como reglas locales de esta fase. Pueden agregar checks, formatos de evidencia o quality gates extra; complementan esta skill, no la reemplazan.

## Steps

### Step 1: Resolver comandos de evidencia

Leer desde config:

- `testing.test_command`
- `testing.coverage_command`
- `testing.typecheck_command`
- `testing.strict_tdd`

Usar fallback legacy solo si faltan esas claves:

- `test_command`
- `tdd`

### Step 2: Validar completitud

Revisar `tasks.md` y clasificar:

- tareas completas
- tareas pendientes
- tareas bloqueadas

Si quedan tareas `[ ]` o `[~]`, reportarlo como observación relevante del reporte. Verify igual puede producir evidencia útil, pero no debe presentar el change como listo para archivar sin dejar esa situación explícitada.

### Step 3: Armar matriz scenario -> evidence

Para cada requirement y scenario:

1. buscar evidencia estructural en código
2. buscar tests relacionados
3. usar `state.md` y archivos afectados como guía para ubicar implementación relevante
4. si existe test runner, correrlo y capturar evidencia
5. marcar el scenario como:
   - `COMPLIANT`
   - `FAILING`
   - `UNTESTED`
   - `STATIC_ONLY`

`STATIC_ONLY` aplica cuando no existe runner o no puede ejecutarse.

No saltees scenarios ni edge cases documentados. El objetivo de verify es cubrir el change completo, no solo una muestra.

### Step 4: Ejecutar evidencia runtime

Si existe `testing.test_command`, ejecutarlo.
Si existe `testing.coverage_command`, ejecutarlo.
Si existe `testing.typecheck_command`, ejecutarlo.

Si no existe test runner:

- no declares cumplimiento runtime total
- registrar riesgo explícito en el reporte

### Step 5: Cargar módulo local si aplica

Si `testing.strict_tdd: true`, cargar `strict-tdd-verify.md`.

### Step 6: Escribir verify-report

Incluir:

- resumen
- estado de tasks (`[x]`, `[ ]`, `[~]`)
- build/tests/typecheck/coverage si existen
- matriz `scenario -> evidence`
- issues separados en `CRITICAL`, `WARNING`, `SUGGESTION`
- veredicto

Usar una estructura de este estilo:

```markdown
# Verificación - {change-name}

## Resumen
- Estado general: {PASS | PASS con warnings | FAIL}
- Tasks: {completas / pendientes / bloqueadas}
- Specs verificadas: {N}
- Scenarios revisados: {N}

## Evidencia Runtime
- Test command: {comando o "no configurado"}
- Typecheck: {resultado o "no configurado"}
- Coverage: {resultado o "no configurado"}

## Matriz Scenario -> Evidence

### {NNN-capability}
| Requirement | Scenario | Evidence | Estado |
|-------------|----------|----------|--------|

## Issues

### CRITICAL
- {issue que bloquea archive}

### WARNING
- {riesgo o falta importante no bloqueante}

### SUGGESTION
- {mejora opcional}

## Veredicto
{si puede pasar a archive o si debe volver a apply}
```

Guia de severidad:

- `CRITICAL`: el comportamiento requerido no se cumple o no hay evidencia suficiente para declararlo cumplido en un punto que bloquea cierre.
- `WARNING`: hay riesgo, deuda o falta de cobertura importante, pero no necesariamente bloquea.
- `SUGGESTION`: mejora opcional.

### Step 7: Registrar fase

Actualizar `state.md` siguiendo `_shared/phase-common.md`.

## Persistence

Escribir o actualizar:

- `openspec/changes/{change-name}/verify-report.md`
- `openspec/changes/{change-name}/state.md`

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/{change-name}/verify-report.md
next: "sdd-archive o sdd-apply"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

## Rules

- No declarar cumplimiento total sin evidencia.
- Si hay test runner, usarlo.
- Si no hay test runner, reportar `STATIC_ONLY` y un riesgo explícito.
- `CRITICAL` bloquea archive.
- Si hay tareas pendientes o bloqueadas, dejarlo explicitado en el reporte y en el veredicto.
- Verificar scenarios y edge cases del change, no solo tests existentes.
- No arregles issues en verify; solo reportalos.

## Optional Modules

- `testing.strict_tdd`: activa `strict-tdd-verify.md`.
