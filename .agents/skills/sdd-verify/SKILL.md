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
- `impact-map.md` si existe.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change y devolver el envelope común al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/proposal.md`
- `openspec/changes/{change-name}/specs/`
- `openspec/changes/{change-name}/tasks.md`
- `openspec/changes/{change-name}/state.md`
- `openspec/changes/{change-name}/design.md` si existe
- `openspec/changes/{change-name}/impact-map.md` si existe
- `docs/known-issues.md` si existe
- `_shared/abstraction-guide.md`

Si `openspec/config.yaml` define `rules.verify`, tratarlas como reglas locales de esta fase. Pueden agregar checks, formatos de evidencia o quality gates extra; complementan esta skill, no la reemplazan.

## Steps

### Step 0: Phase guard

Antes de cualquier otra cosa, leer `state.md` y verificar que verify es la fase correcta:

- Si la última entrada de `state.md` indica que el change debe volver a `sdd-apply` (por ejemplo, un verify anterior devolvió issues CRITICAL), **DETENERSE INMEDIATAMENTE**.
- Mostrar:
  ```
  ⛔ El estado actual del change indica que debe volver a apply.
  Último verify: {fecha} — veredicto: {veredicto}
  Issues pendientes: {lista breve}
  
  Correr verify ahora sin aplicar los fixes va a producir el mismo resultado.
  Ejecutá /sdd:apply primero.
  ```
- No continuar con verify. No producir reporte. Devolver `status: blocked` con `next: sdd-apply`.

Esta guarda existe para evitar loops de apply → verify sin avance real. Si el usuario insiste, puede ejecutar `/sdd:apply` para resolver los issues y después volver a verify.

### Step 0.5: Pre-verificación de bugs conocidos

Si existe `docs/known-issues.md`, leerlo y buscar bugs con estado **Activo**.

Para cada bug activo que aplique al change actual:
1. Ir al código indicado en el bug
2. Confirmar si el fix está presente
3. Si el fix NO está, reportarlo inmediatamente como CRITICAL en el reporte sin esperar al final

Este paso previene que bugs ya diagnosticados y documentados aparezcan como "hallazgos nuevos" en el reporte, y evita iteraciones innecesarias.

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

Si existe `impact-map.md`, además construir una matriz complementaria `impact-map -> coverage` para revisar:

- dominios secundarios `in-scope`
- contratos o interfaces afectados
- downstream flows listados
- edge cases cross-domain
- exclusiones explícitas y su razón

Si el mapa contradice `proposal.md`, specs, `design.md` o `tasks.md`, registrar issue. Si un target `in-scope` no tiene cobertura o justificación suficiente, no declararlo cumplido.

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
- cobertura del `impact-map.md` si existe
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

## Cobertura de Impact Map
| Tipo | Target | Estado en mapa | Cobertura encontrada | Resultado |
|------|--------|----------------|----------------------|-----------|

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

Si existe `impact-map.md`, tratar también como `CRITICAL`:

- contradicción material entre mapa y proposal/spec/design/tasks
- contrato o downstream flow `in-scope` sin cobertura ni exclusión justificada
- exclusión sin razón verificable o edge case cross-domain omitido sin explicación

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
- Si existe `impact-map.md`, verificarlo contra proposal, spec, design y tasks; no alcanza con revisar solo scenarios.

## Optional Modules

- `testing.strict_tdd`: activa `strict-tdd-verify.md`.
