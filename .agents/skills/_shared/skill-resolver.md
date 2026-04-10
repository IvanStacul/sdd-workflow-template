# Skill Resolver — Detección e Inyección de Skills de Proyecto

> Protocolo compartido para que el orquestador detecte skills de proyecto
> (no-SDD) y las inyecte a subagentes que tocan código.

## Qué es una "skill de proyecto"

Cualquier skill en el proyecto que NO sea parte del flujo SDD:
- NO empieza con `sdd-` en su `name`
- NO es `_shared/`
- NO es `domain-brief`
- Es una skill de tecnología, framework, o convención (ej: `laravel`, `react`, `tailwind`)

## Detección

### Directorios a escanear

```
.agents/skills/
.claude/skills/
.cursor/skills/
.opencode/skills/
.gemini/skills/
```

### Para cada skill encontrada

1. Leer `SKILL.md` → extraer `name` y `description`
2. Clasificar por tipo:

| Palabras clave en description | Tipo |
|------------------------------|------|
| back, backend, api, server, laravel, express, django, rails | `backend` |
| front, frontend, ui, component, react, vue, angular, svelte | `frontend` |
| infra, deploy, ci, docker, kubernetes, terraform, cloud | `infra` |
| test, testing, e2e, unit, integration | `testing` |
| style, css, tailwind, sass, design-system | `styling` |
| db, database, migration, orm, eloquent, prisma | `data` |
| (otros) | `general` |

3. Extraer reglas compactas: leer el body del SKILL.md y condensar las reglas principales en máximo 10 líneas

### Caché

El resultado se cachea para la sesión. Se recarga si:
- El orquestador detecta `skill_resolution: fallback` en un sobre de retorno
- El usuario agrega/modifica una skill durante la sesión

## Inyección

### Cuándo inyectar

Solo a subagentes que TOCAN CÓDIGO o DEFINEN ESTRUCTURA:
- `sdd-tasks` — decide qué archivos crear → necesita saber convenciones
- `sdd-design` — define arquitectura → necesita saber patrones del stack
- `sdd-apply` — implementa → necesita seguir convenciones del stack
- `sdd-verify` — revisa → necesita verificar contra convenciones

NO inyectar a: `sdd-explore`, `sdd-propose`, `sdd-archive`, `sdd-patch`, `domain-brief`

### Cómo inyectar

Agregar al prompt del subagente ANTES de las instrucciones de la fase:

```markdown
## Project Standards (auto-resolved)

### {skill-name} ({tipo})
{reglas compactas — máximo 10 líneas por skill}

### {otra-skill} ({tipo})
{reglas compactas}
```

### Matching por contexto

No inyectar TODAS las skills — solo las relevantes:

```
Para cada tarea/archivo del subagente:
├── Extensión .php, .blade.php → inyectar skills tipo backend (laravel)
├── Extensión .tsx, .jsx, .vue → inyectar skills tipo frontend (react)
├── Extensión .css, .scss → inyectar skills tipo styling (tailwind)
├── Path contiene /test/, /spec/ → inyectar skills tipo testing
├── Path contiene /migrations/, /models/ → inyectar skills tipo data
└── Si no matchea → inyectar solo skills tipo general
```

## Coexistencia con el flujo SDD

Las skills de proyecto COEXISTEN con las skills SDD:
- Las skills SDD definen el FLUJO (qué fases seguir, qué documentos crear)
- Las skills de proyecto definen las CONVENCIONES (cómo escribir código)
- No hay conflicto porque operan en capas diferentes
- Si una skill de proyecto contradice una regla de `_shared/`, la skill de proyecto tiene prioridad (es más específica)

## Agregar nuevas skills de proyecto

Cuando se detecta que el proyecto usa una tecnología/framework sin skill:

1. Registrar como sugerencia en el sobre de retorno del subagente
2. El orquestador puede proponer al usuario: "Detecté que usás {tech} pero no hay skill para eso. ¿Querés que cree una?"
3. Si el usuario acepta → crear la skill siguiendo la spec de Agent Skills (SKILL.md con frontmatter)
4. Agregar entrada en `docs/workflow-changelog.md` como mejora aplicada
