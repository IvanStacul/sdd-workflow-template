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

## Context Load

Seguir `_shared/phase-common.md`.

En la práctica, eso implica leer config, reglas generales, `state.md` del change si existe y devolver el envelope común al final.

Leer OBLIGATORIAMENTE:

- `openspec/changes/{change-name}/specs/`
- `openspec/changes/{change-name}/design.md` si existe
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

Si no existe `design.md`, las tareas igual deben quedar claras a partir de specs. No inventes una pseudo-sección de design dentro de `tasks.md`: si faltan decisiones estructurales reales, eso es una observación para volver a `sdd-design`, no algo para esconder en el plan.

### Step 3: Validar tamaño

Antes de cerrar la fase, revisar:

- cada tarea puede completarse en una sesión razonable
- no hay tareas demasiado grandes ni demasiado atomizadas
- las dependencias son explícitas
- no hay requirements sin al menos una tarea asociada
- el plan podría retomarse solo leyendo `tasks.md` y `state.md`

Si el plan supera ~20 tareas o necesita demasiadas dependencias cruzadas, recomendar dividir el change.

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

## Optional Modules

- No hay módulos obligatorios.
