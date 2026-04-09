---
name: sdd-explore
description: >
  Investigar una idea, tecnología o área del codebase antes de proponer un cambio.
  Trigger: Cuando el usuario quiere entender algo antes de crear un change.
metadata:
  version: "1.0"
---

## Purpose

Investigar un tema, área del código, o idea antes de crear una propuesta formal. Esta fase es OPCIONAL — se puede ir directo a propose si el cambio está claro.

Sos un EJECUTOR — investigá directamente. NO lances subagentes.

## What You Receive

- Tema o pregunta a investigar
- Nombre del change (si ya se definió)

## What to Do

### Step 1: Cargar contexto

Seguir **Sección B** de `_shared/phase-common.md`.

### Step 2: Investigar

Según el tipo de exploración:

**Exploración de c��digo existente**:
- Leer archivos relevantes del proyecto
- Identificar patrones, dependencias, posibles impactos
- Documentar lo encontrado con paths exactos

**Exploración de concepto/tecnología**:
- Investigar enfoques posibles
- Comparar alternativas con pros/contras
- Evaluar fit con el stack actual (leer `openspec/config.yaml`)

**Exploración de dominio funcional**:
- Revisar specs existentes en `openspec/specs/`
- Identificar qué existe, qué falta, qué contradice
- Mapear dependencias entre specs

### Step 3: Documentar hallazgos

**Si hay change activo**: Crear `openspec/changes/{change-name}/exploration.md`

**Si no hay change**: Devolver inline — la exploración fue informativa.

#### Formato de exploration.md

```markdown
# Exploración — {tema}

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
- Riesgo: {bajo | medio | alto} — {justificación}

## Conclusión
{Resumen de 2-3 frases con recomendación clara}
```

### Step 4: Persistir

Seguir **Sección C** de `_shared/phase-common.md` (actualizar state.md si hay change activo).

### Step 5: Retornar resumen

Seguir **Sección F** de `_shared/phase-common.md`.

## Rules

- NO tomar decisiones de diseño — solo investigar y presentar opciones
- Incluir siempre paths exactos cuando se referencian archivos del proyecto
- Si la exploración revela que el cambio es más grande de lo esperado, ADVERTIR
- Si se encuentran contradicciones en specs existentes, reportarlas como riesgo
- Mantener exploration.md CONCISO — máximo 200 líneas
