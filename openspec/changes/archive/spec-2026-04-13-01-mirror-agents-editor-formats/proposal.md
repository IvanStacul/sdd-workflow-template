# Propuesta - Formato nativo por editor en mirror-agents

## Por qué

El script `mirror-agents` copia los comandos de `.agents/commands/` directamente a cada directorio de editor sin transformar el formato. Esto funciona para editores que leen `.md` estándar (Cursor, Claude, OpenCode, Antigravity), pero produce archivos en formato incorrecto para Gemini y Qwen (que esperan `.toml`) y para GitHub Copilot (que espera `.prompt.md` dentro de `prompts/`). El resultado es que los comandos SDD no son reconocidos por esos editores después de correr el mirror.

## Qué Cambia

- El script detecta el editor destino y aplica la transformación de formato correcta al copiar commands
- Para Gemini y Qwen: genera archivos `.toml` con `description = "..."` y `prompt = """..."""`
- Para GitHub/VSCode: genera archivos `.prompt.md` en `prompts/` con solo `description:` en frontmatter; no genera `copilot-instructions.md`; borra `skills/` sin regenerar
- Para Cursor: enriquece el frontmatter con `name: /sdd-{cmd}`, `id: sdd-{cmd}`, `category: Workflow`
- Para Claude: agrega `category: Workflow` y `tags: [workflow, sdd]` al frontmatter
- El limpiado previo (pre-paso) borra el target antes de regenerar, incluyendo `prompts/` y `skills/` para el caso `.github/`

## Capabilities

### Nuevas
- `mirror-agents.format-transform`: el script puede transformar el formato de un comando fuente `.md` al formato nativo de cada editor en el momento de copiar

### Modificadas
- `mirror-agents.commands-copy`: la lógica de copia de commands pasa de `cp -r` naïve a una función por editor que extrae body + frontmatter y reensambla en el formato correcto

## Alcance

### Dentro
- Soporte de transformación para: Gemini, Qwen, GitHub/VSCode, Cursor, Claude
- Limpieza de `prompts/` y `skills/` en `.github/` antes de regenerar
- Versión PowerShell (`mirror-agents.ps1`) y Bash (`mirror-agents.sh`) del script
- La fuente de verdad (`.agents/commands/sdd/*.md`) mantiene frontmatter mínimo; el enriquecimiento por editor es responsabilidad del script

### Fuera
- Soporte para Qwen con formato diferente a TOML (se trata igual que Gemini, mismo formato)
- Generación de `copilot-instructions.md` para GitHub — no se crea
- Modificación de la estructura de `.agents/commands/sdd/` (los archivos fuente no cambian)
- Soporte para templates dinámicos de `skills/` — skills se siguen copiando como carpetas directamente

## Impacto

- **Código**: `.agents/skills/sdd-init/scripts/mirror-agents.ps1` y `mirror-agents.sh`
- **APIs**: ninguna
- **Dependencias**: sin cambios — el script usa solo herramientas del shell (sed/awk para bash, regex para PowerShell)
- **Datos**: sin cambios en specs ni base de datos

## Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| El script falla al parsear frontmatter con valores multi-línea | Baja | Medio | Los comandos SDD son documentos cortos; el frontmatter tiene name y description simples |
| Diferencia de comportamiento entre .sh y .ps1 en extracción de body | Media | Medio | Testear ambos scripts contra los mismos archivos fuente antes de usar |
| El formato TOML generado no es reconocido por Gemini/Qwen si hay caracteres especiales en el body | Baja | Alto | Escapar comillas triples en el cuerpo si existen; los comandos SDD actuales no las contienen |
| Borramos `.github/skills/` con contenido que el usuario quería conservar | Baja | Medio | `rm -rf` antes es el comportamiento actual para todos los editores; documentar en README |

## Plan de Rollback

Los archivos actuales en `.github/`, `.gemini/`, `.qwen/` y demás son copias (no symlinks) y pueden restaurarse corriendo la versión anterior del script manualmente. Alternativamente, `git checkout` sobre esos directorios restaura el estado previo si el usuario hizo commit antes de correr el mirror.
