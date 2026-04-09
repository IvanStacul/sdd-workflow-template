<!-- sdd-workflow:start -->
## SDD Workflow

Este proyecto usa **Spec-Driven Development (SDD)** con archivos Markdown como fuente de verdad.

### Comandos disponibles

| Comando | Uso |
|---------|-----|
| `/opsx:init` | Inicializar/re-detectar contexto SDD |
| `/opsx:explore` | Investigar una idea antes de proponer |
| `/opsx:propose` | Crear un change con todos los artefactos |
| `/opsx:apply` | Implementar tareas de un change |
| `/opsx:archive` | Archivar + retro + mejora continua |
| `/opsx:patch` | Registrar cambio pequeño sin flujo completo |
| `/opsx:domain-brief` | Regenerar descripción funcional |

### Reglas del flujo

- Toda la persistencia es archivos Markdown — no hay base de datos
- Las specs, proposals, y artefactos viven en `openspec/`
- Las decisiones se registran con tipo y req afectado en `state.md`
- Al archivar un change, la retro es obligatoria
- Los bugs y lecciones se propagan a `docs/known-issues.md`
- Las mejoras al flujo se registran en `docs/workflow-changelog.md`
- Consultar `_shared/abstraction-guide.md` antes de decidir niveles de abstracción
- Los cambios a templates se aplican solo a artefactos nuevos (forward-only)

### Documentación

| Archivo | Propósito |
|---------|-----------|
| `openspec/config.yaml` | Config del proyecto + overrides |
| `docs/domain-brief.md` | Descripción funcional (auto-generado) |
| `docs/known-issues.md` | Bugs + lecciones aprendidas |
| `docs/workflow-changelog.md` | Mejora continua del flujo |
<!-- sdd-workflow:end -->
