# SDD Workflow Template

Template file-based de Spec-Driven Development para proyectos que trabajan con agentes de IA.

Este repo no es un proyecto ya inicializado con SDD. Es el template que aporta el workflow en `.agents/` y la documentacion base para copiarlo a otro repo.

## Que trae este template

- `.agents/`: orquestador, reglas, personalidad, comandos publicos `/sdd:*` y skills del workflow.
- `docs/workflow-guide.md`: guia corta del flujo real, con comandos publicos, fases internas y artefactos.
- `docs/workflow-sources.md`: que se adopta y que se descarta de OpenSpec, gentle-ai y agent-skills.

## Flujo real

El flujo largo sigue esta secuencia:

```text
explore (opcional) -> propose -> spec -> design (opcional) -> tasks -> apply -> verify -> archive
```

`/sdd:new <nombre>` es la puerta de entrada normal al flujo completo.

Cuando el change es cross-domain, modifica contratos compartidos o tiene riesgo transversal, `sdd-propose` puede crear `openspec/changes/{change-name}/impact-map.md` como fuente de verdad del análisis cruzado. Ese archivo se sigue refinando durante `spec`, `design`, `tasks`, `verify` y `archive`.

`propose`, `spec`, `design` y `tasks` siguen existiendo como fases internas, pero en este template no se presentan como comandos publicos separados.

Para cambios chicos existe `/sdd:patch`, que documenta, implementa y archiva usando un unico `patch.md`.

## Comandos publicos

Los comandos publicos viven en `.agents/commands/sdd/`:

- `/sdd:init`
- `/sdd:onboard`
- `/sdd:new <nombre>`
- `/sdd:continue [nombre]`
- `/sdd:ff [nombre]`
- `/sdd:explore <tema>`
- `/sdd:propose <nombre>`
- `/sdd:apply [nombre]`
- `/sdd:verify [nombre]`
- `/sdd:archive [nombre]`
- `/sdd:patch`
- `/sdd:domain-brief`

## Quick Start

1. Copiar `.agents/` a la raiz del proyecto donde vas a usar SDD.
2. Ejecutar `/sdd:init` para detectar stack, escribir `openspec/config.yaml` y crear la estructura base.
3. Usar `/sdd:onboard` si queres un recorrido guiado, o `/sdd:new <nombre>` para abrir un change real.

Opcional: si trabajas en varios editores, `sdd-init` incluye `mirror-agents.sh` para generar mirrors.

```bash
bash .agents/skills/sdd-init/scripts/mirror-agents.sh cursor claude
```

## Que aparece despues de init

Cuando inicializas SDD dentro de un proyecto, el workflow crea o completa esta base:

- `openspec/config.yaml`
- `openspec/specs/`
- `openspec/changes/archive/`
- `docs/known-issues.md`
- `docs/workflow-changelog.md`

`docs/domain-brief.md` no viene en este template ni se crea vacio en `init`: se genera mas adelante con `/sdd:domain-brief` cuando ya existen specs consolidadas.

Durante el uso normal del workflow pueden aparecer artefactos adicionales por change, por ejemplo `impact-map.md` cuando el análisis cruzado queda `obligatorio` o `recomendado`.

## Leer primero

Si queres operar el workflow: `docs/workflow-guide.md`.

Si queres entender las decisiones de diseno del template: `docs/workflow-sources.md`.
