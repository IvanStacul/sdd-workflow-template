﻿# OpenSpec - Convencion de Archivos

## 1. Estructura

```text
openspec/
|-- config.yaml                       <- config del proyecto y del workflow
|-- specs/                            <- fuente de verdad consolidada
|   `-- NNN-capability/
|       `-- spec.md
`-- changes/
    |-- archive/                      <- changes cerrados; no se vuelven a editar
    `-- {prefix}-YYYY-MM-DD-NN-slug/  <- change activo
        |-- state.md
        |-- exploration.md            <- opcional
        |-- proposal.md
        |-- impact-map.md             <- opcional; analisis de impacto cruzado cuando el change lo requiera
        |-- specs/
        |   `-- NNN-capability/
        |       `-- spec.md           <- delta spec del change
        |-- design.md                 <- opcional
        |-- tasks.md
        |-- verify-report.md
        |-- retro.md                  <- se crea antes de archivar
```

Ideas clave:

- `openspec/specs/` es la fuente de verdad del comportamiento vigente.
- `openspec/changes/{change-name}/` contiene el trabajo en curso.
- `openspec/changes/archive/` es el audit trail historico.

## 2. Naming Convention

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| Change completo | `spec-YYYY-MM-DD-NN-slug` | `spec-2026-04-10-01-product-variants` |
| Patch | `patch-YYYY-MM-DD-NN-slug` | `patch-2026-04-10-02-fix-tax-calc` |
| Spec consolidada | `NNN-capability` | `004-products` |

`NN` es secuencial por fecha y se reinicia cada dia. Para obtener el siguiente valor, contar los directorios activos y archivados con la misma fecha.

### 2.1 Capability vs Domain

En este workflow, `capability` y `domain` NO significan lo mismo:

- `capability` = unidad de comportamiento que tiene su propia spec y puede crearse, modificarse o archivarse de forma trazable.
- `domain` = area funcional más amplia usada para explicar el sistema a nivel negocio o para agrupar capacidades relacionadas.

Por eso los paths de specs usan `NNN-capability`:

- `openspec/specs/004-products/spec.md` representa UNA spec consolidada concreta.
- esa spec puede pertenecer a un dominio más amplio, por ejemplo `inventory`.

Regla práctica:

- si estas nombrando carpetas o archivos de specs, pensa en `capability`
- si estas explicando el sistema para humanos, agrupando areas funcionales o escribiendo `domain-brief`, pensa en `domain`

El nombre del folder puede sonar "de dominio" (`004-products`, `007-orders`), pero en el flujo sigue contando como una `capability`: una unidad de spec versionable dentro de `openspec/specs/`.

## 3. Namespaces

Los namespaces son metadata en la spec, NO carpetas:

```markdown
# Spec - Productos
**Namespace**: inventory
```

Se definen en `openspec/config.yaml`:

```yaml
namespaces:
  - id: inventory
    label: Inventario
    description: Productos, variantes y stock
```

Si el proyecto no los necesita, `namespaces: []` es válido.

## 4. Config Keys

`openspec/config.yaml` puede contener:

| Clave | Que controla | Opciones / notas |
|------|---------------|------------------|
| `agents_md_policy` | Como se gestiona `AGENTS.md` | `managed` / `section` / `readonly`; default recomendado `section` |
| `agent_mode` | Si el flujo se ejecuta en una conversacion o delega fases | `sequential` / `multi`; `multi` solo si el editor soporta subagentes |
| `interaction_mode` | Cuanto pausa el flujo para pedir confirmacion | `interactive` / `auto`; default recomendado `interactive` |
| `model_assignments` | Alias de modelo por fase | Relevante sobre todo en `multi` |
| `namespaces` | Catalogo de dominios o areas funcionales | Metadata, no carpetas |
| `testing.strict_tdd` | Si `apply` y `verify` siguen reglas TDD estrictas | Solo tiene sentido si hay test runner |
| `testing.test_command` | Comando principal de tests | Detectado o completado en `init` |
| `testing.coverage_command` | Comando de cobertura | Opcional |
| `testing.typecheck_command` | Comando de typecheck | Opcional |
| `modules.skill_registry` | Si se resuelven skills de proyecto de forma automática | Default recomendado `true` |
| `modules.model_routing` | Si se usan modelos distintos por fase | Solo tiene efecto real con `agent_mode: multi` |
| `rules.<fase>` | Reglas locales por fase | Complementan `_shared`, no lo reemplazan |

Compatibilidad legacy:

- Si todavía existen `tdd` o `test_command`, leerlos como fallback.
- El workflow nuevo debe escribir `testing.*`, no las claves legacy.

## 5. State.md - Formato

```markdown
# State - {change-name}

## Fase Actual
{fase-actual}

## Resumen
{descripción breve}

---

## Log de Fases (append-only - NO editar entradas anteriores)

### [YYYY-MM-DD HH:MM] {fase}
- **Estado**: {completado | completado con observaciones | bloqueado}
- **Resumen**: {1-3 frases}
- **Decisiones**: {D-NN, o "Ninguna"}
- **Artefactos**: {archivos creados/modificados}
- **Siguiente**: {fase recomendada}

---

## Decisiones (solo agregar filas)

| # | Decisión | Tipo | Req Afectado | Fase | Justificación |
|---|----------|------|--------------|------|---------------|

---

## Archivos Afectados

| Archivo | Acción | Req | Fase |
|---------|--------|-----|------|
```

## 6. Artefactos por Fase

| Skill | Crea o actualiza | Path principal |
|-------|------------------|----------------|
| `sdd-init` | Estructura y config | `openspec/config.yaml`, directorios, docs base |
| `sdd-explore` | Exploración opcional | `openspec/changes/{name}/exploration.md` |
| `sdd-propose` | Propuesta | `openspec/changes/{name}/proposal.md` |
| `sdd-propose` | Analisis cruzado opcional/obligatorio | `openspec/changes/{name}/impact-map.md` |
| `sdd-spec` | Delta specs del change | `openspec/changes/{name}/specs/{NNN-capability}/spec.md` |
| `sdd-design` | Diseño técnico | `openspec/changes/{name}/design.md` |
| `sdd-tasks` | Plan de tareas | `openspec/changes/{name}/tasks.md` |
| `sdd-apply` | Estado del plan y código | `tasks.md`, `state.md`, código del proyecto |
| `sdd-verify` | Evidencia de verificación | `openspec/changes/{name}/verify-report.md` |
| `sdd-archive` | Retro, sync a specs y archive | `retro.md`, `openspec/specs/...`, `openspec/changes/archive/...` |
| `sdd-patch` | Documento único del patch | `openspec/changes/archive/{name}/patch.md` |
| `domain-brief` | Resumen funcional | `docs/domain-brief.md` |

## 7. Reglas de Escritura

- Crear el directorio del change ANTES de escribir artefactos.
- Si un archivo ya existe, LEERLO primero y ACTUALIZARLO (NO sobrescribir).
- Si el directorio del change ya tiene artefactos, el change se está CONTINUANDO.
- `impact-map.md` aparece solo cuando el change requiere análisis de impacto cruzado; si existe, las fases posteriores deben leerlo y refinarlo en lugar de crear artefactos paralelos.
- Usar `openspec/config.yaml` sección `rules` para reglas locales por fase cuando existan.
- Archivar solo después de sincronizar delta specs y de escribir `retro.md`.
- El archive es inmutable.
- Los cambios a templates son forward-only: mejoran artefactos nuevos, no reescriben los ya existentes.

## 8. Convención de `impact-map.md`

Cuando exista `impact-map.md`, usar una estructura file-based simple con estas secciones mínimas:

- clasificación del análisis y dominio principal
- dominios secundarios
- referencias tipadas
- contratos o interfaces afectadas
- downstream flows
- edge cases cross-domain
- exclusiones explícitas
- evidencia esperada para verify

Cada referencia del mapa debe registrar como mínimo:

| Campo | Uso |
|-------|-----|
| `target` | path local o identificador textual (`repo:path`, `repo@ref:path`, `path`) |
| `target_type` | `domain` · `capability` · `spec` · `artifact` · `contract` · `flow` · `external-reference` |
| `relation` | `depends-on` · `updates` · `consumes` · `emits` · `constrains` · `verified-by` · `excluded-after-review` |
| `status` | `primary` · `secondary` · `in-scope` · `out-of-scope` · `watch-only` |
| `reason` | contexto breve y verificable |
| `tags` | labels planas para filtrar o agrupar |

Reglas operativas:

- Deduplicar referencias por combinación de `target` + `relation`.
- Si cambia el alcance de un target ya registrado, actualizar `status`, `reason` y `tags` en la misma entrada en lugar de duplicarla.
- Registrar seguimientos relacionados con nuevas filas o bullets breves que apunten al `target` correspondiente; no anidar recursivamente el contenido completo de otro artefacto.
- Los tags deben ser planos y acotados; usar listas simples como `cross-phase`, `shared-contract`, `verify-critical`, evitando sub-taxonomías infinitas.
- Las exclusiones deben conservar motivo y fecha de revisión para que `verify` pueda distinguir descarte consciente de omisión.
