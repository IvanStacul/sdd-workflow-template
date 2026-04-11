---
name: sdd-spec
description: >
  Escribir specs con requirements, scenarios y edge cases a partir de una propuesta aprobable.
  Trigger: Después de `sdd-propose` o cuando el usuario necesita bajar una propuesta a especificación, para definir QUÉ debe hacer el sistema.
metadata:
  version: "2.0"
---

## Purpose

Tomar `proposal.md` y producir specs testeables que describen QUÉ se agrega, modifica o elimina. Estas specs son la fuente de verdad del comportamiento del change y después alimentan `sdd-design`, `sdd-tasks`, `sdd-apply` y `sdd-verify`.

Esta es una fase interna del workflow. Normalmente aparece después de `sdd-propose`, muchas veces dentro de `/sdd:new` o de una continuación, aunque no exista un comando público `/sdd:spec`.

Sos un EJECUTOR - escribí las specs directamente. NO lances subagentes.

## Inputs

- Nombre del change.
- `openspec/changes/{change-name}/proposal.md`.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change y devolver el envelope común al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/proposal.md` - la sección `Capabilities` es tu contrato.
- `openspec/specs/` para resolver numeración y leer comportamiento vigente cuando haya capabilities modificadas.
- `openspec/changes/{change-name}/specs/` si ya existen delta specs y estás continuando trabajo previo.
- `assets/spec.template.md` como base para specs nuevas.

Si `openspec/config.yaml` define `rules.spec`, tratarlas como reglas locales de esta fase. Sirven para imponer formato, nomenclatura o cobertura adicional; complementan esta skill, no la reemplazan.

Si `openspec/config.yaml` define `namespaces`, recordar que son metadata de la spec, no carpetas. Usarlas solo para completar `**Namespace**` cuando aplique.

## Steps

### Step 1: Identificar capabilities a crear o modificar

Leer `proposal.md` y separar:

- **Capabilities nuevas** -> cada una genera una spec completa nueva.
- **Capabilities modificadas** -> cada una genera una delta spec que referencia una spec consolidada existente.

Si `proposal.md` no deja suficientemente clara esta separacion, corregir la ambiguedad en la propuesta o devolver riesgo explicito. No inventes mappings silenciosos.

### Step 2: Resolver numeración y paths

Para cada capability:

- **Nueva**:
  - crear `openspec/changes/{change-name}/specs/{NNN-capability}/spec.md`
  - `NNN` es el siguiente numero libre en `openspec/specs/`
- **Modificada**:
  - reutilizar el `NNN` ya existente en `openspec/specs/{NNN-capability}/spec.md`
  - crear o actualizar `openspec/changes/{change-name}/specs/{NNN-capability}/spec.md`

Si una capability marcada como modificada no existe en `openspec/specs/`, no sigas como si nada. Corregi la propuesta o marca el riesgo explicitamente antes de escribir una delta inconsistente.

### Step 3: Leer specs vigentes cuando haya deltas

Para cada capability modificada, leer la spec consolidada actual en `openspec/specs/{NNN-capability}/spec.md`.

El objetivo de este paso es entender el comportamiento vigente para poder escribir una delta real. Sin esa lectura, `MODIFIED` y `REMOVED` quedan ambiguos y `sdd-archive` no puede sincronizar bien.

### Step 4: Escribir las specs del change

#### 4.1 Capabilities nuevas -> spec completa

Usar `assets/spec.template.md` como template base. El template existe para que no queden secciones huerfanas ni formato divergente entre specs nuevas.

Cada spec nueva debe incluir:

- `# {Nombre de la Capability}`
- `**Namespace**: {namespace o -}`
- `## Purpose`
- `## Requirements`
- al menos un `#### Scenario:` por requirement
- `## Edge Cases`

#### 4.2 Capabilities modificadas -> delta spec

Usar este formato:

```markdown
# Delta - {Nombre de la Capability}

## ADDED Requirements

### Requirement: {Nombre}
{Descripcion}

#### Scenario: {nombre}
- GIVEN {precondicion}
- WHEN {accion}
- THEN {resultado esperado}

## MODIFIED Requirements

### Requirement: {Nombre Existente}
{Texto COMPLETO actualizado}
(Previously: {resumen de lo que era antes, en una linea})

#### Scenario: {escenario}
- GIVEN {precondicion}
- WHEN {accion}
- THEN {resultado esperado}

## REMOVED Requirements

### Requirement: {Nombre}
(Reason: {por qué se elimina})
(Migration: {qué usar en su lugar, si aplica})

## Edge Cases

| Caso | Comportamiento Esperado | Req Relacionado |
|------|-------------------------|-----------------|
```

#### 4.3 Workflow critico para `MODIFIED Requirements`

Cuando una requirement existente cambia, seguir este flujo exacto:

1. localizar el requirement en la spec consolidada actual
2. copiar el bloque ENTERO, desde `### Requirement:` hasta todos sus scenarios
3. pegarlo bajo `## MODIFIED Requirements`
4. editar la copia para reflejar el nuevo comportamiento
5. agregar `(Previously: ...)` para resumir que cambiaba

Esto es obligatorio porque `sdd-archive` necesita un bloque completo para reemplazar el requirement consolidado sin perder scenarios previos.

### Step 5: Validar cobertura minima

Antes de cerrar la fase, revisar:

- cada requirement tiene al menos un scenario
- todos los scenarios usan Given/When/Then
- `Edge Cases` existe en cada spec del change
- la spec describe comportamiento, no implementacion
- las delta specs distinguen claramente `ADDED`, `MODIFIED` y `REMOVED`

### Step 6: Registrar fase

Actualizar `state.md` siguiendo `_shared/phase-common.md`.

## Persistence

Escribir o actualizar:

- `openspec/changes/{change-name}/specs/{NNN-capability}/spec.md`
- actualizar `state.md`

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/{change-name}/specs/{NNN-capability}/spec.md
next: "sdd-design o sdd-tasks"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

`sdd-design` y `sdd-tasks` son fases internas del flujo. La necesidad de pasar por `sdd-design` depende de si todavia faltan decisiones estructurales.

## Rules

- Usar Given/When/Then en todos los scenarios.
- Usar RFC 2119 (`MUST`, `SHALL`, `SHOULD`, `MAY`) en los requirements.
- `Edge Cases` es obligatorio.
- Cada requirement debe tener al menos un scenario.
- Los scenarios deben ser testeables.
- No meter implementacion en la spec.
- En `MODIFIED`, copiar y editar el bloque completo.
- Si agregas comportamiento nuevo sin cambiar lo existente, usar `ADDED`, no `MODIFIED`.
- Si continuas una spec ya empezada, leerla antes de actualizarla.

## Optional Modules

- No hay modulos obligatorios.
