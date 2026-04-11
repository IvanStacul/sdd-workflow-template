---
name: sdd-explore
description: "Investigar una idea, un área del código o una capacidad antes de proponer un cambio. Usar cuando el usuario ejecuta /sdd:explore o necesita contexto antes de crear un change."
metadata:
  version: "2.0"
---

## Purpose

Explorar el estado actual del repo, las specs y la idea del cambio para producir hallazgos accionables sin tomar decisiones de diseño todavía.

Esta fase es OPCIONAL. Si el cambio ya está claro, se puede pasar directo a `sdd-propose`.

Sos un EJECUTOR - investigá directamente. NO lances subagentes.

## Inputs

- Tema o pregunta a investigar.
- Opcionalmente, nombre del change si la exploración ya pertenece a uno.

## Context Load

Seguir `_shared/phase-common.md`.

En la practica, eso significa que antes de investigar tenes que leer config, reglas generales, `state.md` si ya existe un change y devolver el envelope común al final.

Ademas leer lo que corresponda al tipo de exploracion:

- `openspec/changes/{change-name}/exploration.md` si ya existe y estas continuando una exploracion previa.
- `openspec/specs/` si la pregunta toca comportamiento existente o contradicciones funcionales.
- código, configuración y docs del proyecto relevantes al tema.

Si `openspec/config.yaml` define `rules.explore`, tratarlas como guardrails locales de esta fase. Sirven para priorizar evidencia, riesgos o formato extra del resultado; complementan esta skill, no la reemplazan.

## Steps

### Step 1: Clasificar la exploracion

Determinar que tipo de exploracion estas haciendo antes de leer archivos al azar:

- **Código existente**: queres entender implementación actual, dependencias o impacto técnico.
- **Dominio funcional**: queres saber que cubren hoy las specs, que falta o que se contradice.
- **Tecnología o enfoque**: queres comparar alternativas o validar fit con el stack actual.
- **Idea nueva**: queres separar supuestos de evidencia del repo antes de abrir un change.

Esta clasificación define que evidencia hace falta y donde persiste mejor el resultado.

### Step 2: Recolectar evidencia

Investigar según el tipo detectado:

- **Código existente**:
  - leer los archivos relevantes del proyecto
  - identificar patrones, dependencias y zonas impactadas
  - documentar paths exactos
- **Dominio funcional**:
  - revisar `openspec/specs/`
  - identificar que existe, que falta y que se contradice la idea
  - mapear dependencias entre specs si aparecen
- **Tecnología o enfoque**:
  - comparar alternativas con pros y contras
  - validar compatibilidad con el stack y las reglas del proyecto
  - dejar claro que parte viene del repo y que parte es inferencia
- **Idea nueva**:
  - contrastar la idea con el estado actual del repo
  - listar supuestos que todavía no tienen evidencia

No hagas afirmaciones genéricas. Si una conclusión depende del repo, citar el path exacto. Si depende de una inferencia, marcarlo como tal.

### Step 3: Sintetizar hallazgos

Preparar una exploracion útil para la fase siguiente. Como mínimo debe dejar claro:

- que se quiso investigar
- que evidencia se encontró
- que alternativas aparecen
- que impacto estimado tiene el cambio
- que riesgos u open questions siguen abiertos
- cual es la recomendacion mas razonable

Usar este formato si escribis `exploration.md`:

```markdown
# Exploración - {tema}

## Pregunta / Objetivo
{Qué se quiso investigar}

## Hallazgos

### {Área/Tema 1}
- {hallazgo con referencia a archivo/spec si aplica}

### {Área/Tema 2}
- {hallazgo}

## Alternativas Evaluadas

| Alternativa | Pros | Contras | Recomendación |
|-------------|------|---------|---------------|

## Impacto Estimado
- Archivos afectados: {lista o estimación}
- Specs afectadas: {lista}
- Riesgo: {bajo | medio | alto} - {justificación}

## Conclusión
{Resumen de 2-3 frases con recomendación clara}
```

### Step 4: Persistir o devolver inline

Si existe change activo, escribir o actualizar `openspec/changes/{change-name}/exploration.md` y registrar la fase en `state.md` siguiendo `_shared/phase-common.md`.

Si no existe change activo, devolver la exploracion inline. En ese caso no inventes artefactos ni simules un `state.md` inexistente.

## Persistence

Si hay change activo:

- `openspec/changes/{change-name}/exploration.md`
- actualizar `openspec/changes/{change-name}/state.md`

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/{change-name}/exploration.md
next: "sdd-propose o ninguna"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

Si devolves la exploracion inline porque no hay change activo, dejar `artifacts: []`.

## Rules

- NO tomar decisiones de diseno. Esta fase investiga y ordena opciones.
- Citar siempre paths exactos cuando referencies archivos del proyecto.
- Si la exploracion revela que el cambio es mas grande de lo esperado, marcarlo como riesgo.
- Si aparecen contradicciones entre specs existentes, reportarlas explicitamente.
- Separar hechos observados de inferencias.
- Mantener `exploration.md` conciso: maximo 200 lineas.

## Optional Modules

- No hay modulos obligatorios.
