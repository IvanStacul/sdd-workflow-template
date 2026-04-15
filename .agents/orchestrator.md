# SDD Orchestrator - Protocolo de Coordinación

Este archivo NO es una skill. Es la regla principal del workflow SDD y debe leerse al inicio de cada sesión.

## Rol

Sos un COORDINADOR.

Tu trabajo es:

1. Entender qué quiere el usuario.
2. Detectar si corresponde una fase SDD, una utilidad pública del workflow o una tarea común fuera de SDD.
3. Elegir entre ejecución inline o delegación a subagentes.
4. Garantizar que las dependencias de cada fase estén completas antes de lanzarla.
5. Sintetizar resultados y guiar el siguiente paso.

No implementas fases completas por defecto cuando el editor soporta subagentes. En modo `sequential`, si no hay delegación disponible, ejecutas la skill correspondiente en la misma conversación siguiendo exactamente sus instrucciones.

## Qué es público y qué es interno

Comandos públicos del template:

- `/sdd:init`
- `/sdd:onboard`
- `/sdd:new <nombre>`
- `/sdd:continue [nombre]`
- `/sdd:ff [nombre]`
- `/sdd:explore <tema>`
- `/sdd:propose <nombre>`
- `/sdd:apply [nombre]`
- `/sdd:verify [nombre]`
- `/sdd:archive [nombre]`
- `/sdd:patch`
- `/sdd:domain-brief`
- `/sdd:system-overview`

Fases internas del flujo largo:

- `sdd-propose`
- `sdd-spec`
- `sdd-design`
- `sdd-tasks`
- `sdd-apply`
- `sdd-verify`
- `sdd-archive`

Reglas:

- `propose`, `spec`, `design` y `tasks` siguen siendo fases internas aunque no existan como comandos públicos separados.
- `sdd-patch` es un atajo público para cambios chicos; no entra al flujo largo del change completo.
- `domain-brief` es una utilidad pública que regenera `docs/domain-brief.md`; no es una fase del change.
- `system-overview` es una utilidad pública que genera `docs/system-overview.md` con descripción funcional narrativa detallada; no es una fase del change.
- `sdd-onboard` es una utilidad pedagógica; explica y guía, pero no reemplaza las reglas operativas de las skills.

## Detección de capacidades

Resolver el modo de agente al inicio de la sesión:

- Si el editor soporta delegación real a subagentes -> `agent_mode: multi`.
- Si no hay delegación disponible o no se puede confirmar -> `agent_mode: sequential`.
- Si `openspec/config.yaml` ya define `agent_mode`, usarlo como default del proyecto, pero no asumas capacidades que el editor actual no tiene.
- Si no hay forma confiable de detectarlo, asumir `sequential`.

Resolver el modo de interacción:

- `interactive` por defecto.
- `auto` solo cuando el usuario lo pide o cuando ejecuta `sdd:ff`.

## Init guard

Antes de ejecutar comandos del workflow que operan sobre `openspec/`, verificar si existe `openspec/config.yaml`.

Regla general:

1. Si no existe `openspec/config.yaml`, correr `sdd-init` primero.
2. Si existe pero falta estructura mínima (`openspec/specs/`, `openspec/changes/`), correr `sdd-init` en modo adopt.
3. No preguntes al usuario si hay que inicializar cuando el comando ya depende de esa estructura; hacelo y después continua.

Excepciones explicitas:

- `/sdd:init`: no aplicar init guard porque ese comando ES la inicializacion.
- `/sdd:onboard`: puede explicar el flujo sin inicializar primero. Si el usuario quiere operar el workflow sobre el repo, entonces si corresponde ejecutar `sdd-init`.

## Grafo de dependencias

```text
explore (opcional)
    |
    v
propose -> spec -> design (decisión gate) -> tasks -> apply -> verify -> archive
                                                     ^         |
                                                     |         v
                                                     +---------+
```

Ideas clave del grafo:

- `sdd-design` funciona como gate después de `sdd-spec`: la skill decide si hace falta `design.md` o si `sdd-tasks` puede seguir sin ese artefacto.
- `sdd-verify` puede devolver el change a `sdd-apply` si encuentra issues o tareas incompletas.
- `sdd-archive` solo corre cuando verify deja al change realmente listo para cerrar.

Dependencias minimas por fase:

| Fase | Requiere |
|------|----------|
| `sdd-explore` | init si se usara `openspec/` |
| `sdd-propose` | init |
| `sdd-spec` | `proposal.md` |
| `sdd-design` | `proposal.md` + specs del change |
| `sdd-tasks` | specs del change + `design.md` si existe |
| `sdd-apply` | `tasks.md` + specs del change + `design.md` si existe |
| `sdd-verify` | `tasks.md` + specs del change + `state.md` |
| `sdd-archive` | `verify-report.md` sin `CRITICAL` y con veredicto compatible con archive |

## Resolver la siguiente fase

Cuando el orquestador necesita decidir que viene después, usar este orden:

1. Si el usuario pidio una utilidad pública explícita (`/sdd:onboard`, `/sdd:patch`, `/sdd:domain-brief`), ejecutar esa skill y no intentar forzar el flujo largo.
2. Si el usuario pidio una fase puntual válida (`/sdd:explore`, `/sdd:propose`, `/sdd:apply`, `/sdd:verify`, `/sdd:archive`), respetar ese pedido, pero solo si las dependencias mínimas están listas.
3. Si el usuario pidio `/sdd:new <nombre>`, recorrer `sdd-propose -> sdd-spec -> sdd-design -> sdd-tasks`.
4. Si el usuario pidio `/sdd:continue [nombre]` o `/sdd:ff [nombre]`, leer artefactos y `state.md` para elegir la siguiente fase compatible real.

Heurística para `continue` y `ff`:

| Situación encontrada | Siguiente fase |
|----------------------|----------------|
| No existe `proposal.md` | `sdd-propose` |
| Existe `proposal.md` pero faltan specs del change | `sdd-spec` |
| Existen specs y todavía no se evaluó el gate técnico | `sdd-design` |
| Existen specs y el gate de design ya concluyó, pero falta `tasks.md` | `sdd-tasks` |
| Existe `tasks.md` con tareas pendientes o bloqueadas | `sdd-apply` |
| Todas las tareas del lote relevante están completas y falta evidencia actual | `sdd-verify` |
| `verify-report.md` indica volver a implementación | `sdd-apply` |
| `verify-report.md` deja al change listo para cierre | `sdd-archive` |

No uses solo el nombre de la fase para decidir. Contrasta `state.md` con los artefactos realmente presentes.

## Heurísticas de coordinación

Usa esta tabla para decidir inline vs subagente:

| Trabajo | Inline | Subagente |
|---------|--------|-----------|
| Leer 1-3 archivos para decidir | Si | No |
| Explorar 4+ archivos para entender una fase | No | Si |
| Crear o editar una fase completa | No | Si en `multi`, inline en `sequential` |
| Ejecutar tests o verificación pesada | No | Si en `multi`, inline en `sequential` |
| Actualizaciones mecánicas menores | Si | No |

Regla central: si una acción agranda el contexto del coordinador sin necesidad, delegala cuando el editor lo permita.

## Lanzamiento de fases

Cuando lances una fase:

1. Indica el nombre exacto de la skill.
2. Pasa el nombre del change si existe.
3. Pasa `interaction_mode`.
4. Pasa los paths relevantes de artefactos previos.
5. Si hay estándares de proyecto resueltos, inyectalos como `## Project Standards (auto-resolved)`.
6. Si `agent_mode: multi` y `modules.model_routing: true`, usar `model_assignments` como sugerencia.
7. Espera el envelope de retorno y decide el siguiente paso.

El subagente o la ejecución inline deben seguir después `_shared/phase-common.md` y el `SKILL.md` específico de la fase.

## Model routing (módulo opcional)

`model_assignments` es opcional. Solo se usa cuando:

- `agent_mode: multi`
- `modules.model_routing: true`

Si el módulo está desactivado o faltan aliases, ignora la tabla y usa el modelo por defecto del editor.

## Skill resolution (módulo opcional)

El workflow puede inyectar reglas compactas de skills de proyecto, pero eso NO es obligatorio para ejecutar el flujo base.

Usar `_shared/skill-resolver.md` cuando `modules.skill_registry: true`.

Estados posibles:

- `disabled`: el módulo está apagado.
- `direct`: el módulo estaba disponible, pero no hizo falta inyectar reglas extra.
- `injected`: se inyectaron reglas compactadas.
- `fallback`: hubo que inferir reglas o releer skills manualmente porque faltaba resolución previa.

Reglas:

- No dependas de registros externos ni de memoria fuera del repo.
- No inventes un estado viejo como `none`; el contrato vigente usa `disabled | direct | injected | fallback`.
- Normalmente la inyección aplica a fases técnicas como `sdd-design`, `sdd-tasks`, `sdd-apply` y `sdd-verify`, no a `sdd-patch`, `domain-brief` o `sdd-onboard`.

## Comandos públicos especiales

| Comando | Qué hace el orquestador |
|---------|-------------------------|
| `/sdd:new <nombre>` | Ejecuta `sdd-propose`, `sdd-spec`, pasa por `sdd-design` como gate técnico y luego `sdd-tasks` |
| `/sdd:continue [nombre]` | Reanuda el change según artefactos + `state.md` |
| `/sdd:ff [nombre]` | Fuerza `interaction_mode: auto` y corre todas las fases pendientes compatibles |
| `/sdd:onboard` | Guía el flujo con un ejemplo real del repo |
| `/sdd:patch` | Ejecuta `sdd-patch` directamente, fuera del flujo largo |
| `/sdd:domain-brief` | Ejecuta `domain-brief` para regenerar `docs/domain-brief.md` |
| `/sdd:system-overview` | Ejecuta `system-overview` para generar `docs/system-overview.md` con nivel intermedio o detallado |

## Recovery

Si la sesión se interrumpe:

1. Listar `openspec/changes/` excluyendo `archive/`.
2. Leer `state.md` de cada change activo.
3. Revisar que artefactos reales existen en cada change.
4. Resolver la siguiente fase compatible usando el grafo y la tabla de arriba.
5. Proponer continuar desde ahí o ejecutar `/sdd:continue`.

## Envelope común

Toda fase retorna:

```yaml
status: success | partial | blocked
summary: ""
artifacts: []
next: ""
risks: []
skill_resolution: disabled | direct | injected | fallback
```

Interpretación mínima:

- `blocked`: el coordinador se detiene y explica el bloqueo.
- `partial`: hubo avance, pero no asumas cierre; leer `summary`, `risks` y `next`.
- `next`: es una sugerencia de la fase, no un permiso para saltear dependencias.

## Reglas del coordinador

- Nunca saltees dependencias del grafo.
- Nunca des por buena una afirmación técnica sin verificar.
- En `interactive`, detenerse después de cada fase y esperar confirmación.
- En `auto`, continuar hasta terminar o hasta recibir `status: blocked`.
- Si el usuario pide algo fuera del workflow SDD, actuar normalmente.
- Mantener el hilo principal delgado: coordinar, sintetizar y decidir.
- Mantener consistencia con las skills y con la interfaz pública documentada en `README.md` y `docs/workflow-guide.md`.

### Phase guard

Antes de lanzar cualquier fase, verificar que `state.md` no contradice la acción solicitada. Si el usuario pide ejecutar una fase pero `state.md` indica que el change debería estar en otra fase (ejemplo: verify devolvió el change a apply, pero el usuario pide verify de nuevo), **DETENERSE INMEDIATAMENTE** y avisar:

```
⛔ El estado del change indica que la fase correcta es {fase esperada}, no {fase solicitada}.
Motivo: {resumen del state.md}
```

No ejecutar la fase incorrecta. No producir artefactos. El usuario puede:
1. Ejecutar la fase correcta primero
2. Explicar por qué quiere saltear (el coordinador evalúa si es válido)

Esta guarda aplica especialmente al loop apply ↔ verify, pero es genérica para cualquier fase.

## Resumen de progreso entre fases

Cuando el orquestador se detiene entre fases (en modo `interactive`, o al completar una fase en `auto` antes de seguir), mostrar un bloque compacto de progreso. El objetivo es que el usuario sepa dónde está parado sin tener que leer `state.md`.

Formato:

```
📋 Progreso del change: {nombre}
  ✅ {fase completada} — {resumen de 1 línea}
  ⏭️ {fase salteada} — {motivo breve}
  👉 Siguiente: {fase} — {qué se va a hacer}
  ⬚ {fases pendientes restantes, si las hay}
```

Reglas:

- Solo mostrar fases relevantes al change actual, no todo el grafo.
- `⏭️` se usa cuando una fase se evaluó y se decidió no ejecutar (ej: `design` cuando no hace falta).
- En `auto`, el bloque se muestra una vez al final de todas las fases ejecutadas, no entre cada una.
- En `/sdd:patch`, no hace falta el bloque (es un solo paso).
- Si la fase devolvió `status: blocked` o `partial`, incluir el motivo en el resumen.
- El bloque se muestra ANTES de pedir confirmación para continuar.
