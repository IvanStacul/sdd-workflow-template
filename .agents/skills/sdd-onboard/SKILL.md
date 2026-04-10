---
name: sdd-onboard
description: >
  Guía interactiva paso a paso del flujo SDD usando el código real del proyecto.
  Trigger: Cuando el usuario es nuevo en el flujo o dice "onboard", "tutorial", "cómo funciona".
metadata:
  version: "1.0"
---

## Purpose

Guiar al usuario por el flujo SDD completo usando su proyecto real como ejemplo. No es teórico — cada paso se demuestra con código y specs del proyecto actual.

Sos un EJECUTOR. NO lances subagentes.

## What to Do

### Step 1: Verificar estado del proyecto

```
¿Existe openspec/?
├── NO → Ejecutar sdd-init primero, luego continuar
└── SÍ → Leer config.yaml para entender el contexto
```

### Step 2: Presentar el flujo

Explicar el flujo en términos simples, usando el proyecto como contexto:

```markdown
## Flujo SDD — Cómo funciona

Tu proyecto es un {tipo de proyecto} con {stack}. 
El flujo SDD te ayuda a planificar y ejecutar cambios de forma estructurada.

### Las fases

1. **Explorar** (`/opsx:explore`) — Investigar antes de actuar
   → "¿Cómo funciona X en el código actual?"

2. **Proponer** (`/opsx:propose`) — Definir qué vas a cambiar y por qué
   → "Quiero agregar {feature} porque {razón}"

3. **Especificar** (automático) — Definir QUÉ debe hacer el sistema
   → Requisitos con escenarios Given/When/Then

4. **Diseñar** (opcional) — Definir CÓMO implementarlo
   → Solo si hay decisiones arquitectónicas

5. **Tareas** (automático) — Plan de implementación
   → Lista de tareas con archivos y criterios

6. **Implementar** (`/opsx:apply`) — Escribir código
   → Siguiendo las specs como guía

7. **Verificar** (automático) — Confirmar que cumple specs
   → Cada scenario verificado

8. **Archivar** (`/opsx:archive`) — Cerrar, retro, mejorar
   → Retro obligatoria + propagación de lecciones

### Para cambios pequeños
`/opsx:patch` — Todo en un paso, sin flujo completo
```

### Step 3: Proponer mini-ejercicio

Buscar en el proyecto algo CONCRETO y PEQUEÑO para demostrar:

```
Estrategias de búsqueda (en orden de preferencia):
1. Si hay specs existentes → proponer agregar un edge case a una spec
2. Si hay TODOs en el código → proponer resolver uno
3. Si hay código sin validación → proponer agregar una validación
4. Último recurso → proponer agregar documentación a una función compleja
```

Presentar al usuario:

```markdown
### 🎯 Mini-ejercicio

Encontré algo que podemos usar de ejemplo:
{descripción del cambio pequeño}

¿Querés que lo hagamos juntos paso a paso? Puedo usar `/opsx:patch`
para un cambio así de chico, o el flujo completo `/opsx:new` si
preferís ver todas las fases.
```

### Step 4: Guiar paso a paso

Si el usuario acepta, ejecutar el flujo elegido PASO A PASO:
- Después de cada fase, explicar qué se hizo y por qué
- Mostrar los archivos generados
- Preguntar si tiene dudas antes de continuar

### Step 5: Resumen final

```markdown
## ✅ Onboarding Completo

Acabás de completar tu primer cambio con SDD. Resumen:

### Qué se generó
- {lista de archivos en openspec/}

### Comandos que usaste
- {lista de comandos}

### Para el día a día
- Cambios grandes/medianos → `/opsx:new <nombre>`
- Cambios pequeños → `/opsx:patch`
- Continuar algo pendiente → `/opsx:continue`
- Ver estado → leer `openspec/changes/` 

### Tip
El flujo se adapta a vos. Si una fase no aplica (ej: design para un
cambio simple), se salta. La retro del archive mejora el flujo con el tiempo.
```

## Rules

- SIEMPRE usar código/specs reales del proyecto — no inventar ejemplos
- SIEMPRE detenerse después de cada paso y esperar al usuario
- Si el proyecto está vacío (sin código), explicar el flujo teóricamente y sugerir empezar con sdd-init + un primer spec
- Mantener el tono didáctico pero no condescendiente
- No abrumar con toda la información de una vez — ir paso a paso
