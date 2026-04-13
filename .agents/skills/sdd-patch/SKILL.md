---
name: sdd-patch
description: "Registrar e implementar un cambio pequeño sin recorrer el workflow SDD completo. Usar cuando hay un fix, una validación nueva o un ajuste acotado que igual necesita trazabilidad."
metadata:
  version: "2.0"
---

## Purpose

Resolver cambios chicos que no justifican `propose -> spec -> design -> tasks -> apply -> verify -> archive`, pero que SÍ necesitan quedar documentados para no perder trazabilidad.

`sdd-patch` es un atajo público del workflow, no una fase interna del change completo. Usa un solo documento (`patch.md`), implementa el cambio y archiva directo cuando termina.

Sos un EJECUTOR. NO lances subagentes.

## Inputs

- Descripción breve del cambio.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config y reglas generales antes de tocar el cambio.

Leer OBLIGATORIAMENTE:

- specs consolidadas afectadas en `openspec/specs/` si existen
- `docs/known-issues.md` si existe

## Steps

### Step 1: Validar que realmente sea patch

Usar patch solo si el cambio:

- toca pocos archivos
- no introduce un módulo o feature nuevo
- no cambia arquitectura ni modelo de datos
- puede describirse y verificarse en un solo `patch.md`

Ejemplos tipicos:

- fix de bug puntual
- validación nueva acotada
- ajuste chico de lógica de negocio
- cambio pequeño de configuración con impacto claro

Si durante esta validación ya se ve que el alcance es mayor, detenerse y recomendar el flujo completo.

### Step 2: Crear el patch activo

Crear `openspec/changes/patch-YYYY-MM-DD-NN-slug/`.

`NN` es secuencial por fecha y debe considerar tanto patches activos como archivados del mismo día, siguiendo `_shared/openspec-convention.md`.

### Step 3: Escribir `patch.md`

Crear `openspec/changes/patch-YYYY-MM-DD-NN-slug/patch.md`.

`patch.md` es el documento único del cambio. Debe dejar clara la motivación, lo que se modifica y cómo verificarlo, sin obligar a abrir otros artefactos intermedios.

Usar esta estructura mínima:

```markdown
# Patch - {descripción}

## Motivación
{por qué se hace este cambio}

## Cambio
{qué se modifica y qué comportamiento queda distinto}

## Archivos

| Archivo | Acción | Detalle |
|---------|--------|---------|
| `path/to/file` | Modificado | {qué se cambió} |

## Spec afectada
{referencia a la spec consolidada afectada o "Ninguna"}

## Decisiones
| # | Decisión | Tipo | Justificación |
|---|----------|------|---------------|
{solo si hubo una decisión relevante}

## Verificación
- [ ] {cómo comprobar que el cambio quedó bien}
```

### Step 4: Implementar el cambio

Hacer el cambio en código y mantener `patch.md` sincronizado con lo realmente implementado.

Si durante la implementación descubrís que el cambio es más grande de lo esperado, detenerte y recomendar migrarlo al flujo completo. No fuerces un patch que ya dejó de ser pequeño.

### Step 5: Sincronizar artefactos permanentes si corresponde

Si el patch cambia comportamiento ya cubierto por una spec consolidada:

- actualizar la spec principal directamente en `openspec/specs/`
- no crear delta spec ni artefactos del flujo largo

Si el patch corrige un bug que ya estaba listado en `docs/known-issues.md`:

- marcarlo como resuelto o actualizar su estado
- agregar referencia al patch si ayuda a la trazabilidad

### Step 6: Archivar el patch

Mover `openspec/changes/patch-YYYY-MM-DD-NN-slug/` a `openspec/changes/archive/patch-YYYY-MM-DD-NN-slug/`.

El artefacto final del patch es el archivo archivado, no un change activo abierto.

## Persistence

Escribir o actualizar:

- `openspec/changes/patch-YYYY-MM-DD-NN-slug/patch.md`
- specs consolidadas afectadas en `openspec/specs/` si corresponde
- `docs/known-issues.md` si corresponde

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/archive/patch-YYYY-MM-DD-NN-slug/patch.md
next: "ninguno o flujo completo"
risks:
  - ""
skill_resolution: disabled | direct | fallback
```

## Rules

- `patch.md` es el documento único.
- No crear `proposal.md`, delta specs, `design.md`, `tasks.md` ni `verify-report.md`.
- Si el patch afecta una spec, actualizar la spec consolidada directamente.
- Si el cambio deja de ser pequeno, detenerse y recomendar el flujo completo.
- Si existe `docs/known-issues.md`, revisarlo antes de repetir un bug ya documentado.

## Optional Modules

- No hay modulos obligatorios.
