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

Si el input es vago o incompleto (el usuario dijo algo general sin detallar qué quiere cambiar), preguntar antes de avanzar. No inventar alcance ni capabilities a partir de una frase ambigua.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` si el change ya existe y devolver el envelope común al final.

Además leer:

- `openspec/changes/{change-name}/exploration.md` si existe.
- `openspec/changes/{change-name}/impact-map.md` si existe.
- `openspec/specs/` para detectar capabilities existentes y no inventar modificaciones.
- `docs/domain-brief.md` si existe y ayuda a entender el dominio.

Si `openspec/config.yaml` define `rules.proposal`, tratarlas como reglas locales de esta fase. Suelen agregar secciones requeridas, constraints de alcance o criterios de rollout; complementan esta skill, no la reemplazan.

## Steps

### Step 1: Resolver nombre y directorio del change

Crear o continuar un directorio con la convencion de `_shared/openspec-convention.md`:

- `spec-YYYY-MM-DD-NN-slug` para changes completos.
- `slug` sale del nombre provisto por el usuario.
- `NN` se calcula contando changes activos y archivados de la misma fecha.

Si el usuario ya paso un nombre completo que respeta la convención, preservarlo. Si el directorio ya existe y tiene artefactos previos, preguntar si quiere continuar ese change o crear uno nuevo. Leer lo que haya antes de escribir y no duplicar carpetas.

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

### Step 4: Clasificar el análisis cruzado y crear o actualizar `impact-map.md`

Evaluar si el change requiere análisis de impacto cruzado con esta matriz mínima:

- `obligatorio` si el change toca 2 o más dominios o capabilities relacionadas, modifica un contrato compartido, cambia templates del workflow o integra fases distintas.
- `obligatorio` si el riesgo funcional es alto o el cambio es claramente cross-cutting aunque la implementación viva en pocos archivos.
- `recomendado` si el cambio parece local pero tiene downstream flows, navegación entre artefactos o dependencias que conviene revisar explícitamente.
- `opcional` solo para cambios acotados y localizados, como fixes editoriales o ajustes sin contratos ni efectos aguas abajo.

Reglas de persistencia:

- Si la clasificación es `obligatorio` o `recomendado`, crear o actualizar `openspec/changes/{change-name}/impact-map.md` usando `assets/impact-map.template.md`.
- Si el archivo ya existe, leerlo y refinar el mismo artefacto; no reemplazarlo ni crear paralelos.
- Si la clasificación es `opcional`, dejar una justificación breve dentro de la propuesta y conservar esa clasificación visible para que fases posteriores puedan verificar la omisión.

Contenido mínimo cuando exista `impact-map.md`:

- nivel de clasificación y justificación
- dominio principal afectado
- dominios secundarios revisados
- referencias tipadas iniciales
- contratos o interfaces afectadas
- downstream flows observables
- edge cases cross-domain detectados
- exclusiones explícitas con razón
- evidencia esperada para verify

Usar referencias tipadas deduplicadas por `target` + `relation`, sin nesting recursivo.

### Step 5: Validar que la propuesta sea accionable

Antes de cerrar la fase, revisar:

- que las capabilities modificadas realmente existan en `openspec/specs/`
- que el alcance no mezcle decisiones de implementación
- que el cambio no mezcle subsistemas independientes que deberían ser changes separados
- que riesgos y rollback no hayan quedado vacios
- que la propuesta alcance para que `sdd-spec` escriba specs sin inferencias grandes

Si el cambio es demasiado grande, NO cerrar la fase con una recomendacion abstracta. Dejar explicitados al menos:

- cortes naturales propuestos
- nombre tentativo de cada sub-change
- capabilities incluidas en cada slice
- dependencias y orden recomendado
- cual es el primer slice implementable

Si la division ya esta clara y el usuario quiere seguir en la misma sesion, redefinir la propuesta actual como el primer slice implementable en lugar de dejar un change paraguas ambiguo. Los slices restantes deben quedar nombrados y delimitados desde esta fase para que otra sesion pueda retomarlos sin depender del contexto conversacional.

**Criterio de decisión vs pregunta**: si algo es razonablemente inferible del contexto (exploración previa, specs existentes, conversación), tomar la decisión y documentarla en la propuesta. Si falta información que cambia el alcance o las capabilities, preguntar. Preferir mantener el momentum con decisiones razonables antes que frenar con preguntas menores.

### Step 6: Presentar para review

Antes de registrar la fase, presentar al usuario un resumen breve de la propuesta:

- Nombre del change
- Capabilities nuevas y modificadas
- Clasificación del análisis cruzado (`obligatorio`, `recomendado` u `opcional`)
- Qué queda dentro y fuera del alcance
- Riesgos principales

Esperar confirmación o ajustes. No asumir aceptación implícita.

### Step 7: Registrar fase

Actualizar `state.md` siguiendo `_shared/phase-common.md`.

## Persistence

Escribir o actualizar:

- `openspec/changes/{change-name}/state.md`
- `openspec/changes/{change-name}/proposal.md`
- `openspec/changes/{change-name}/impact-map.md` cuando la clasificación sea `obligatorio` o `recomendado`

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
- Si el scope es demasiado grande, dejar la division operativa en la propuesta. No alcanza con "conviene dividir".
- No dejar `Capabilities` ambiguas: `sdd-spec` depende de esa sección.
- Si el análisis cruzado queda como `opcional`, dejar la justificación explícita; si queda como `obligatorio` o `recomendado`, no cerrar la fase sin `impact-map.md`.

## Optional Modules

- No hay módulos obligatorios.
