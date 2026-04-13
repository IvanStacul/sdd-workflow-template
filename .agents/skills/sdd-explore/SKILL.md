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

## Stance

**Sos un compañero de pensamiento, no un formulario.** Explore es una postura, no una secuencia rígida. Tu trabajo es ayudar a pensar mejor sobre el problema antes de formalizarlo.

- **Curioso, no prescriptivo** — hacé preguntas que surjan naturalmente de lo que el usuario trae, no sigas un guión fijo.
- **Hilos abiertos, no interrogatorios** — mostrá múltiples direcciones interesantes y dejá que el usuario siga la que resuene. No lo canalices por un solo camino de preguntas.
- **Visual** — usá diagramas ASCII cuando ayuden a clarificar el pensamiento. Flujos, máquinas de estado, grafos de dependencia, tablas de comparación. Si la exploración necesita visualizaciones más ricas (arquitectura compleja, comparaciones de UI, mockups), escalar a `visual-companion`.
- **Adaptivo** — seguí hilos interesantes, pivoteá cuando aparezca información nueva.
- **Fundamentado** — explorá el codebase real cuando sea relevante; no teorices en el vacío.

Los Steps de abajo son una guía, no un checklist. Adaptá el orden y la profundidad según lo que el usuario trae.

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

## Adaptar al Entry Point

Antes de clasificar formalmente, leé qué trae el usuario y adaptá tu enfoque:

**Idea vaga** — el usuario tiene una intuición pero no sabe bien qué forma tiene. Tu rol: expandir el espacio de posibilidades, hacer preguntas que revelen la forma real del problema, mostrar el espectro de opciones con diagramas.

```
Usuario: Estoy pensando en agregar colaboración en tiempo real

Vos: Colaboración real-time es un espacio grande. Pensemos...

      ESPECTRO DE COLABORACIÓN
      ════════════════════════════════════════════

      Awareness          Coordinación         Sync
          │                   │                 │
          ▼                   ▼                 ▼
      ┌────────┐         ┌────────┐        ┌────────┐
      │Presencia│        │Cursores│        │  CRDT  │
      │  "3     │        │ Multi  │        │Conflict│
      │online"  │        │ select │        │  free  │
      └────────┘         └────────┘        └────────┘
          │                   │                 │
       trivial            moderado           complejo

      ¿Por dónde va tu cabeza?
```

**Problema concreto** — el usuario sabe qué le duele. Tu rol: investigar el codebase, mapear el estado actual, identificar los nudos y preguntar cuál urge.

```
Usuario: El sistema de auth es un quilombo

Vos: [lee el codebase]

     ┌─────────────────────────────────────────────┐
     │              FLUJO AUTH ACTUAL               │
     └─────────────────────────────────────────────┘
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
     ┌─────────┐  ┌─────────┐  ┌─────────┐
     │ Google  │  │  GitHub │  │  Email  │
     │  OAuth  │  │  OAuth  │  │  Magic  │
     └────┬────┘  └────┬────┘  └────┬────┘
          │             │             │
          └─────────────┼─────────────┘
                        ▼
                  ┌───────────┐
                  │  Session  │
                  └─────┬─────┘
                        │
                        ▼
                  ┌───────────┐
                  │   Perms   │
                  └───────────┘

     Veo tres nudos. ¿Cuál está quemando?
```

**Continuación de exploración previa** — ya hay un `exploration.md`. Tu rol: retomar desde donde quedó, profundizar en open questions pendientes, actualizar hallazgos si cambió el contexto.

## Steps

### Step 1: Clasificar la exploracion

Determinar que tipo de exploracion estas haciendo antes de leer archivos al azar:

- **Código existente**: queres entender implementación actual, dependencias o impacto técnico.
- **Dominio funcional**: queres saber que cubren hoy las specs, que falta o que se contradice.
- **Tecnología o enfoque**: queres comparar alternativas o validar fit con el stack actual.
- **Idea nueva**: queres separar supuestos de evidencia del repo antes de abrir un change.

Esta clasificación define que evidencia hace falta y donde persiste mejor el resultado. No la anuncies mecánicamente; usala internamente para enfocar la investigación.

### Step 1.5: Evaluar alcance temprano

Antes de leer archivos al azar, evaluar si la idea o el tema implica múltiples subsistemas independientes (por ejemplo, "necesitamos auth, notificaciones y un panel de admin"). Si es así:

- Señalarlo de inmediato como hallazgo de alcance.
- Recomendar descomponer en changes separados antes de profundizar en evidencia.
- Enfocar la exploración actual en mapear las piezas y sus dependencias, no en investigar cada una en detalle.

Este paso evita invertir evidencia detallada en un scope que después va a necesitar dividirse.

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

**Visualizá cuando ayude.** Si un hallazgo se entiende mejor como diagrama que como bullet, dibujalo. Flujos, dependencias entre archivos, árboles de decisión, comparaciones lado a lado — todo vale.

### Step 2.5: Ofrecer capturar insights que emerjan

Durante la exploración pueden cristalizar insights que ya son decisiones o requisitos. No los dejes pasar. Ofrecé capturarlos sin presionar:

| Tipo de insight | Dónde capturar | Ejemplo de oferta |
|-----------------|----------------|-------------------|
| Requisito nuevo descubierto | spec cuando exista | "Eso es un requisito nuevo. ¿Lo anotamos para la spec?" |
| Cambio de alcance | proposal cuando exista | "Esto cambia el scope. ¿Lo marcamos?" |
| Decisión técnica clara | exploration.md o design futuro | "Esa es una decisión técnica. ¿La registro?" |
| Supuesto invalidado | exploration.md | "Ese supuesto no se sostiene. Lo marco." |

**El usuario decide.** Ofrecé y seguí. No auto-captures sin confirmación salvo supuestos invalidados (esos son evidencia, no decisión).

### Step 3: Sintetizar hallazgos

Preparar una exploracion útil para la fase siguiente. Como mínimo debe dejar claro:

- que se quiso investigar
- que evidencia se encontró
- que alternativas aparecen
- que impacto estimado tiene el cambio
- que riesgos u open questions siguen abiertos
- cual es la recomendacion mas razonable

Formato sugerido para `exploration.md` (adaptar según lo que se encontró; no todas las secciones son obligatorias):

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

## Open Questions
- {pregunta que quedó abierta}

## Conclusión
{Resumen de 2-3 frases con recomendación clara}
```

### Step 4: Persistir o devolver inline

Si existe change activo, escribir o actualizar `openspec/changes/{change-name}/exploration.md` y registrar la fase en `state.md` siguiendo `_shared/phase-common.md`.

Si no existe change activo, devolver la exploracion inline. En ese caso no inventes artefactos ni simules un `state.md` inexistente.

Si la exploración fue conversacional (varias idas y vueltas), sintetizar los hallazgos clave al final antes de persistir. No volcar el log de conversación crudo.

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
- Si la exploracion revela que el cambio es mas grande de lo esperado o abarca subsistemas independientes, marcarlo como riesgo y recomendar dividir en changes separados.
- Si aparecen contradicciones entre specs existentes, reportarlas explicitamente.
- Separar hechos observados de inferencias.
- Mantener `exploration.md` conciso: maximo 200 lineas.
- Si hacés una pregunta al usuario, DETENERTE y esperar la respuesta. No continuar ni asumir respuestas.
- No forzar todas las secciones del template si la exploración no las necesita.

## Optional Modules

- No hay modulos obligatorios.
