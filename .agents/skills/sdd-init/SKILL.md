---
name: sdd-init
description: >
  Inicializar el flujo SDD en un proyecto. Detecta stack, estructura existente,
  y genera config.yaml, AGENTS.md, y estructura de documentación.
  Trigger: Cuando el usuario ejecuta /opsx:init o quiere iniciar el flujo SDD 
  en un proyecto, o dice "sdd init", "iniciar sdd" u "openspec init".
metadata:
  version: "1.0"
---

## Purpose

Eres un subagente encargado de inicializar el contexto de desarrollo basado en especificaciones (SDD) en un proyecto. Detectar el stack técnico, evaluar la estructura existente, y generar los archivos necesarios para operar el flujo.

Sos un EJECUTOR — hacé el trabajo directamente. NO lances subagentes.

## What to Do

### Step 1: Detectar contexto del proyecto

Leer el proyecto para entender:
- Tech stack (package.json, composer.json, go.mod, pyproject.toml, etc.)
- Convenciones existentes (linters, formatters, test frameworks)
- Patrones de arquitectura en uso

### Step 2: Detectar estructura existente

Evaluar qué existe YA en el proyecto:

```
Verificar existencia de:
├── AGENTS.md (o equivalentes: CLAUDE.md, .cursorrules, etc.)
├── openspec/
│   ├── config.yaml
│   ├── specs/
│   └── changes/
├── docs/
│   ├── known-issues.md
│   ├── workflow-changelog.md
│   └── domain-brief.md
├── .agents/ (o .cursor/skills/, .claude/skills/, etc.)
└── Otras estructuras de specs (docs/specs/, .skills/, etc.)
```

Clasificar en modo de init:

| Modo | Condición | Acción |
|------|-----------|--------|
| **fresh** | No existe `openspec/` ni estructura de specs | Crear todo desde cero |
| **migrate** | Existe estructura de specs diferente (ej: `docs/specs/`) | Auditar, proponer mapeo, preguntar antes de actuar |
| **adopt** | Ya existe `openspec/` | Verificar consistencia, completar lo que falte |

**Si es modo migrate**: presentar un reporte de qué se encontró vs qué espera el flujo SDD. Proponer plan de migración. PREGUNTAR al usuario antes de ejecutar.

### Step 3: Configurar política de AGENTS.md

Preguntar al usuario qué modo prefiere para la gestión de `AGENTS.md`:

| Modo | Comportamiento | Cuándo usarlo |
|------|---------------|---------------|
| `managed` | El flujo controla todo el AGENTS.md | Repo nuevo, o el usuario quiere que el flujo gobierne |
| `section` | Solo se toca la sección delimitada `<!-- sdd-workflow:start/end -->` | Repo con AGENTS.md que tiene reglas propias |
| `readonly` | Nunca se modifica AGENTS.md — las reglas viven solo en SKILLs | El usuario no quiere que se toque su archivo |

Guardar la elección en `openspec/config.yaml` como `agents_md_policy`.

### Step 4: Crear/actualizar openspec/config.yaml

Usar el template en `assets/config.template.yaml` como base. Completar con:
- Contexto del proyecto detectado en Step 1
- Namespaces (preguntar al usuario si quiere definir algunos o dejar vacío)
- Política de AGENTS.md elegida en Step 3
- TDD habilitado/deshabilitado (detectar si hay test runner; preguntar preferencia)

**Si `openspec/config.yaml` ya existe**: LEER el existente, comparar con el template, y proponer al usuario:
- `mantener`: dejar el existente como está
- `merge`: agregar campos faltantes sin tocar los existentes
- `reemplazar`: generar uno nuevo (backup del anterior)

### Step 5: Crear/actualizar AGENTS.md

Según la política elegida:

**Si `managed`**: Crear `AGENTS.md` completo usando `assets/agents-section.template.md` como contenido.

**Si `section`**: Si `AGENTS.md` existe, agregar la sección delimitada al final. Si no existe, crear solo con la sección delimitada.

**Si `readonly`**: No tocar `AGENTS.md`. Informar al usuario que las reglas viven en los SKILLs.

### Step 6: Crear estructura de directorios

```bash
mkdir -p openspec/specs
mkdir -p openspec/changes/archive
mkdir -p docs
```

### Step 7: Crear archivos de documentación

Usando los templates de `assets/`:
- `docs/known-issues.md` ← de `assets/known-issues.template.md`
- `docs/workflow-changelog.md` ← de `assets/workflow-changelog.template.md`

**Si alguno ya existe**: NO sobrescribir. Informar que ya existe.

### Step 8: Detectar editores y ofrecer mirrors

Preguntar al usuario qué editores/agentes usa. Ofrecer generar copias de `.agents/` para cada editor.

Si el usuario acepta, ejecutar el script `scripts/mirror-agents.sh` con los editores seleccionados, o generar las copias manualmente si el script no está disponible.

### Step 9: Retornar resumen

```markdown
## SDD Inicializado

**Proyecto**: {nombre}
**Stack**: {stack detectado}
**Modo init**: {fresh | migrate | adopt}
**AGENTS.md policy**: {managed | section | readonly}
**TDD**: {habilitado | deshabilitado | no disponible}

### Estructura Creada/Verificada
- openspec/config.yaml {✅ creado | ✅ actualizado | ℹ️ existente}
- openspec/specs/ {✅ creado | ℹ️ existente}
- openspec/changes/ {✅ creado | ℹ️ existente}
- AGENTS.md {✅ creado | ✅ sección agregada | ⏭️ readonly}
- docs/known-issues.md {✅ creado | ℹ️ existente}
- docs/workflow-changelog.md {✅ creado | ℹ️ existente}

### Siguiente paso
Ejecutar `/opsx:explore <tema>` o `/opsx:propose <change-name>`.
```

## Rules

- NUNCA crear specs placeholder — las specs se crean con sdd-spec
- SIEMPRE detectar el stack real, no adivinar
- Si hay estructura existente, AUDITAR y PREGUNTAR antes de modificar
- Mantener context en config.yaml CONCISO — máximo 10 líneas
- Si el proyecto tiene un `docs/` con contenido propio, NO borrar nada
- Sobre de retorno según **Sección F** de `_shared/phase-common.md`
