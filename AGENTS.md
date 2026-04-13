<!-- sdd-workflow:start -->
## SDD Workflow

Este proyecto usa **Spec-Driven Development** file-based: la fuente de verdad vive en archivos Markdown dentro del repo.

### Archivos de configuración del agente

| Archivo | Propósito |
|---------|-----------|
| `.agents/orchestrator.md` | Protocolo de coordinación y delegación |
| `.agents/personality.md` | Personalidad y tono del agente |
| `.agents/rules.md` | Reglas generales del proyecto |

**Leer estos archivos al inicio de cada sesión.**

### Comandos disponibles

| Comando | Uso |
|---------|-----|
| `/sdd:init` | Inicializar o re-detectar contexto SDD |
| `/sdd:onboard` | Recorrido guiado del flujo con un ejemplo real |
| `/sdd:new <nombre>` | Crear change completo |
| `/sdd:continue [nombre]` | Continuar change desde donde quedó |
| `/sdd:ff [nombre]` | Fast-forward de fases pendientes |
| `/sdd:explore <tema>` | Investigar antes de proponer |
| `/sdd:propose <nombre>` | Crear propuesta individual |
| `/sdd:apply [nombre]` | Implementar tareas |
| `/sdd:verify [nombre]` | Verificar cumplimiento con evidencia |
| `/sdd:archive [nombre]` | Archivar con retro obligatoria |
| `/sdd:patch` | Cambio chico documentado en un único `patch.md` |
| `/sdd:domain-brief` | Regenerar `docs/domain-brief.md` desde specs consolidadas |

`/sdd:new <nombre>` normalmente recorre `propose -> spec -> design (si aplica) -> tasks`.

### Reglas del flujo

- Toda la persistencia vive en archivos Markdown.
- Las specs, proposals y artefactos viven en `openspec/`.
- Las decisiones se registran con tipo y req afectado en `state.md`.
- Al archivar un change, la retro es OBLIGATORIA.
- Los bugs y lecciones se propagan a `docs/known-issues.md`.
- Las mejoras al flujo se registran en `docs/workflow-changelog.md`.
- Consultar `.agents/skills/_shared/abstraction-guide.md` antes de decidir niveles de abstracción.
- Los cambios a templates se aplican solo a artefactos nuevos (forward-only).
- `testing.strict_tdd`, `modules.skill_registry` y `modules.model_routing` son módulos opcionales configurados en `openspec/config.yaml`.
- Si `modules.skill_registry` está activo, el orquestador puede inyectar skills de proyecto en fases técnicas.
- Las skills de proyecto (no-SDD) pueden coexistir con el flujo SDD sin reemplazarlo.

### Documentación

| Archivo | Propósito |
|---------|-----------|
| `openspec/config.yaml` | Config del proyecto + módulos opcionales |
| `docs/domain-brief.md` | Resumen funcional regenerable con `/sdd:domain-brief` |
| `docs/known-issues.md` | Bugs + lecciones aprendidas |
| `docs/workflow-changelog.md` | Mejora continua del flujo |
<!-- sdd-workflow:end -->