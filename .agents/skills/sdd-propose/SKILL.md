---
name: sdd-propose
description: "Crear una propuesta formal de cambio con motivación, alcance y capacidades afectadas. Usar cuando el usuario ejecuta /sdd:propose o inicia un change nuevo."
metadata:
  version: "2.0"
---

## Purpose

Crear la propuesta que establece POR QUÉ y QUÉ cambia. Es el contrato entre la idea y las specs: todo lo que viene después depende de que `proposal.md` deje claro el alcance y las capabilities afectadas.

Esta fase puede llegar directo por `/sdd:propose` o como parte de `/sdd:new`, pero sigue siendo la misma fase interna del workflow.

Sos un EJECUTOR - escribí la propuesta directamente. NO lances subagentes.

## Inputs

- Nombre o slug deseado para el change.
- Descripción del cambio deseado.
- Exploración previa, si existe.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` si el change ya existe y devolver el envelope común al final.

Además leer:

- `openspec/changes/{change-name}/exploration.md` si existe.
- `openspec/specs/` para detectar capabilities existentes y no inventar modificaciones.
- `docs/domain-brief.md` si existe y ayuda a entender el dominio.

Si `openspec/config.yaml` define `rules.proposal`, tratarlas como reglas locales de esta fase. Suelen agregar secciones requeridas, constraints de alcance o criterios de rollout; complementan esta skill, no la reemplazan.

## Steps

### Step 1: Resolver nombre y directorio del change

Crear o continuar un directorio con la convencion de `_shared/openspec-convention.md`:

- `spec-YYYY-MM-DD-NN-slug` para changes completos.
- `slug` sale del nombre provisto por el usuario.
- `NN` se calcula contando changes activos y archivados de la misma fecha.

Si el usuario ya paso un nombre completo que respeta la convención, preservarlo. Si el directorio ya existe, tratarlo como continuación del mismo change: leer lo que haya antes de escribir y no duplicar carpetas.

### Step 2: Crear o actualizar `state.md`

Inicializar `openspec/changes/{change-name}/state.md` con el formato de `_shared/openspec-convention.md` si todavía no existe.

Si ya existe:

- leerlo primero
- preservar el historial append-only
- actualizar solo el puntero de fase y las entradas nuevas que correspondan

### Step 3: Escribir `proposal.md`

`proposal.md` tiene que explicar cada decisión en el punto donde aparece para que `sdd-spec` no tenga que adivinar contexto.

Usar esta estructura:

```markdown
# Propuesta - {nombre descriptivo}

## Por qué
{1-3 frases sobre el problema u oportunidad. Qué problema resuelve. Por qué ahora.}

## Qué Cambia
- {cambio concreto 1}
- {cambio concreto 2}

## Capabilities

### Nuevas
- `{nombre}`: {descripción breve}

### Modificadas
- `{nombre-existente}`: {qué requirement o comportamiento cambia}

## Alcance

### Dentro
- {funcionalidad incluida}

### Fuera
- {funcionalidad excluida} - {motivo}

## Impacto
- **Código**: {módulos/archivos afectados}
- **APIs**: {interfaces o endpoints afectados, si aplica}
- **Dependencias**: {nuevas deps o cambios}
- **Datos**: {migraciones, schemas o "sin cambios"}

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|

## Plan de Rollback
{Cómo volver atrás si el cambio falla}
```

Puntos clave de esta estructura:

- `## Capabilities` es el contrato con `sdd-spec`.
- `### Nuevas` lista capabilities que van a crear specs nuevas.
- `### Modificadas` lista capabilities existentes cuya spec consolidada necesita un delta.
- `### Fuera` evita scope creep y debe quedar tan claro como `### Dentro`.
- `## Plan de Rollback` es obligatorio aunque el rollback sea "revert del commit".

### Step 4: Validar que la propuesta sea accionable

Antes de cerrar la fase, revisar:

- que las capabilities modificadas realmente existan en `openspec/specs/`
- que el alcance no mezcle decisiones de implementacion
- que el cambio no mezcle subsistemas independientes que deberían ser changes separados
- que riesgos y rollback no hayan quedado vacios
- que la propuesta alcance para que `sdd-spec` escriba specs sin inferencias grandes

Si el cambio es demasiado grande, recomendar dividirlo en multiples changes antes de avanzar.

### Step 5: Registrar fase

Actualizar `state.md` siguiendo `_shared/phase-common.md`.

## Persistence

Escribir o actualizar:

- `openspec/changes/{change-name}/state.md`
- `openspec/changes/{change-name}/proposal.md`

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/{change-name}/proposal.md
  - openspec/changes/{change-name}/state.md
next: "sdd-spec"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

## Rules

- Leer specs existentes ANTES de listar capabilities modificadas.
- No meter detalles de implementación en la propuesta; eso pertenece a `sdd-design`.
- Incluir SIEMPRE `Plan de Rollback`, aunque sea simple
- Tratar el change como continuación si ya existe directorio o artefactos previos.
- Si el scope es demasiado grande, recomendar dividir.
- No dejar `Capabilities` ambiguas: `sdd-spec` depende de esa sección.

## Optional Modules

- No hay módulos obligatorios.
