---
name: sdd-init
description: >
  Inicializar el flujo SDD en un proyecto. Detecta stack, estructura existente,
  y genera config.yaml, AGENTS.md, personality.md, rules.md, y estructura de documentación.
  Trigger: Cuando el usuario ejecuta /opsx:init o quiere iniciar el flujo SDD
  en un proyecto, o dice "sdd init", "iniciar sdd" u "openspec init".
metadata:
  version: "1.1"
---

## Purpose

Inicializar el contexto SDD (Spec-Driven Development) en un proyecto. Detectar el stack técnico, evaluar la estructura existente, configurar archivos de agente, y generar la estructura de documentación.

Sos un EJECUTOR — hacé el trabajo directamente. NO lances subagentes.

## What to Do

### Step 1: Detectar contexto del proyecto

Leer el proyecto para entender:
- Tech stack (package.json, composer.json, go.mod, pyproject.toml, etc.)
- Convenciones existentes (linters, formatters, test frameworks)
- Patrones de arquitectura en uso
- Test runner y comando (detectar si TDD es viable)

### Step 2: Detectar estructura existente

```
Verificar existencia de:
├── AGENTS.md (o equivalentes: CLAUDE.md, .cursorrules, etc.)
├── .agents/orchestrator.md, personality.md, rules.md
├── openspec/
│   ├── config.yaml
│   ├── specs/
│   └── changes/
├── docs/
│   ├── known-issues.md
│   ├── workflow-changelog.md
│   └── domain-brief.md
├── .agents/skills/ (y otras carpetas de editores)
└── Otras estructuras de specs (docs/specs/, .skills/, etc.)
```

Clasificar en modo de init:

| Modo | Condición | Acción |
|------|-----------|--------|
| **fresh** | No existe `openspec/` ni estructura de specs | Crear todo desde cero |
| **migrate** | Existe estructura de specs diferente (ej: `docs/specs/`) | Auditar, proponer mapeo, preguntar antes de actuar |
| **adopt** | Ya existe `openspec/` | Verificar consistencia, completar lo que falte |

**Si es modo migrate**: presentar reporte de qué se encontró vs qué espera el flujo SDD. Proponer plan de migración. PREGUNTAR al usuario antes de ejecutar.

### Step 3: Configurar política de AGENTS.md

Preguntar al usuario qué modo prefiere:

| Modo | Comportamiento |
|------|---------------|
| `managed` | El flujo controla todo el AGENTS.md |
| `section` | Solo se toca la sección delimitada `<!-- sdd-workflow:start/end -->` |
| `readonly` | Nunca se modifica AGENTS.md — reglas viven solo en SKILLs |

### Step 4: Detectar capacidades de subagentes

Preguntar: "¿Tu editor soporta delegación a subagentes? (ej: Claude Code con delegate/task)"

Guardar respuesta en config.yaml como `agent_mode: multi | sequential`.

Si multi-agente, preguntar qué modelos tiene disponibles y completar la tabla `model_assignments` en config.yaml con los valores que correspondan (o los defaults).

### Step 5: Crear/actualizar openspec/config.yaml

Usar template `assets/config.template.yaml`. Completar con:
- Contexto del proyecto (Step 1)
- Namespaces (preguntar o dejar vacío)
- Política de AGENTS.md (Step 3)
- Modo de agente y modelos (Step 4)
- TDD (detectar test runner, preguntar preferencia)

**Si ya existe**: LEER, comparar, proponer `mantener` / `merge` / `reemplazar`.

### Step 6: Crear/actualizar archivos de agente

#### `.agents/orchestrator.md`
- Si NO existe → copiar desde template del workflow (ya está en el repo del template)
- Si existe → no tocar (el usuario puede haberlo personalizado)

#### `.agents/personality.md`
- Si NO existe → generar desde `assets/personality.template.md`
- Si existe → no tocar
- Preguntar al usuario si quiere personalizar idioma/tono

#### `.agents/rules.md`
- Si NO existe → generar desde `assets/rules.template.md`
- Si existe → comparar con template, proponer merge si faltan reglas

### Step 7: Crear/actualizar AGENTS.md

Según la política elegida:

**`managed`**: Crear completo. Incluir:
```markdown
# AGENTS.md

Leer los siguientes archivos al inicio de cada sesión:
- [Orquestador](.agents/orchestrator.md) — protocolo de coordinación
- [Personalidad](.agents/personality.md) — tono e idioma
- [Reglas](.agents/rules.md) — reglas generales del proyecto

{contenido de assets/agents-section.template.md}
```

**`section`**: Agregar sección delimitada al final del AGENTS.md existente.

**`readonly`**: No tocar.

### Step 8: Crear estructura de directorios

```bash
mkdir -p openspec/specs
mkdir -p openspec/changes/archive
mkdir -p docs
```

### Step 9: Crear archivos de documentación

Desde `assets/`:
- `docs/known-issues.md` (si no existe)
- `docs/workflow-changelog.md` (si no existe)

### Step 10: Detectar skills de proyecto existentes

Escanear directorios de skills buscando skills NO-SDD:

```
Para cada skill en .agents/skills/, .claude/skills/, .cursor/skills/:
├── Si name NO empieza con "sdd-" Y NO es "_shared" Y NO es "domain-brief"
│   └── Registrar: name, description, tipo inferido
└── Reportar al usuario qué skills de proyecto se detectaron
```

Si no se encontraron y el stack lo sugiere, proponer crear:
"Detecté que usás {Laravel/React/etc}. ¿Querés que cree una skill con las convenciones?"

### Step 11: Detectar editores y ofrecer mirrors

Preguntar qué editores usa. Ejecutar `scripts/mirror-agents.sh` si acepta.

### Step 12: Retornar resumen

```markdown
## SDD Inicializado

**Proyecto**: {nombre}
**Stack**: {stack detectado}
**Modo init**: {fresh | migrate | adopt}
**AGENTS.md policy**: {managed | section | readonly}
**Agent mode**: {multi | sequential}
**TDD**: {habilitado | deshabilitado | no disponible}

### Archivos de Agente
- .agents/orchestrator.md {✅ creado | ℹ️ existente}
- .agents/personality.md {✅ creado | ℹ️ existente}
- .agents/rules.md {✅ creado | ℹ️ existente}
- AGENTS.md {✅ creado | ✅ sección agregada | ⏭️ readonly}

### Estructura OpenSpec
- openspec/config.yaml {✅ creado | ✅ actualizado | ℹ️ existente}
- openspec/specs/ {✅ creado | ℹ️ existente}
- openspec/changes/ {✅ creado | ℹ️ existente}

### Documentación
- docs/known-issues.md {✅ creado | ℹ️ existente}
- docs/workflow-changelog.md {✅ creado | ℹ️ existente}

### Skills de Proyecto Detectadas
{lista o "Ninguna — considerar crear skills para {stack}"}

### Modelos Configurados
{tabla de asignación o "Modo secuencial — tabla no aplica"}

### Siguiente paso
Ejecutar `/opsx:onboard` para tutorial, o `/opsx:new <nombre>` para tu primer change.
```

## Rules

- NUNCA crear specs placeholder — las specs se crean con sdd-spec
- SIEMPRE detectar el stack real, no adivinar
- Si hay estructura existente, AUDITAR y PREGUNTAR antes de modificar
- Mantener context en config.yaml CONCISO — máximo 10 líneas
- Si el proyecto tiene un `docs/` con contenido propio, NO borrar nada
- SIEMPRE preguntar por capacidades de subagentes — no asumir
- Si el usuario no sabe si su editor soporta subagentes, default a sequential
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
