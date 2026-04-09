---
name: sdd-spec
description: >
  Escribir especificaciones con requisitos, escenarios y casos de borde.
  Trigger: Después de crear una propuesta, para definir QUÉ debe hacer el sistema.
metadata:
  version: "1.0"
---

## Purpose

Tomar la propuesta y producir specs — requisitos estructurados con escenarios que describen QUÉ se agrega, modifica o elimina. Las specs son la fuente de verdad de comportamiento.

Sos un EJECUTOR — escribí las specs directamente. NO lances subagentes.

## What You Receive

- Nombre del change
- Proposal ya creada en `openspec/changes/{change-name}/proposal.md`

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

Leer OBLIGATORIAMENTE:
- `openspec/changes/{change-name}/proposal.md` — la sección Capabilities es tu contrato

### Step 2: Identificar specs a crear

```
PARA CADA entrada en "Capabilities > Nuevas":
├── Crear spec COMPLETA: openspec/changes/{change-name}/specs/{NNN-capability}/spec.md
└── NNN = siguiente número secuencial en openspec/specs/

PARA CADA entrada en "Capabilities > Modificadas":
├── Crear DELTA spec: openspec/changes/{change-name}/specs/{NNN-capability}/spec.md
└── NNN = el número existente en openspec/specs/
```

### Step 3: Leer specs existentes (si hay capabilities modificadas)

Para cada capability modificada, leer `openspec/specs/{NNN-capability}/spec.md` para entender el comportamiento ACTUAL. Tu delta describe CAMBIOS a este comportamiento.

### Step 4: Escribir specs

Usar el template de `assets/spec.template.md`.

#### Para capabilities NUEVAS → spec completa:

```markdown
# {Nombre de la Capability}

**Namespace**: {namespace de config.yaml o —}

## Purpose
{Descripción del dominio de esta spec}

## Requirements

### Requirement: {Nombre del Requisito}
{Descripción usando RFC 2119: MUST, SHALL, SHOULD, MAY}

#### Scenario: {Camino feliz}
- GIVEN {precondición}
- WHEN {acción}
- THEN {resultado esperado}
- AND {resultado adicional, si hay}

#### Scenario: {Caso de error}
- GIVEN {precondición}
- WHEN {acción}
- THEN {resultado esperado}

## Edge Cases

| Caso | Comportamiento Esperado | Req Relacionado |
|------|------------------------|-----------------|
| {descripción} | {qué debe pasar} | {FR-XX-NN} |
```

#### Para capabilities MODIFICADAS → delta spec:

```markdown
# Delta — {Nombre de la Capability}

## ADDED Requirements

### Requirement: {Nombre}
{Descripción}

#### Scenario: {nombre}
- GIVEN / WHEN / THEN

## MODIFIED Requirements

### Requirement: {Nombre Existente}
{Texto COMPLETO actualizado — reemplaza el existente}
(Previously: {resumen de lo que era antes, en una línea})

#### Scenario: {escenario — todos, no solo los que cambian}
- GIVEN / WHEN / THEN

## REMOVED Requirements

### Requirement: {Nombre}
(Reason: {por qué se elimina})
(Migration: {qué usar en su lugar, si aplica})

## Edge Cases

| Caso | Comportamiento Esperado | Req Relacionado |
|------|------------------------|-----------------|
```

### MODIFIED Requirements — Workflow CRÍTICO

```
1. Localizar el requirement en openspec/specs/{capability}/spec.md
2. COPIAR el bloque ENTERO — desde `### Requirement:` hasta todos sus scenarios
3. PEGAR bajo `## MODIFIED Requirements`
4. EDITAR la copia para reflejar el nuevo comportamiento
5. Agregar "(Previously: {resumen})" bajo el texto del requirement

¿Por qué copiar-completo-y-editar?
→ Al archivar, el bloque MODIFIED REEMPLAZA el requirement en la spec principal
→ Si tu bloque es parcial, el archive PIERDE scenarios que no copiaste
→ Si agregas comportamiento NUEVO sin cambiar lo existente, usar ADDED
```

### Step 5: Persistir

Seguir **Sección C** de `_shared/phase-common.md`.

### Step 6: Retornar resumen

```markdown
## Specs Creadas

**Change**: {change-name}

| Capability | Tipo | Requirements | Scenarios | Edge Cases |
|-----------|------|-------------|-----------|------------|
| {nombre} | Nueva/Delta | {N} | {N} | {N} |

### Cobertura
- Caminos felices: {cubiertos/faltantes}
- Casos de error: {cubiertos/faltantes}
- Edge cases: {cubiertos/faltantes}

### Siguiente paso
sdd-design (si se necesita arquitectura) o sdd-tasks (si el diseño está claro).
```

## Rules

- SIEMPRE usar Given/When/Then para scenarios
- SIEMPRE usar RFC 2119 (MUST, SHALL, SHOULD, MAY)
- La sección **Edge Cases** es OBLIGATORIA — no es opcional
- Cada requirement DEBE tener al menos UN scenario
- Los scenarios deben ser TESTEABLES — alguien debe poder escribir un test automatizado
- NO incluir detalles de implementación — specs describen QUÉ, no CÓMO
- MODIFIED requirements DEBEN ser el bloque COMPLETO copiado y editado
- Si agregas comportamiento nuevo sin cambiar lo existente → usar ADDED, no MODIFIED
- Aplicar reglas de `openspec/config.yaml` sección `rules.spec` si existen
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
