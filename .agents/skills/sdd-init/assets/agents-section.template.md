<!-- sdd-workflow:start -->
## SDD Workflow

Este proyecto usa **Spec-Driven Development** con archivos Markdown como fuente de verdad.

### Archivos de configuración del agente

| Archivo | Propósito |
|---------|-----------|
| `.agents/orchestrator.md` | Protocolo de coordinación de fases |
| `.agents/personality.md` | Personalidad y tono del agente |
| `.agents/rules.md` | Reglas generales (commits, verificación, interacción) |

**Leer estos archivos al inicio de cada sesión.**

### Comandos disponibles

| Comando | Uso |
|---------|-----|
| `/opsx:init` | Inicializar/re-detectar contexto SDD |
| `/opsx:onboard` | Tutorial interactivo del flujo |
| `/opsx:new <nombre>` | Crear change completo (propose → tasks) |
| `/opsx:continue [nombre]` | Continuar change desde donde quedó |
| `/opsx:ff [nombre]` | Fast-forward: todas las fases sin pausa |
| `/opsx:explore <tema>` | Investigar antes de proponer |
| `/opsx:propose <nombre>` | Crear propuesta individual |
| `/opsx:apply [nombre]` | Implementar tareas |
| `/opsx:archive [nombre]` | Archivar con retro obligatoria |
| `/opsx:patch` | Cambio pequeño sin flujo completo |
| `/opsx:domain-brief` | Regenerar descripción funcional |

### Reglas del flujo

- Toda la persistencia es archivos Markdown — no hay base de datos
- Las specs, proposals, y artefactos viven en `openspec/`
- Las decisiones se registran con tipo y req afectado en `state.md`
- Al archivar un change, la retro es OBLIGATORIA
- Los bugs y lecciones se propagan a `docs/known-issues.md`
- Las mejoras al flujo se registran en `docs/workflow-changelog.md`
- Consultar `_shared/abstraction-guide.md` antes de decidir niveles de abstracción
- Los cambios a templates se aplican solo a artefactos nuevos (forward-only)
- Las skills de proyecto (no-SDD) coexisten y se inyectan automáticamente

### Documentación

| Archivo | Propósito |
|---------|-----------|
| `openspec/config.yaml` | Config del proyecto + overrides |
| `docs/domain-brief.md` | Descripción funcional (auto-generado) |
| `docs/known-issues.md` | Bugs + lecciones aprendidas |
| `docs/workflow-changelog.md` | Mejora continua del flujo |
<!-- sdd-workflow:end -->