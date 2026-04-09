# OpenSpec — Convención de Archivos

## Estructura

```
openspec/
├── config.yaml              ← Config del proyecto, namespaces, overrides de fase
├── specs/                   ← Fuente de verdad (specs vigentes, carpetas planas)
│   └── NNN-domain/
│       └── spec.md          ← Incluye campo Namespace como metadata
└── changes/
    ├── archive/             ← Changes completados (inmutables, con retro.md)
    │   └── YYYY-MM-DD-NN-slug/
    └── {prefix}-YYYY-MM-DD-NN-slug/  ← Changes activos
        ├── state.md
        ├── exploration.md   ← (opcional)
        ├── proposal.md
        ├── specs/
        │   └── NNN-domain/
        │       └── spec.md  ← Delta spec
        ├── design.md
        ├── tasks.md
        └── verify-report.md
```

## Naming Convention

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Change completo | `spec-YYYY-MM-DD-NN-slug` | `spec-2026-04-09-01-product-variants` |
| Patch | `patch-YYYY-MM-DD-NN-slug` | `patch-2026-04-09-02-fix-tax-calc` |
| Spec consolidada | `NNN-domain` | `004-products` |

`NN` es secuencial por fecha — se reinicia cada día. Para determinar el siguiente NN, contar los directorios existentes en `openspec/changes/` con la misma fecha.

## Namespaces

Los namespaces son metadata en la spec, NO carpetas:

```markdown
# Spec — Productos
**Namespace**: inventory
```

Cambiar de namespace = cambiar una línea. Definidos en `openspec/config.yaml`:

```yaml
namespaces:
  - id: inventory
    label: Inventario
```

## State.md — Formato

```markdown
# State — {change-name}

## Fase Actual
{fase-actual}

## Resumen
{descripción breve}

---

## Log de Fases (append-only — NO editar entradas anteriores)

### [YYYY-MM-DD HH:MM] {fase}
- **Estado**: {completado | completado con observaciones | bloqueado}
- **Resumen**: {1-3 frases}
- **Decisiones**: {D-NN, o "Ninguna"}
- **Artefactos**: {archivos creados/modificados}
- **Siguiente**: {fase recomendada}

---

## Decisiones (solo agregar filas)

| # | Decisión | Tipo | Req Afectado | Fase | Justificación |
|---|----------|------|-------------|------|---------------|

---

## Archivos Afectados (solo agregar filas)

| Archivo | Acción | Req | Fase |
|---------|--------|-----|------|
```

## Artefactos por Fase

| Skill | Crea | Path |
|-------|------|------|
| sdd-init | Estructura | `openspec/config.yaml`, directorios |
| sdd-explore | Opcional | `openspec/changes/{name}/exploration.md` |
| sdd-propose | Obligatorio | `openspec/changes/{name}/proposal.md` |
| sdd-spec | Obligatorio | `openspec/changes/{name}/specs/{NNN-domain}/spec.md` |
| sdd-design | Obligatorio | `openspec/changes/{name}/design.md` |
| sdd-tasks | Obligatorio | `openspec/changes/{name}/tasks.md` |
| sdd-apply | Actualiza | `tasks.md` (marca `[x]`), `state.md` (archivos afectados) |
| sdd-verify | Obligatorio | `openspec/changes/{name}/verify-report.md` |
| sdd-archive | Mueve + Crea | `→ archive/` + `retro.md`, actualiza specs principales |
| sdd-patch | Todo en uno | `openspec/changes/{name}/patch.md` |

## Reglas de Escritura

- Crear el directorio del change ANTES de escribir artefactos
- Si un archivo ya existe, LEER primero y ACTUALIZAR (no sobrescribir)
- Si el directorio del change ya tiene artefactos, el change se está CONTINUANDO
- Usar `openspec/config.yaml` sección `rules` para reglas específicas por fase
- El archive es un AUDIT TRAIL — nunca modificar changes archivados
