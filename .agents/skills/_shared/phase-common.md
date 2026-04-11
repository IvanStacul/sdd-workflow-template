# SDD Phase - Protocolo Común

Protocolo compartido para todas las fases SDD. Cada skill de fase debe seguir este archivo junto con su `SKILL.md` específico.

## A. Límites del Ejecutor

Cada agente de fase SDD es un EJECUTOR, no un coordinador. Esto significa que:

- Hace el trabajo de la fase directamente.
- No rediseña el flujo completo mientras ejecuta la fase.
- No lanza subagentes salvo que la fase lo habilite explícitamente.
- No devuelve el trabajo sin antes intentar resolverlo con la evidencia disponible.

## B. Carga de Contexto (OBLIGATORIO antes de ejecutar)

Antes de cualquier acción, leer en este orden:

1. `openspec/config.yaml` para entender contexto del proyecto, namespaces, modulos y reglas por fase.
2. `.agents/rules.md` para reglas generales del proyecto.
3. Si hay change activo, `openspec/changes/{change-name}/state.md`.
4. Los artefactos previos requeridos por la fase actual según su `SKILL.md` y el flujo definido en `.agents/orchestrator.md`.
5. `docs/known-issues.md` si existen bug conocidos y lecciones relevantes para la fase.
6. `docs/workflow-changelog.md` solo si la fase necesita mejorar el workflow o archivar un change.

Si un archivo opcional no existe, continuar y reportarlo como observacion, no como error fatal.

### Project Standards auto-resolved

Si el orquestador inyecto un bloque `## Project Standards (auto-resolved)`, seguir esas reglas tal como llegaron. Ese bloque ya representa skills de proyecto resueltas y compactadas; no releer los `SKILL.md` originales salvo que la fase entre en modo `fallback`.

Si no llega ese bloque y `modules.skill_registry: true`, el coordinador puede usar `_shared/skill-resolver.md` para resolver estandares de proyecto.

### Compatibilidad legacy

- Si `testing.strict_tdd` no existe, usar `tdd`.
- Si `testing.test_command` no existe, usar `test_command`.
- Las fases nuevas pueden leer claves legacy, pero no deben volver a escribirlas.

## C. Guardado de Contexto (OBLIGATORIO después de ejecutar)

Después de completar la fase, actualizar `state.md` del change.

### C.1 Actualizar puntero de fase actual

Cambiar la sección `Fase Actual` para reflejar el estado corriente.

### C.2 Agregar entrada al log (append-only)

Agregar al final del `Log de Fases`. NUNCA editar entradas anteriores.

```markdown
### [YYYY-MM-DD HH:MM] {nombre-de-fase}
- **Estado**: {completado | completado con observaciones | bloqueado}
- **Resumen**: {1-3 frases de lo hecho}
- **Decisiones**: {D-NN, D-NN o "Ninguna"}
- **Artefactos**: {archivos creados/modificados}
- **Siguiente**: {fase recomendada}
```

### C.3 Registrar decisiones (si las hay)

Agregar filas a la tabla `Decisiones` de `state.md`.

| Campo | Descripción |
|-------|-------------|
| `#` | ID secuencial (`D-01`, `D-02`, ...) |
| `Decisión` | Qué se decidió |
| `Tipo` | `Req funcional` · `Regla de negocio` · `Decisión de diseño` · `Anti-patrón evitado` · `Restricción técnica` · `Scope (diferido)` |
| `Req Afectado` | `FR-XX-NN` o `-` si no aplica |
| `Fase` | Fase donde se tomó |
| `Justificación` | Por qué se decidió así |

Si una decisión modifica un requisito, la spec correspondiente debe quedar actualizada o explícitamente marcada para actualizarse en la siguiente fase.

### C.4 Registrar archivos afectados (solo cuando la fase modifica código)

Agregar filas a la tabla `Archivos Afectados` de `state.md`:

| Archivo | Acción | Req | Fase |
|---------|--------|-----|------|
| `path/to/file` | Creado/Modificado/Eliminado | `FR-XX-NN` | `{fase}` |

## D. State Append-Only

`state.md` es un log de auditoría. Las reglas son:

- La sección `Fase Actual` si se actualiza porque es un puntero.
- El `Log de Fases` solo agrega entradas.
- Las tablas `Decisiones` y `Archivos Afectados` solo agregan filas.
- Nunca borrar ni reescribir historia salvo corrección evidente de formato.

## E. Persistencia de Artefactos

Cada fase que genera un artefacto debe escribirlo dentro de `openspec/changes/{change-name}/`, salvo las excepciones explícitas del flujo como `sdd-init`, `domain-brief` o la sincronización final de `sdd-archive`.

Reglas:

- Crear el artefacto esperado en el path correcto; si se omite, el flujo queda incompleto.
- Si el archivo ya existe, leerlo primero y actualizarlo.
- Si el directorio del change ya contiene artefactos, tratarlo como una continuación.
- Los changes archivados son inmutables.

## F. Sobre de Retorno

Cada fase DEBE devolver un resumen estructurado al orquestador o al usuario:

```yaml
status: success | partial | blocked
summary: ""
artifacts:
  - path/to/file
next: ""
risks:
  - ""
skill_resolution: disabled | direct | injected | fallback
```

Guía de uso:

- `success`: la fase terminó sin bloqueos.
- `partial`: hubo avance, pero queda una observación importante.
- `blocked`: no se puede continuar.

### Skill Resolution

- `disabled`: `modules.skill_registry` está apagado.
- `direct`: el módulo está disponible, pero no hizo falta inyectar reglas extra; la fase siguió con reglas base.
- `injected`: se aplicaron estándares de proyecto compactados.
- `fallback`: hubo que inferir reglas o releer skills manualmente porque faltaba resolución previa.

`direct` reemplaza el viejo `none` de versiones anteriores.
