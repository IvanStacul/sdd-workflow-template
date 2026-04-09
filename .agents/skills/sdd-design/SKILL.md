---
name: sdd-design
description: >
  Crear documento de diseño técnico con decisiones de arquitectura.
  Trigger: Cuando el cambio requiere decisiones técnicas antes de implementar.
metadata:
  version: "1.0"
---

## Purpose

Definir CÓMO implementar el cambio. Decisiones de arquitectura, patrones, trade-offs. Solo se crea cuando hay complejidad técnica — no todo change necesita design.

Sos un EJECUTOR. NO lances subagentes.

## When to Create

Crear design.md si ALGUNO aplica:
- Cambio cross-cutting (múltiples módulos/servicios)
- Nuevo patrón arquitectónico o dependencia externa
- Cambios significativos de modelo de datos
- Complejidad de seguridad, performance, o migración
- Ambigüedad que beneficia documentar decisiones antes de codear

NO crear si:
- El cambio es directo y la implementación es obvia
- Solo se agregan campos/endpoints CRUD sin lógica nueva

## What You Receive

- Nombre del change
- Proposal + Specs ya creadas

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

Leer OBLIGATORIAMENTE:
- `openspec/changes/{change-name}/proposal.md`
- `openspec/changes/{change-name}/specs/` — todas las specs del change

Consultar:
- `_shared/abstraction-guide.md` — para decisiones de niveles de abstracción

### Step 2: Escribir design.md

Usar el template de `assets/design.template.md`.

### Step 3: Persistir

Seguir **Sección C** de `_shared/phase-common.md`.

### Step 4: Retornar resumen

```markdown
## Diseño Creado

**Change**: {change-name}

### Decisiones clave
| # | Decisión | Alternativa descartada | Razón |
|---|----------|----------------------|-------|

### Riesgos técnicos
{lista o "Ninguno"}

### Siguiente paso
sdd-tasks
```

## Rules

- Consultar `_shared/abstraction-guide.md` ANTES de decidir niveles de abstracción
- Cada decisión debe tener ALTERNATIVA CONSIDERADA y RAZÓN
- NO repetir lo que ya dice la spec — referenciarla
- Si detectás que la spec tiene huecos, reportarlo como riesgo
- Aplicar reglas de `openspec/config.yaml` sección `rules.design` si existen
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
