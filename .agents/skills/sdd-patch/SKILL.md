---
name: sdd-patch
description: >
  Registrar un cambio pequeño sin seguir el flujo completo de SDD.
  Trigger: Cuando hay un fix, validación nueva, o cambio menor que necesita quedar documentado.
metadata:
  version: "1.0"
---

## Purpose

Registrar cambios pequeños que no justifican el flujo completo (propose → spec → design → tasks → apply → verify → archive) pero que SÍ necesitan quedar documentados para mantener la trazabilidad.

Sos un EJECUTOR. NO lances subagentes.

## When to Use

- Fix de un bug simple
- Validación nueva que se agrega
- Ajuste de lógica menor
- Corrección de typo en lógica de negocio
- Cambio de configuración que afecta comportamiento

## When NOT to Use (usar flujo completo)

- Nuevo módulo o feature
- Cambio que afecta múltiples archivos (>5)
- Cambio que modifica el modelo de datos
- Cambio que podría romper funcionalidad existente

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

### Step 2: Crear directorio del patch

```
openspec/changes/patch-YYYY-MM-DD-NN-slug/
```

### Step 3: Escribir patch.md (todo en un archivo)

```markdown
# Patch — {descripción}

## Motivación
{Por qué se hace este cambio — 1-3 frases}

## Cambio
{Qué se modifica — ser específico}

## Archivos

| Archivo | Acción | Detalle |
|---------|--------|---------|
| `path/to/file` | Modificado | {qué se cambió} |

## Spec afectada
{Referencia a spec existente si aplica, o "Ninguna"}

## Decisión
| # | Decisión | Tipo | Justificación |
|---|----------|------|---------------|
{Solo si hay decisión relevante}

## Verificación
- [ ] {cómo verificar que funciona}
```

### Step 4: Implementar el cambio

Hacer el cambio en el código.

### Step 5: Actualizar spec si corresponde

Si el patch modifica comportamiento cubierto por una spec existente:
- Actualizar la spec principal en `openspec/specs/` directamente
- NO crear delta — es un cambio directo

### Step 6: Actualizar known-issues.md si corresponde

Si el patch corrige un bug listado en `docs/known-issues.md`:
- Marcar el bug como ✅ Resuelto
- Agregar referencia al patch

### Step 7: Mover a archive

```bash
mv openspec/changes/patch-YYYY-MM-DD-NN-slug openspec/changes/archive/patch-YYYY-MM-DD-NN-slug
```

### Step 8: Retornar resumen

```markdown
## Patch Aplicado

**Patch**: {nombre}
**Archivos**: {N} modificados
**Spec actualizada**: {sí/no — cuál}
**Known issues**: {bug resuelto o "N/A"}
```

## Rules

- El patch.md es un documento TODO EN UNO — no se crean proposal, spec, design por separado
- Si durante la implementación descubrís que el cambio es más grande, DETENERSE y recomendar flujo completo
- Si el patch afecta una spec, actualizar la spec DIRECTAMENTE (no delta)
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
