---
name: domain-brief
description: "Generar o regenerar la descripción funcional del sistema a partir de las specs vigentes. Usar cuando el usuario ejecuta /sdd:domain-brief o necesita un resumen funcional actualizado."
metadata:
  version: "2.0"
---

## Purpose

Generar `docs/domain-brief.md`: un documento corto y legible que explica QUÉ hace el sistema desde la perspectiva funcional, sin detalles de implementación.

Este brief se regenera leyendo las specs consolidadas actuales. No reemplaza las specs: las resume para alguien que necesita entender el producto o el dominio sin leer todo `openspec/specs/`.

Sos un EJECUTOR. NO lances subagentes.

## Inputs

- Specs consolidadas en `openspec/specs/`.

## Context Load

Leer:

1. `openspec/config.yaml`
2. `.agents/rules.md` para reglas generales del proyecto
3. `.agents/personality.md` para tono y filosofía de comunicación
4. Si `openspec/config.yaml` define `communication.compression`, leer `.agents/skills/caveman/SKILL.md` para las reglas operativas de cada nivel
5. todas las specs vigentes dentro de `openspec/specs/`

Si no hay specs consolidadas, la fase debe retornar `blocked`.

## Steps

### Step 1: Relevar capabilities vigentes

Listar todas las specs consolidadas y extraer:

- nombre de la capability (`NNN-capability`)
- problema o necesidad que cubre
- funcionalidades principales
- relaciones relevantes con otras specs

En los paths de specs, `capability` sigue siendo la unidad versionable. Para el brief, podés agrupar varias capabilities dentro de un dominio funcional más amplio si eso vuelve la lectura más clara. Si no hace falta agrupar, un dominio puede coincidir con una sola capability.

### Step 2: Sintetizar para un lector no técnico

El domain brief NO es una copia de las specs. Tiene que responder, en lenguaje llano:

- que es el sistema
- que problemas resuelve
- cuales son sus dominios o áreas funcionales principales
- qué capabilities vigentes sostienen cada dominio
- como se relacionan entre si

### Step 3: Usar el template local

Tomar como base `assets/domain-brief.template.md`.

Ese template define la estructura mínima esperada del documento:

- presentación general del sistema
- dominios funcionales
- lista de capabilities vigentes por dominio
- relaciones entre dominios
- glosario opcional si aporta claridad

### Step 4: Escribir el brief

Crear o sobrescribir `docs/domain-brief.md`.

El documento se regenera completo en cada corrida; no es incremental.

## Persistence

Escribir:

- `docs/domain-brief.md`

## Return Envelope

```yaml
status: success | blocked
summary: ""
artifacts:
  - docs/domain-brief.md
next: "ninguno"
risks:
  - ""
skill_resolution: disabled | direct
```

## Rules

- No copiar las specs literalmente.
- No incluir detalles de implementación.
- Escribir para un humano NO técnico que quiere entender qué hace el sistema.
- Referenciar las capabilities o specs por nombre para mantener trazabilidad.
- Agrupar por dominio solo cuando mejore la claridad; no forzar taxonomías artificiales.


## Optional Modules

- No hay módulos obligatorios.
