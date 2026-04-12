# Patch - Mejoras al mirror, gitignore y visibilidad del workflow

## Motivación

Tras operar el workflow en varias sesiones se detectaron 3 huecos relacionados con la infraestructura de multi-editor y la experiencia del usuario:

1. **`.gitignore` incompleto** — Faltan directorios de mirrors auto-generados (`.gemini/`, `.codex/`, `.qwen/`, `.agent/`, `.amazonq/`, `.visual-companion/`). Son descartables y no deberían trackearse.
2. **Falta de visibilidad del progreso** — En modo `interactive` el orquestador se detiene entre fases pero no muestra un resumen de qué fases se completaron, cuáles se saltearon y cuál viene. El usuario ve "un chat normal" sin mapa del flujo.
3. **Mirror incompleto** — `mirror-agents.sh` copia skills/commands pero no genera archivos raíz que los editores leen como entry point (`CLAUDE.md`, `GEMINI.md`, etc.). Tampoco existe versión PowerShell. Falta opción de symlink vs copia.

## Cambio

### 2a. Completar `.gitignore`
Agregar todos los directorios de editor auto-generados y `.visual-companion/`.

### 1a. Resumen de progreso en el orquestador
Agregar instrucción en `orchestrator.md` para que al detenerse entre fases muestre un bloque de progreso con fases completadas, salteadas y siguiente.

### 3a + 3b. Extender mirror y crear versión PowerShell
- Extender `mirror-agents.sh` para generar archivos raíz (`CLAUDE.md`, `GEMINI.md`, etc.) como puente a `AGENTS.md`.
- Agregar flag `--symlink` para usar symlinks en lugar de copias (excepto editores con estructura diferente como vscode).  
- Crear `mirror-agents.ps1` como port nativo para Windows.

## Archivos

| Archivo | Acción | Detalle |
|---------|--------|---------|
| `.gitignore` | Modificado | Agregar directorios de editor faltantes y `.visual-companion/` |
| `.agents/orchestrator.md` | Modificado | Agregar sección de resumen de progreso entre fases |
| `.agents/skills/sdd-init/scripts/mirror-agents.sh` | Modificado | Generar root files + opción `--symlink` |
| `.agents/skills/sdd-init/scripts/mirror-agents.ps1` | Creado | Port PowerShell del mirror |

## Spec afectada
Ninguna — son mejoras a la infraestructura del workflow.

## Decisiones

| # | Decision | Tipo | Justificacion |
|---|----------|------|---------------|
| D-01 | Root files se generan como copia del contenido de AGENTS.md, no como symlinks al archivo | Decisión de diseño | Algunos editores no resuelven symlinks correctamente y AGENTS.md puede no existir si la policy es `readonly` |
| D-02 | `--symlink` aplica solo a skills/ y commands/, no a root files | Decisión de diseño | Root files son archivos únicos pequeños; el beneficio del symlink es en los árboles grandes de skills |
| D-03 | El resumen de progreso es una lista compacta, no un diagrama | Decisión de diseño | Debe ser breve y no agregar ruido al chat; el diagrama del grafo ya existe en el orchestrator para referencia |

## Verificación
- [x] `.gitignore` incluye todos los directorios de editor del mirror script
- [x] El orquestador tiene instrucción de mostrar progreso entre fases
- [x] `mirror-agents.sh --help` muestra la opción `--symlink`
- [x] `mirror-agents.sh` genera `CLAUDE.md` cuando se pasa `claude` como editor
- [x] `mirror-agents.ps1` existe y genera los mismos resultados que el bash
- [x] Los mirrors se re-sincronizaron post-cambio
