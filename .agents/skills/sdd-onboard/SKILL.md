---
name: sdd-onboard
description: "Guiar al usuario de forma interactiva y paso a paso por el workflow SDD usando el proyecto real como ejemplo. Usar cuando el usuario ejecuta /sdd:onboard o necesita aprender el flujo(dice 'onboard', 'tutorial', 'cómo funciona')."
metadata:
  version: "2.0"
---

## Purpose

Guiar al usuario por el workflow SDD completo usando el repo real como ejemplo. No es una explicación teórica aislada: cada paso debe anclarse en archivos, specs o código del proyecto actual.

Sos un EJECUTOR. NO lances subagentes.

## Inputs

- Estado actual del proyecto.

## Context Load

Leer:

- `openspec/config.yaml` si existe
- `openspec/specs/` si existen specs
- `docs/workflow-guide.md` si existe
- código del proyecto suficiente para proponer un ejemplo pequeño

## Steps

### Step 1: Verificar init

Si falta `openspec/config.yaml`, explicar que onboarding puede dar una vista general, pero que el primer paso real del workflow es `sdd-init`.

Si el usuario quiere seguir operando el flujo sobre el repo, correr `sdd-init` primero y después continuar con el onboarding.

### Step 2: Explicar fases

Explicar el flujo distinguiendo claramente comandos públicos de fases internas.

Usar esta idea base:

- `/sdd:new <nombre>` es la puerta de entrada normal al flujo completo
- ese flujo recorre `propose -> spec -> design (si aplica) -> tasks -> apply -> verify -> archive`
- `propose`, `spec`, `design` y `tasks` existen como fases del workflow, aunque no siempre existan como comandos públicos separados
- `/sdd:continue` y `/sdd:ff` sirven para retomar o avanzar un change ya abierto
- `/sdd:explore` sirve para investigar antes de proponer
- `/sdd:patch` es un atajo público para cambios chicos con un único `patch.md`
- `/sdd:domain-brief` no es una fase del change: regenera `docs/domain-brief.md` desde specs consolidadas

Si existe `docs/workflow-guide.md`, usarlo como apoyo pedagógico para que la explicación siga el flujo público real del repo.

### Step 3: Proponer un mini ejercicio

Buscar algo pequeno y real del repo:

- edge case faltante
- TODO
- validación chica
- mejora documental acotada

Priorizar, en este orden:

1. edge case o aclaracion chica sobre una spec existente
2. TODO o bug acotado que pueda resolverse con `patch`
3. validación o mejora chica del código
4. mejora documental puntual si no hay mejor ejemplo técnico

Presentar el ejercicio explicando por que conviene usar `/sdd:patch` o `/sdd:new <nombre>` según el alcance.

### Step 4: Guiar paso a paso

Si el usuario acepta, ejecutar el flujo elegido PASO A PASO.

Después de cada paso o fase:

- explicar que se hizo
- mostrar artefactos generados
- esperar confirmacion del usuario

No saltees de una fase a otra como si el onboarding fuera una automatización muda. El objetivo es que el usuario entienda que paso y por que.

### Step 5: Cerrar con resumen operativo

Al terminar el onboarding, resumir:

- que artefactos se generaron o revisaron
- que comando uso el usuario o que comando debería usar la próxima vez
- cuando conviene `patch` y cuando conviene el flujo completo
- cuál es el siguiente paso recomendado para seguir practicando

## Persistence

- No escribe artefactos propios salvo que el usuario acepte ejecutar fases reales del workflow.

## Return Envelope

```yaml
status: success | partial
summary: ""
artifacts: []
next: "/sdd:new <nombre> o /sdd:patch"
risks:
  - ""
skill_resolution: disabled
```

## Rules

- Usar siempre ejemplos reales del repo.
- Detenerse después de cada paso importante y esperar confirmación del usuario.
- Si el proyecto está vacío o casi sin contexto, explicar el flujo de forma guiada y sugerir `sdd-init` + un primer change pequeño.
- Distinguir siempre comandos públicos de fases internas.
- No presentar `spec`, `design` o `tasks` como comandos públicos si no existen como tales.
- Mencionar `patch` y `domain-brief` en su rol real: utilidad pública, no fase interna del change largo.
- No abrumar con toda la teoría de una vez.
- Mantener el tono didáctico y colaborativo.

## Optional Modules

- No hay módulos obligatorios.
