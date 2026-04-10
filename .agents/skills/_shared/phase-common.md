# SDD Phase — Protocolo Común

Protocolo estándar para todas las fases SDD. Cada skill de fase DEBE seguir estas reglas junto con su SKILL.md específico.

## A. Límites del Ejecutor

Cada agente de fase SDD es un EJECUTOR, no un coordinador. Realiza el trabajo de la fase directamente. NO lances subagentes ni devuelvas el trabajo, a menos que el SKILL.md de la fase indique explícitamente detenerse.

## B. Carga de Contexto (OBLIGATORIO antes de ejecutar)

Antes de cualquier acción, lee en este orden:

1. `openspec/config.yaml` → contexto del proyecto, reglas de la fase, namespaces, política de `agents_md_policy`
2. `.agents/rules.md` → reglas generales del proyecto
3. Si hay change activo → `state.md` del change (log de fases, decisiones previas, archivos afectados)
4. Artefactos previos del change según la tabla de dependencias de la fase (ver orchestrator.md)
5. `docs/known-issues.md` → bugs conocidos y lecciones relevantes (si existe)

Si se recibió un bloque `## Project Standards (auto-resolved)` del orquestador, seguir esas reglas — son skills de proyecto ya procesadas. NO leer archivos SKILL.md de otras skills.

Si un archivo no existe, continúa sin él — no es un error, es un proyecto que aún no llegó a esa fase.

## C. Guardado de Contexto (OBLIGATORIO después de ejecutar)

Después de completar la fase, actualizar `state.md` del change:

### C.1 Actualizar puntero de fase actual

Cambiar la sección "Fase Actual" al inicio del archivo para reflejar el estado corriente.

### C.2 Agregar entrada al log (append-only)

Agregar al final del "Log de Fases" — NUNCA editar entradas anteriores:

```markdown
### [YYYY-MM-DD HH:MM] {nombre-de-fase}
- **Estado**: {completado | completado con observaciones | bloqueado}
- **Resumen**: {1-3 frases de lo hecho}
- **Decisiones**: {D-NN, D-NN o "Ninguna"}
- **Artefactos**: {archivos creados/modificados}
- **Siguiente**: {fase recomendada}
```

### C.3 Registrar decisiones (si las hay)

Agregar filas a la tabla "Decisiones" de `state.md`. Cada decisión con:

| Campo | Descripción |
|-------|-------------|
| `#` | ID secuencial (D-01, D-02, ...) |
| `Decisión` | Qué se decidió |
| `Tipo` | `Req funcional` · `Regla de negocio` · `Decisión de diseño` · `Anti-patrón evitado` · `Restricción técnica` · `Scope (diferido)` |
| `Req Afectado` | FR-XX-NN o "—" si no aplica |
| `Fase` | Fase donde se tomó |
| `Justificación` | Por qué se decidió así |

**Si la decisión modifica un requisito**: actualizar la spec correspondiente Y preguntar al usuario si la clasificación del tipo es correcta.

### C.4 Registrar archivos afectados (solo en fases que modifican código)

Agregar filas a la tabla "Archivos Afectados" de `state.md`:

| Archivo | Acción | Req | Fase |
|---------|--------|-----|------|
| `path/to/file` | Creado/Modificado/Eliminado | FR-XX-NN | {fase} |

## D. State Append-Only

El `state.md` es un log. Las reglas:

- La sección "Fase Actual" SÍ se actualiza (es un puntero)
- El "Log de Fases" solo se AGREGA — nunca se editan entradas anteriores
- Las tablas de "Decisiones" y "Archivos Afectados" solo se agregan filas — nunca se borran ni editan
- Esto da auditabilidad sin depender de `git log`

## E. Persistencia de Artefactos

Cada fase que genere un artefacto DEBE escribirlo en el path dentro de `openspec/changes/{change-name}/`. Si se omite, se INTERRUMPE el flujo: las fases posteriores no encontrarán la salida.

## F. Sobre de Retorno

Cada fase DEBE devolver un resumen estructurado al orquestador (o al usuario si es modo secuencial):

```markdown
**Estado**: {success | partial | blocked}
**Resumen**: {1-3 frases}
**Artefactos**: {lista de archivos escritos}
**Siguiente**: {fase recomendada o "ninguna"}
**Riesgos**: {riesgos detectados o "Ninguno"}
**Skill Resolution**: {injected | none | fallback}
```

Valores de `Skill Resolution`:
- `injected` — se recibieron Project Standards del orquestador y se siguieron
- `none` — no se recibieron ni se encontraron skills de proyecto (normal)
- `fallback` — se intentó cargar skills manualmente porque no se recibieron del orquestador

Si el orquestador recibe `fallback`, debe re-escanear skills de proyecto y reinjectarlas en futuras delegaciones.
