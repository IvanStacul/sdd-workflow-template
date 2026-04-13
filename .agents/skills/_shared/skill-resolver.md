# Skill Resolver - Detección e Inyección de Skills de Proyecto

Este protocolo solo aplica cuando `modules.skill_registry: true`.

## Purpose

Resolver reglas compactas de skills de proyecto y ponerlas a disposición de las fases que realmente las necesitan, sin depender de memoria externa ni de que el usuario las copie a mano en cada pedido.

La idea es separar capas:

- Las skills SDD definen el flujo.
- Las skills de proyecto definen convenciones de stack, framework o equipo.
- El resolver compacta esas convenciones para que fases como `sdd-design`, `sdd-tasks`, `sdd-apply` o `sdd-verify` las puedan seguir sin releer todo el catálogo.

Si el módulo está apagado, el workflow sigue funcionando solo con las reglas base de SDD.

## Qué cuenta como "skill de proyecto"

Una skill de proyecto es cualquier skill local que:

- No empieza con `sdd-`.
- No vive en `_shared/`.
- No es `domain-brief`.
- Describe una tecnología, framework, estilo de código o convención del proyecto.

Ejemplos: `laravel`, `react`, `tailwind`, `postgres`, `testing`.

## Fuentes de resolución

Usar este orden:

1. `.agents/skill-registry.md` si existe (registro consolidado del proyecto).
2. `.atl/skill-registry.md` como fallback legacy.
3. Skills locales en `.agents/skills/`.
4. Si hace falta compatibilidad entre editores, también escanear `.claude/skills/`, `.cursor/skills/`, `.opencode/skills/` y `.gemini/skills/`.

Preferir un registro consolidado cuando exista. Solo hacer deep scan cuando el registro no está o está incompleto.

## Detección y clasificación

Para cada skill encontrada:

1. Leer `SKILL.md`.
2. Extraer `name` y `description`.
3. Clasificarla por tipo.
4. Compactar sus reglas principales en un bloque breve.

Tabla sugerida de clasificación:

| Palabras clave en `description` | Tipo |
|---------------------------------|------|
| back, backend, api, server, laravel, express, django, rails | `backend` |
| front, frontend, ui, component, react, vue, angular, svelte | `frontend` |
| infra, deploy, ci, docker, kubernetes, terraform, cloud | `infra` |
| test, testing, e2e, unit, integration | `testing` |
| style, css, tailwind, sass, design-system | `styling` |
| db, database, migration, orm, eloquent, prisma | `data` |
| otros | `general` |

Regla de compactacion:

- Extraer solo las reglas que cambian decisiones reales.
- Maximo 10 lineas por skill.
- Inyectar texto compacto, no paths a otros `SKILL.md`.

## Cuando inyectar

Inyectar solo a fases que tocan código o definen estructura:

- `sdd-design`
- `sdd-tasks`
- `sdd-apply`
- `sdd-verify`

Normalmente no hace falta inyectar a:

- `sdd-explore`
- `sdd-propose`
- `sdd-archive`
- `sdd-patch`
- `domain-brief`

`sdd-init` puede usar este módulo para detectar que skills de proyecto existen, pero no necesita inyectar reglas compactadas a otra fase porque todavía está armando el contexto.

## Matching por contexto

No inyectar todas las skills juntas. Elegir las relevantes para la tarea o los archivos involucrados.

Ejemplos:

- Backend o API -> `backend` y `data`
- Frontend o componentes -> `frontend` y `styling`
- Tests -> `testing`
- Infraestructura -> `infra`
- Si no matchea nada especifico -> `general`

## Formato de inyección

El coordinador puede agregar este bloque antes de la skill de fase:

```markdown
## Project Standards (auto-resolved)

### {skill-name} ({tipo})
{reglas compactas}
```

## Resultado esperado

El coordinador o la fase deben reflejar uno de estos estados:

- `disabled`: el módulo está apagado.
- `direct`: el módulo estaba disponible, pero no hizo falta inyectar nada adicional.
- `injected`: se inyectaron reglas compactadas.
- `fallback`: hubo que releer skills o inferir reglas porque faltó resolución previa.

## Rules

- No dependas de memoria externa ni de backends propietarios.
- Si existe un registro consolidado, usarlo antes de escanear todo el repo.
- Si una skill de proyecto contradice una regla genérica de `_shared/`, la skill de proyecto tiene prioridad porque es más específica.
- Si el stack detectado sugiere que falta una skill importante, reportarlo como oportunidad de mejora en `init`, `onboard` o en el resumen de la fase.
