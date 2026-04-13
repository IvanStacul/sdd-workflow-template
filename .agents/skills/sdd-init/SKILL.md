---
name: sdd-init
description: "Inicializar el workflow SDD en un proyecto y escribir la configuración file-based. Usar cuando el usuario ejecuta /sdd:init, quiere iniciar el flujo SDD o falta openspec/config.yaml."
metadata:
  version: "2.0"
---

## Purpose

Inicializar el contexto SDD (Spec-Driven Development) del proyecto, detectar stack técnico y de testing, evaluar la estructura existente, configurar archivos de agente, y dejar la estructura file-based lista para trabajar sin adivinar decisiones importantes.

Sos un EJECUTOR - hacé el trabajo directamente. NO lances subagentes.

## Inputs

- Raiz del proyecto actual.
- Opcionalmente: preferencias explícitas del usuario para políticas, modos o módulos.

## Context Load

Leer en este orden:

1. `AGENTS.md`, `CLAUDE.md`, `.cursorrules` u otros archivos de reglas si existen.
2. `.agents/orchestrator.md`, `.agents/personality.md`, `.agents/rules.md` si existen.
3. `openspec/config.yaml` si existe.
4. Estructura actual del repo para detectar stack, tests, skills y documentación.

Compatibilidad legacy:

- Si existe `tdd`, mapearlo a `testing.strict_tdd`.
- Si existe `test_command`, mapearlo a `testing.test_command`.

## Steps

### Step 1: Detectar contexto real del proyecto

Inspeccionar el proyecto para detectar:

- stack técnico (lenguajes, frameworks, herramientas de build)
- linters y formatters
- patrones de arquitectura ya en uso
- test runner
- coverage command
- typecheck command

El objetivo de este paso es que el init se apoye en evidencia real del repo. No inventar stack, comandos ni capacidades.

### Step 2: Detectar estructura existente y clasificar el init

Verificar existencia de:

- `AGENTS.md` o equivalentes (`CLAUDE.md`, `.cursorrules`, etc.)
- `.agents/orchestrator.md`, `.agents/personality.md`, `.agents/rules.md`
- `openspec/config.yaml`
- `openspec/specs/`
- `openspec/changes/`
- `docs/known-issues.md`
- `docs/workflow-changelog.md`
- otras estructuras de specs o skills (`docs/specs/`, `.agents/skills/`, `.claude/skills/`, etc.)

Clasificar en:

| Modo | Condición | Acción |
|------|-----------|--------|
| **fresh** | No existe `openspec/` ni estructura de specs | Crear todo desde cero |
| **migrate** | Existe estructura de specs diferente (ej: `docs/specs/`) | Auditar, proponer mapeo y preguntar antes de actuar |
| **adopt** | Ya existe `openspec/` | Verificar consistencia y completar lo que falte |

**Si es modo migrate**: presentar reporte de que se encontro vs que espera el flujo SDD. Proponer plan de migracion. PREGUNTAR al usuario antes de ejecutar.

### Step 3: Resolver decisiones de configuración ANTES de escribir nada

Antes de escribir `openspec/config.yaml`, explicar cada decisión en el momento en que aparece. La persona que lee esta skill no debería tener que saltar a otra sección para entender que significa cada opción.

Usar defaults solo si:

- el usuario no dio preferencia,
- el estado del repo no obliga otra cosa,
- y la recomendación es razonable para un proyecto genérico.

Para detalle estructural del archivo, ver `_shared/openspec-convention.md`.
Para el módulo de skills de proyecto, ver `_shared/skill-resolver.md`.

#### 3.1 `agents_md_policy`

Controla como se gestiona `AGENTS.md`.

| Opcion | Que hace | Cuando conviene |
|--------|----------|-----------------|
| `managed` | El workflow controla todo el archivo | Repos nuevos o cuando el usuario quiere centralizar todo en SDD |
| `section` | Solo toca la sección delimitada `<!-- sdd-workflow:start/end -->` | Repos donde `AGENTS.md` ya tiene contenido propio o puede crecer con otras reglas |
| `readonly` | Nunca modifica `AGENTS.md` | Repos donde `AGENTS.md` lo mantiene otra herramienta o el usuario no quiere automatizarlo |

Recomendación contextual:

- `managed` si `AGENTS.md` no existe y no hay evidencia de otro owner o de convivencia necesaria con otras reglas.
- `section` si `AGENTS.md` ya existe, si el repo ya usa otras instrucciones, o si es razonable esperar crecimiento fuera del workflow.

Motivo: `managed` es más simple cuando el archivo nace para SDD; `section` evita invadir un archivo compartido.

#### 3.2 `agent_mode`

Controla como se ejecutan las fases.

| Opcion | Que hace | Implicancia |
|--------|----------|-------------|
| `sequential` | El orquestador ejecuta todas las fases en la misma conversacion | Funciona en cualquier editor; es el default seguro |
| `multi` | El orquestador puede delegar fases a subagentes | Solo sirve si el editor realmente soporta delegación |

Preguntar si el editor soporta delegación a subagentes SOLO si no hay evidencia suficiente.

Evidencia válida para elegir `multi` sin preguntar:

- documentación oficial del editor confirmando agent mode con delegación o ejecución autónoma,
- herramientas/capacidades del entorno que incluyan delegación a agentes,
- configuración existente del proyecto que ya trabaje en `multi`.

Si no hay evidencia o el usuario no lo sabe, usar `sequential`.

Si se elige `multi`, completar `model_assignments` con los aliases disponibles o preservar los ya configurados.

Recomendación contextual:

- `multi` cuando haya evidencia real de delegación disponible en el editor actual.
- `sequential` cuando no se pueda confirmar.

#### 3.3 `interaction_mode`

Controla cuanta confirmacion pide el flujo.

| Opcion | Que hace | Cuando conviene |
|--------|----------|-----------------|
| `interactive` | Pausa en decisiones importantes y deja visible el avance | Cuando se está adoptando el workflow o se prioriza control |
| `auto` | Ejecuta más seguido de punta a punta con menos pausas | Cuando el equipo ya confía en el flujo y quiere velocidad |

Recomendación: `interactive`.

#### 3.4 `namespaces`

Los namespaces son metadata de specs, no carpetas. Sirven para separar dominios funcionales grandes.

| Opcion | Que hace |
|--------|----------|
| `[]` | No usar namespaces por ahora |
| Lista de namespaces | Etiquetar specs por dominio (`inventory`, `billing`, etc.) |

Recomendación: dejar `[]` al iniciar, salvo que el proyecto ya tenga dominios bien definidos y estables.

#### 3.5 `testing.strict_tdd`

Controla si `sdd-apply` y `sdd-verify` deben cargar reglas de TDD estricto.

| Opcion | Que hace | Implicancia |
|--------|----------|-------------|
| `false` | Permite implementar sin forzar ciclo test-first estricto | Default seguro cuando el equipo no trabaja con TDD estricto |
| `true` | Activa reglas extra para escribir o ajustar tests antes del código | Requiere test runner real y acuerdo del equipo |

Recomendación: `false` por default. Solo activar si el proyecto tiene test runner y el usuario o la configuración existente piden TDD estricto.

Ademas de esta bandera, detectar:

- `testing.test_command`
- `testing.coverage_command`
- `testing.typecheck_command`

Si el proyecto no tiene test runner, dejar los campos vacios y explicarlo.

#### 3.6 `modules.skill_registry`

Controla si el flujo detecta skills de proyecto y las inyecta en fases relevantes.

| Opcion | Que hace | Implicancia |
|--------|----------|-------------|
| `false` | El flujo usa solo reglas SDD base | Menos integracion con convenciones del proyecto |
| `true` | Activa el resolver de skills de proyecto | Las fases técnicas pueden recibir estandares compactados automaticamente |

Recomendación: `true`.

Motivo: mejora la consistencia entre fases y ayuda a que `design`, `tasks`, `apply` y `verify` sepan que convenciones o herramientas existen en el repo.

#### 3.7 `modules.model_routing`

Controla si se usan modelos distintos por fase.

| Opcion | Que hace | Implicancia |
|--------|----------|-------------|
| `false` | Ignora routing por fase | Menos complejidad; default seguro |
| `true` | Usa `model_assignments` para elegir modelo según la fase | Solo tiene sentido real si `agent_mode: multi` |

Recomendación: `false`, salvo que el editor soporte delegación y existan aliases de modelo confirmados por config, settings o convencion del equipo.

Si se activa:

- no inventar aliases,
- usar valores ya configurados en el editor o preservados en `openspec/config.yaml`,
- si solo hay un modelo confirmado, se puede rutear todo a ese mismo alias y dejar nota de la limitacion.

#### 3.8 Defaults recomendados

Si no hay preferencias explicitas ni restricciones del repo, usar defaults contextuales:

- `agents_md_policy: managed` si `AGENTS.md` no existe y no hay otro owner detectable; si no, `section`
- `agent_mode: multi` si el editor soporta delegación con evidencia real; si no, `sequential`
- `interaction_mode: interactive`
- `namespaces: []`
- `testing.strict_tdd: false`
- `modules.skill_registry: true`
- `modules.model_routing: true` solo si hay aliases confirmados; si no, `false`

Si ya existe config, preservar valores explicitos y migrar solo la forma del bloque `testing`.

### Step 4: Crear o actualizar `openspec/config.yaml`

Usar `assets/config.template.yaml`.

Completar con:

- contexto del proyecto detectado en Step 1
- politica de `AGENTS.md`
- modo de agente e interacción
- `model_assignments`
- `namespaces`
- `testing.strict_tdd`
- `testing.test_command`
- `testing.coverage_command`
- `testing.typecheck_command`
- `modules.skill_registry`
- `modules.model_routing`
- `rules.<fase>` si el proyecto ya tiene overrides claros

Si `openspec/config.yaml` ya existe:

- LEER antes de tocar.
- Preservar valores explicitos del usuario.
- Migrar `tdd` y `test_command` a `testing.*`.
- Si el archivo requiere un cambio estructural fuerte, proponer `mantener` / `merge` / `reemplazar` antes de hacerlo.

No volver a escribir claves legacy en raiz.

### Step 5: Crear o actualizar archivos base del agente

#### `.agents/orchestrator.md`

- Si NO existe -> copiar desde el workflow template.
- Si existe -> no pisarlo silenciosamente; comparar y proponer merge si le faltan reglas base importantes.

#### `.agents/personality.md`

- Si NO existe -> crear desde el workflow template.
- Si existe -> preservar la voz del proyecto y solo proponer merge si faltan pautas esenciales.

#### `.agents/rules.md`

- Si NO existe -> crear desde el workflow template.
- Si existe -> preservar reglas propias del proyecto y agregar solo guardrails SDD faltantes.

### Step 6: Crear o actualizar `AGENTS.md` según la policy elegida

Usar `assets/agents-section.template.md` cuando haga falta escribir la sección SDD.

| Policy | Acción |
|--------|--------|
| `managed` | Crear o reemplazar el archivo completo. Usar solo si el usuario quiere que el workflow lo administre entero. |
| `section` | Crear el archivo si no existe, o insertar/actualizar solo el bloque delimitado `<!-- sdd-workflow:start/end -->`. Preservar el resto. |
| `readonly` | No tocar `AGENTS.md`. Asegurar que `.agents/` quede documentado y mencionar que el usuario debe enlazarlo manualmente si quiere. |

Si el usuario elige `readonly`, asegurarse de que las reglas del workflow sigan estando claras en `.agents/` y que no haya contradicciones obvias con `AGENTS.md`.

### Step 7: Asegurar estructura y documentación base

Crear si falta:

- `openspec/specs/`
- `openspec/changes/archive/`
- `docs/`

Crear si faltan, usando los templates de `assets/`:

- `docs/known-issues.md` desde `assets/known-issues.template.md`
- `docs/workflow-changelog.md` desde `assets/workflow-changelog.template.md`

No crear specs placeholder.
No crear `docs/domain-brief.md` vacio; ese archivo se genera con `domain-brief` cuando ya existen specs consolidadas.

### Step 8: Detectar skills de proyecto y mirrors opcionales

Si `modules.skill_registry: true`, escanear skills de proyecto existentes:

- incluir skills locales que NO empiecen con `sdd-`
- excluir `_shared`
- excluir `domain-brief`
- reportar al usuario cuales se detectaron y de que tipo parecen ser

Si no se encontraron y el stack sugiere que convendría una skill de proyecto, proponer crearla más adelante.

Si el usuario trabaja en varios editores, ofrecer `scripts/mirror-agents.sh` como paso opcional.

### Step 9: Retornar resumen claro

El resumen final debe dejar visible:

- stack detectado
- modo de init (`fresh`, `migrate`, `adopt`)
- decisiones de configuración tomadas
- archivos creados, preservados o fusionados
- skills de proyecto detectadas
- siguiente paso recomendado (`/sdd:onboard` o `/sdd:new <nombre>`)

## Persistence

Escribir o actualizar:

- `openspec/config.yaml`
- `openspec/specs/`
- `openspec/changes/archive/`
- `docs/known-issues.md`
- `docs/workflow-changelog.md`
- `AGENTS.md` según policy

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/config.yaml
next: "/sdd:new <nombre> o /sdd:onboard"
risks:
  - ""
skill_resolution: disabled
```

## Rules

- Nunca crear specs placeholder.
- SIEMPRE detectar el stack real, no inventar.
- Si hay estructura existente, AUDITAR y PREGUNTAR antes de modificar.
- Explicar cada decisión de configuración en el momento en que se presenta.
- Usar los templates de `assets/` cuando exista un artefacto canonico para ese archivo.
- Escribir solo la nueva forma `testing.*`.
- Si no hay test runner, dejar `testing.*` vacio y explicarlo.
- No borrar documentación existente del proyecto.
- No pisar archivos personalizados del usuario sin comparar y proponer merge.

## Optional Modules

- `testing.strict_tdd`: si está en `true`, `sdd-apply` y `sdd-verify` cargan reglas adicionales de TDD estricto.
- `modules.skill_registry`: default recomendado `true`; habilita detección e inyección de skills de proyecto según `_shared/skill-resolver.md`.
- `modules.model_routing`: solo tiene efecto cuando `agent_mode: multi`.
