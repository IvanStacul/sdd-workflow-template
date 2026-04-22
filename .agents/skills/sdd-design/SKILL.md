---
name: sdd-design
description: "Crear un documento de diseño técnico cuando el change necesita decisiones estructurales antes de implementar. Usar cuando la propuesta o las specs requieren decisiones técnicas antes de implementar."
metadata:
  version: "2.0"
---

## Purpose

Definir COMO se implementa un change cuando `proposal.md` y las specs no alcanzan para tomar decisiones técnicas seguras. Decisiones de arquitectura, patrones, trade-offs. Solo se crea cuando hay complejidad técnica — no todo change necesita design.

`design.md` no es obligatorio en todos los changes. Se crea solo cuando documentar decisiones estructurales reduce riesgo real antes de pasar a `sdd-tasks` y `sdd-apply`.

Sos un EJECUTOR - escribi el diseño directamente. NO lances subagentes.

## Inputs

- Nombre del change.
- `proposal.md`.
- specs del change.
- `impact-map.md` si existe.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change si existe y devolver el envelope común al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/proposal.md`
- `openspec/changes/{change-name}/specs/` - todas las specs del change
- `openspec/changes/{change-name}/impact-map.md` si existe - usarlo como señal de transversalidad y contratos compartidos
- `_shared/abstraction-guide.md`

Si `openspec/config.yaml` define `rules.design`, tratarlas como reglas locales de esta fase. Pueden agregar secciones obligatorias, restricciones técnicas o convenciones de rollout; complementan esta skill, no la reemplazan.

La referencia a `_shared/abstraction-guide.md` no reemplaza esta skill: sirve para decidir si conviene abstraer, extraer servicios o mantener implementación inline cuando el diseño toca estructura de código.

## Steps

### Step 1: Determinar si hace falta design

Crear `design.md` cuando documentar decisiones reduzca riesgo real. Como regla práctica, crear el documento si aparece ALGUNO de estos casos:

- Cambio cross-cutting (múltiples módulos, servicios o capas)
- Dependencia nueva
- Cambios de modelo de datos
- Complejidad de performance, seguridad o migración
- Ambigüedad técnica que conviene cerrar antes de codear
- Necesidad de elegir patrones, boundaries o estrategia de integración

Si existe `impact-map.md`, tratarlo como señal fuerte de que hace falta design cuando expone alguno de estos cruces:

- 2 o más dominios o capabilities `in-scope`
- contratos o interfaces compartidas entre fases, módulos o repositorios
- downstream flows cuyo orden o impacto no sea trivial
- edge cases cross-domain que no se resuelven con una implementación local aislada

NO crear `design.md` si el cambio ya está suficientemente definido por specs y la implementación es directa.

Ejemplos típicos donde suele sobrar el design:

- agregar un campo o endpoint CRUD sin lógica nueva
- ajustar validaciones locales sin impacto transversal
- cambios pequeños donde el supuesto design solo repetiría requirements ya escritos en specs

Si decidís que no hace falta `design.md`, igual registrar la fase en `state.md` y dejarlo explicado en el resumen o en riesgos/observaciones. `sdd-tasks` puede continuar sin design cuando el change no tiene decisiones estructurales pendientes.

### Step 2: Escribir `design.md` si agrega valor

Si hace falta design, crear o actualizar `openspec/changes/{change-name}/design.md` usando `assets/design.template.md`.

Nombrar el template en este punto es importante: la skill depende de ese asset para no dejar secciones huérfanas ni variar el formato de decisión a decisión.

El documento debe incluir como mínimo:

- contexto del problema y restricciones técnicas
- objetivos y no-objetivos del diseño 
- decisiones clave
- alternativas consideradas
- riesgos técnicos y trade-offs
- plan de implementación o migración a alto nivel
- preguntas abiertas reales, si las hay

Si existe `impact-map.md`, el design debe resumir solo los cruces relevantes para la decisión técnica:

- dominios o módulos afectados en scope
- contratos o interfaces compartidas que condicionan el diseño
- downstream flows cuya coordinación requiere orden o boundaries explícitos
- exclusiones que cambian el alcance técnico del change

Cada decisión importante debe quedar presentada con:

- qué se decide
- qué alternativas se evaluaron
- por qué se elige esa opción
- qué riesgo, costo o limitación deja abierta

No reescribas requirements de la spec. El design explica CÓMO encarar la implementación y por qué ese enfoque es razonable; la spec sigue siendo la fuente de verdad del QUÉ.

### Step 3: Validar si el design deja al change listo para taskear

Antes de cerrar la fase, revisar:

- que las decisiones realmente cierren ambigüedades técnicas de las specs
- que no se haya convertido el design en una copia de requirements
- que los riesgos y trade-offs relevantes hayan quedado explicitados
- que `sdd-tasks` pueda transformar el documento en tareas concretas sin volver a adivinar la arquitectura
- si existe `impact-map.md`, que los cruces `in-scope` del mapa queden cubiertos o justificados explícitamente en el design

Si todavía quedan huecos en la spec, reportarlos como riesgo o pregunta abierta. No completes silenciosamente un design con supuestos no acordados.

### Step 4: Registrar fase

Actualizar `state.md` siguiendo `_shared/phase-common.md`.

## Persistence

Si se crea o actualiza design:

- `openspec/changes/{change-name}/design.md`
- `openspec/changes/{change-name}/state.md`

Si no hace falta design:

- actualizar `openspec/changes/{change-name}/state.md`
- no inventar `design.md`

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/{change-name}/design.md
next: "sdd-tasks"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

Si no se crea `design.md`, devolver `artifacts: []` y dejar claro en `summary` que `sdd-tasks` puede seguir sin ese artefacto.

## Rules

- Consultar `_shared/abstraction-guide.md` ANTES de decidir niveles de abstracción.
- NO repetir requirements de la spec; referenciarla.
- Si detectás que la spec tiene huecos, reportarlo como riesgo o pregunta abierta. No improvisar un design que asuma cosas no definidas.
- Toda decisión relevante debe incluir RAZÓN y ALTERNATIVA CONSIDERADA.
- Si el design no agrega valor real, reportarlo y no fuerces el documento.
- Si continuás un `design.md` existente, leerlo antes de actualizarlo.
- Si existe `impact-map.md`, usarlo para decidir si el change es realmente cross-cutting y para justificar contratos, boundaries y exclusiones sin duplicar el mapa completo.

## Optional Modules

- No hay módulos obligatorios.
