# Guia del Workflow SDD

Esta guía explica como se opera el workflow real de este template sin obligarte a reconstruirlo leyendo skill por skill.

Si un documento de `docs/` contradice a `.agents/orchestrator.md` o a una skill, mandan `.agents/orchestrator.md` y `.agents/skills/`.

## 1. Interfaz pública

Los comandos públicos viven en `.agents/commands/sdd/`:

| Comando | Cuando usarlo | Resultado esperado |
|---------|---------------|--------------------|
| `/sdd:init` | Instalar o re-detectar el workflow en un proyecto | Escribe `openspec/config.yaml` y asegura la estructura base |
| `/sdd:onboard` | Aprender el flujo con un ejemplo real del repo | Explica el workflow paso a paso |
| `/sdd:new <nombre>` | Abrir un change completo | Recorre `propose -> spec -> design` como gate técnico -> `tasks` |
| `/sdd:continue [nombre]` | Retomar un change ya empezado | Lee artefactos + `state.md` y elige la siguiente fase compatible, reusando `impact-map.md` si existe |
| `/sdd:ff [nombre]` | Avanzar sin pausas por las fases pendientes | Fuerza `interaction_mode: auto` y sigue hasta bloquear o terminar |
| `/sdd:explore <tema>` | Investigar antes de proponer | Produce contexto para decidir mejor un change |
| `/sdd:propose <nombre>` | Crear una propuesta formal puntual | Genera el arranque de un change sin correr todo el flujo |
| `/sdd:apply [nombre]` | Implementar tareas pendientes | Ejecuta `sdd-apply` sobre un change existente |
| `/sdd:verify [nombre]` | Verificar cumplimiento con evidencia | Genera evidencia y decide si el change puede cerrar |
| `/sdd:archive [nombre]` | Cerrar un change ya verificado | Archiva con retro obligatoria |
| `/sdd:patch` | Resolver un cambio chico con trazabilidad | Usa un único `patch.md`, implementa y archiva |
| `/sdd:domain-brief` | Regenerar el resumen funcional del sistema | Relee specs consolidadas y genera `docs/domain-brief.md` |

## 2. Fases internas vs comandos

El flujo largo sigue esta secuencia:

```text
explore (opcional) -> propose -> spec -> design (opcional) -> tasks -> apply -> verify -> archive
```

Hay una diferencia importante entre interfaz pública y fases internas:

- `/sdd:new <nombre>` es la puerta de entrada normal al flujo completo.
- Si `sdd-propose` clasifica el análisis cruzado como `obligatorio` o `recomendado`, crea o actualiza `impact-map.md` y las fases siguientes continúan ese mismo archivo.
- `propose`, `spec`, `design` y `tasks` siguen siendo fases internas del workflow.
- En este template no se presentan `spec`, `design` ni `tasks` como comandos públicos separados.
- `/sdd:continue` y `/sdd:ff` no adivinan la siguiente fase por nombre: la resuelven mirando artefactos reales y `state.md`.
- `/sdd:patch` no entra al flujo largo del change completo.
- `/sdd:domain-brief` no es una fase del change: es una utilidad pública aparte.

Si necesitas entender el rol de cada fase interna:

| Fase | Para que existe |
|------|------------------|
| `sdd-explore` | Reunir contexto antes de abrir un change |
| `sdd-propose` | Definir el problema, alcance y motivación |
| `sdd-spec` | Convertir la propuesta en requirements y escenarios |
| `sdd-design` | Decidir si hace falta diseño técnico antes de planificar tareas |
| `sdd-tasks` | Bajar la spec a trabajo ejecutable |
| `sdd-apply` | Implementar las tareas y actualizar el estado |
| `sdd-verify` | Contrastar implementación, specs y evidencia |
| `sdd-archive` | Cerrar el change y propagar aprendizaje |

## 3. Que contiene este repo y que genera el workflow

Este repo es el template. No todos los artefactos de un proyecto ya inicializado tienen que existir aca desde el inicio.

### Archivos que si vienen en el template

- `.agents/`
- `README.md`
- `docs/workflow-guide.md`
- `docs/workflow-sources.md`

### Archivos que `/sdd:init` crea o completa en el repo consumidor

| Ruta | Como aparece | Para que sirve |
|------|--------------|----------------|
| `openspec/config.yaml` | Lo escribe `sdd-init` | Configuración file-based del workflow |
| `openspec/specs/` | Lo asegura `sdd-init` | Fuente de verdad consolidada |
| `openspec/changes/archive/` | Lo asegura `sdd-init` | Historial de changes cerrados |
| `docs/known-issues.md` | Lo crea `sdd-init` si falta | Lecciones y bugs a propagar |
| `docs/workflow-changelog.md` | Lo crea `sdd-init` si falta | Mejora continua del workflow |

### Archivos que aparecen durante el uso normal del workflow

| Ruta | Quien lo genera | Nota |
|------|------------------|------|
| `openspec/changes/{change-name}/proposal.md` | `sdd-propose` | Arranque del change |
| `openspec/changes/{change-name}/impact-map.md` | `sdd-propose` cuando aplica | Fuente de verdad del análisis cruzado; se reutiliza en las fases siguientes |
| `openspec/changes/{change-name}/specs/.../spec.md` | `sdd-spec` | Delta specs del change |
| `openspec/changes/{change-name}/design.md` | `sdd-design` cuando aplica | Puede no existir si el gate técnico concluye que no hace falta |
| `openspec/changes/{change-name}/tasks.md` | `sdd-tasks` | Plan ejecutable del change |
| `openspec/changes/{change-name}/state.md` | Fases del workflow | Estado operativo del change |
| `openspec/changes/{change-name}/verify-report.md` | `sdd-verify` | Evidencia y veredicto |
| `openspec/changes/patch-.../patch.md` | `sdd-patch` | Documento único del atajo de patch |
| `docs/domain-brief.md` | `domain-brief` | No se crea vacio en `init`; se genera cuando ya hay specs consolidadas |

## 4. Configuración que importa

`/sdd:init` explica cada decisión en el momento en que la propone, pero conviene conocer estos conceptos base:

| Clave | Default recomendado | Que controla |
|-------|---------------------|--------------|
| `agents_md_policy` | `section` | Si el workflow gestiona todo `AGENTS.md`, solo un bloque o nada |
| `agent_mode` | `sequential` | Si el orquestador ejecuta inline o puede delegar a subagentes |
| `interaction_mode` | `interactive` | Cuantas pausas y confirmaciones pide el flujo |
| `namespaces` | `[]` | Metadata de specs por dominio; no crea carpetas nuevas |
| `testing.strict_tdd` | `false` | Si `apply` y `verify` cargan reglas extra de TDD estricto |
| `modules.skill_registry` | `true` | Si fases técnicas pueden resolver skills del proyecto |
| `modules.model_routing` | `false` | Si se usan modelos distintos por fase |

Puntos a recordar:

- `model_assignments` puede estar presente aunque no siempre tenga efecto operativo.
- El routing por fase importa sobre todo cuando el editor soporta delegación y `modules.model_routing` esta activado.
- `modules.skill_registry` se mantiene en `true` para que el workflow pueda inyectar estandares del proyecto sin volver publicas esas skills.

## 5. Convenciones importantes

- En paths de specs se usa `NNN-capability`: `capability` es la unidad versionable de spec.
- `domain` se usa como agrupacion conceptual o explicación funcional, por ejemplo en `domain-brief`.
- Toda la persistencia durable vive en Markdown dentro del repo.
- Los cambios a templates son forward-only: mejoran artefactos nuevos, no reescriben historico.

### Analisis cross-domain con `impact-map.md`

- La clasificación puede ser `obligatorio`, `recomendado` u `opcional`.
- Es `obligatorio` cuando el change cruza dominios, contratos compartidos, templates del workflow o riesgo funcional alto.
- Es `recomendado` cuando el cambio parece local pero tiene downstream flows o dependencias que conviene revisar.
- Es `opcional` solo para fixes acotados sin contratos ni efectos aguas abajo; la omisión debe quedar justificada.
- Si el mapa existe, `spec`, `design`, `tasks`, `verify` y `archive` lo releen y refinan; no se crean copias paralelas.
- Los examples estáticos viven en `docs/examples/impact-map-required.md` y `docs/examples/impact-map-optional.md`.

## 6. Como leer el repo

Usa este orden:

1. `README.md` para entender que trae el template y como arrancar.
2. `docs/workflow-guide.md` para la interfaz pública, el flujo real y los artefactos.
3. `docs/workflow-sources.md` para entender por que el workflow esta armado asi.
4. `.agents/orchestrator.md` y `.agents/skills/` si necesitas el contrato operativo exacto.
