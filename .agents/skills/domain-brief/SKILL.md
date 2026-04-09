---
name: domain-brief
description: >
  Generar o regenerar la descripción funcional del dominio de la aplicación.
  Trigger: Cuando se necesita un resumen actualizado del dominio de negocio.
metadata:
  version: "1.0"
---

## Purpose

Generar `docs/domain-brief.md` — un documento que describe QUÉ hace la aplicación desde la perspectiva funcional. Similar a lo que haría un analista funcional. Se regenera leyendo las specs vigentes.

Sos un EJECUTOR. NO lances subagentes.

## What to Do

### Step 1: Leer specs vigentes

Leer TODAS las specs en `openspec/specs/`. Cada spec describe un dominio funcional.

### Step 2: Leer config

Leer `openspec/config.yaml` para entender el contexto general del proyecto.

### Step 3: Generar domain-brief.md

Usar template de `assets/domain-brief.template.md`.

El domain-brief NO es una copia de las specs — es una S��NTESIS legible para humanos no técnicos. Debe responder:

- ¿Qué es este sistema?
- ¿Qué problemas resuelve?
- ¿Qué funcionalidades tiene?
- ¿Cómo se relacionan entre sí?

### Step 4: Escribir

Crear/sobrescribir `docs/domain-brief.md`.

## Rules

- Este documento se REGENERA completamente cada vez — no es incremental
- Escribir para un humano NO técnico que quiere entender qué hace el sistema
- NO incluir detalles de implementación
- Referenciar las specs por nombre para trazabilidad
- Si no hay specs en `openspec/specs/`, advertir que no se puede generar
