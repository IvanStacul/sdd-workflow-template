# Changelog del Workflow SDD

> Registro de mejoras al sistema de especificaciones y workflow.
> Estado de cada entrada: `propuesta` | `aplicada` | `descartada`.

---

## v1.0 - Inicial ({FECHA})

**Estado**: aplicada

- Estructura base del flujo SDD.
- Skills: init, explore, propose, spec, design, tasks, apply, verify, archive, patch, domain-brief.
- Convenciones compartidas: phase-common, openspec-convention, abstraction-guide.
- Retro obligatoria en archive con propagacion a known-issues.
- `state.md` con log append-only.
- Namespaces como metadata, no carpetas.
- Templates forward-only: las mejoras no reescriben artefactos existentes.

---

<!-- Formato para entradas futuras:

## {Descripcion} ({YYYY-MM-DD})

**Estado**: {propuesta | aplicada | descartada}
**Origen**: retro de {change-name}
**Skill/archivo afectado**: {path}

{Descripcion y justificacion}

-->
