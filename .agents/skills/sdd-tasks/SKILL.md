---
name: sdd-tasks
description: "Descomponer specs y design en tareas implementables, chicas y verificables. Usar después de sdd-spec y, si existe, sdd-design."
metadata:
  version: "2.0"
---

## Purpose

Tomar las specs del change y, si existe, `design.md`, para producir `tasks.md` como plan de implementación ejecutable por lotes.

`tasks.md` no es un resumen informal: es la continuidad operativa que después usa `sdd-apply` para elegir lotes, marcar avance y retomar trabajo sin depender de memoria externa.

Sos un EJECUTOR - escribí el plan directamente. No lances subagentes.

## Inputs

- Nombre del change.
- specs del change.
- design del change, si existe.
- `impact-map.md` si existe.

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change si existe y devolver el envelope común al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/specs/`
- `openspec/changes/{change-name}/design.md` si existe
- `openspec/changes/{change-name}/impact-map.md` si existe
- `_shared/abstraction-guide.md`

Si `openspec/config.yaml` define `rules.tasks`, tratarlas como reglas locales de esta fase. Pueden agregar formato, criterios de granularidad o checks adicionales; complementan esta skill, no la reemplazan.

La referencia a `_shared/abstraction-guide.md` sirve para decidir si conviene separar archivos, helpers o servicios en las tareas. Aun asi, la skill debe dejar una explicación local de por que se parte el trabajo como se parte.

## Steps

### Step 1: Agrupar por fases

Separar el plan por bloques coherentes de implementación. El objetivo no es inventar fases ceremoniales, sino ordenar el trabajo de manera que `sdd-apply` pueda tomar un lote sin romper dependencias.

Usar grupos como:

- infraestructura
- implementación
- integracion
- verificación o limpieza, si aplica

Si existe `impact-map.md`, usarlo para agrupar trabajo cross-domain por contratos, flows o boundaries compartidos, en lugar de esconder esos cruces dentro de tareas genéricas.

Si el change es chico, no fuerces cuatro fases. Pocas fases claras son mejores que una taxonomia artificial.

### Step 2: Redactar tareas

Crear o actualizar `openspec/changes/{change-name}/tasks.md` usando `assets/tasks.template.md`.

Ese template debe nombrarse explícitamente aca porque la skill depende de su estructura. `sdd-apply` usa `tasks.md` como continuidad entre lotes y espera el formato de checklist `- [ ]`.

Cada tarea debe incluir:

- checkbox `- [ ]`
- referencia al requirement
- archivos afectados
- dependencias
- criterio verificable

Formato esperado por tarea:

```markdown
- [ ] 1.1 {Descripción de la tarea} `[REQ-XX]`
  - **Archivos**: `path/to/file.ext`
  - **Depende de**: -
  - **Criterio**: {cuando está completa, de forma verificable}
```

Puntos clave:

- la descripción debe ser accionable, no vaga
- la referencia al requirement conecta la tarea con la spec
- `**Archivos**` ayuda a `sdd-apply` a cargar el contexto correcto
- `**Depende de**` define el orden entre lotes
- `**Criterio**` define cuando puede marcarse `[x]`

Si existe `impact-map.md`, cada dominio secundario, contrato compartido o downstream flow `in-scope` debe quedar cubierto por al menos una tarea verificable o una exclusión explícita. No dejar impactos críticos solo en el mapa.

Cuando una tarea cruza una frontera entre capas o subsistemas (por ejemplo frontend/backend, request/response, import/export, UI/runtime), el `**Criterio**` debe dejar explicito el contrato esperado con un ejemplo minimo observable: payload, shape, parametros, orden o resultado visible. No alcanza con "integrar".

Si no existe `design.md`, las tareas igual deben quedar claras a partir de specs. No inventes una pseudo-sección de design dentro de `tasks.md`: si faltan decisiones estructurales reales, eso es una observación para volver a `sdd-design`, no algo para esconder en el plan.

### Step 3: Validar tamaño

Antes de cerrar la fase, revisar:

- cada tarea puede completarse en una sesión razonable
- no hay tareas demasiado grandes ni demasiado atomizadas
- las dependencias son explícitas
- no hay requirements sin al menos una tarea asociada
- el plan podría retomarse solo leyendo `tasks.md` y `state.md`
- si existe `impact-map.md`, cada contrato o downstream flow `in-scope` quedo convertido en tarea, criterio observable o exclusión justificada

**Límite recomendado: ~15-20 tareas por change.** Si el plan supera ese rango, recomendar dividir.

Si el plan supera ese rango y la división es razonable, no cierres la fase con un `tasks.md` gigante. Devolve `partial` y reruta a materializar el corte en propuesta/specs antes de seguir con implementación.

#### Cómo dividir un change grande

Cuando el plan tiene más de ~20 tareas o demasiadas dependencias cruzadas:

1. **Identificar cortes naturales** — buscar grupos de tareas que pueden verificarse y desplegarse de forma independiente. Señales de un buen corte:
   - las tareas del grupo comparten archivos afectados
   - el grupo implementa un subconjunto completo de requirements
   - el grupo no depende de tareas fuera de él para funcionar

2. **Proponer la división al usuario** — presentar los changes sugeridos con nombre, scope y dependencias entre sí:
   ```
   Change original: {nombre} (~35 tareas)
   
   Propuesta de división:
   1. {nombre}-foundation (12 tareas) — infraestructura y modelos
   2. {nombre}-ui (10 tareas) — componentes y páginas
   3. {nombre}-integration (8 tareas) — conexiones y validaciones
   
   Dependencias: 2 y 3 dependen de 1. 2 y 3 son independientes.
   ```

3. **Materializar el corte, no solo anunciarlo** — si el usuario acepta dividir o el corte ya venia claro desde `proposal.md`, el siguiente paso no es dejar una nota en `tasks.md`. Hay que volver a `sdd-propose`/`sdd-spec` y dejar creados los slices y sus specs acotadas para que otra sesion pueda retomarlos sin depender del contexto conversacional.

4. **Cada change dividido necesita su propia proposal y specs** — no alcanza con partir `tasks.md`. El flujo completo aplica a cada sub-change.

5. **No dividir artificialmente** — si las 25 tareas están tan acopladas que no hay corte limpio, es mejor mantener un solo change y trabajar por lotes en apply. La división forzada genera más overhead que el change grande.

#### Criterios minimos para slices riesgosos

Cuando el plan incluya alguno de estos casos, las tareas deben dejar evidencia minima desde el criterio:

- controller, handler o flujo backend nuevo -> al menos una tarea de test o validacion del flujo completo
- feature interactiva de input, teclado o foco -> al menos un test unitario, smoke runtime o validacion equivalente
- contrato entre capas -> ejemplo minimo de request, response, payload o forma de intercambio

### Step 4: Registrar fase

Actualizar `state.md` siguiendo `_shared/phase-common.md`.

## Persistence

Escribir o actualizar:

- `openspec/changes/{change-name}/tasks.md`
- `openspec/changes/{change-name}/state.md`

## Return Envelope

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - openspec/changes/{change-name}/tasks.md
next: "sdd-apply"
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

## Rules

- Usar siempre el formato `- [ ]`.
- No crear tareas vagas o no verificables.
- Cada tarea debe referenciar el requirement que implementa.
- Cada tarea debe listar archivos afectados.
- Mantener dependencias explícitas.
- Alinear archivos y criterios con las specs.
- Si existe `design.md`, usarlo para resolver orden y dependencias, no para duplicar texto.
- Si continuas un `tasks.md` existente, leerlo antes de actualizarlo.
- Si el plan ya excede el tamano razonable y el corte es claro, detener la fase y materializar la division antes de seguir.
- Si existe `impact-map.md`, no dejar contratos o cruces `in-scope` sin una tarea observable o una exclusión explícita.

## Optional Modules

- No hay módulos obligatorios.
