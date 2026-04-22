# Known Issues y Lecciones Aprendidas

> Actualizado durante el archive de cada change.
> No borrar entradas; es un registro acumulativo.

---

## Bugs

### Activos

_Ninguno registrado._

### Resueltos

### BUG-001: El propio change omitió materializar `impact-map.md`
- **Estado**: Resuelto
- **Detectado en**: spec-2026-04-22-03-workflow-cross-domain-traceability
- **Fase**: verify
- **Descripción**: El change había implementado wiring completo de `impact-map.md` en skills y docs, pero no creó su propio archivo `impact-map.md` antes del primer `verify`.
- **Causa raiz**: `apply` cerró lotes por cambios en workflow sin validar que nuevo artefacto obligatorio también existiera en change activo.
- **Solución**: Se creó `impact-map.md`, se persistió clasificación `obligatorio` en `proposal.md` y se ejecutó un rerun de `verify` exitoso.
- **Prevención**: Cuando un change introduce un artefacto obligatorio del workflow, debe adoptarlo en el mismo change y validarlo en disco antes de cerrar `apply`.
- **Prevención aplicada**: no - verificación actual lo detectó, pero no se agregó una regla nueva adicional durante archive.

<!-- Formato para nuevas entradas:
### BUG-NNN: {título}
- **Estado**: Activo | Resuelto
- **Detectado en**: {change-name}
- **Fase**: {fase donde ocurrió}
- **Descripción**: {que paso}
- **Causa raiz**: {por que paso}
- **Solución**: {que se hizo}
- **Prevención**: {que cambio al flujo evita que vuelva a pasar}
- **Prevención aplicada**: {si/no - que skill se modificó}
-->

---

## Lecciones

### Arquitectura

| ID | Lección | Origen | Acción tomada |
|----|---------|--------|---------------|

### Flujo de trabajo

| ID | Lección | Origen | Acción tomada |
|----|---------|--------|---------------|
| L-W-01 | Las skills invocadas directamente por comando público no cargan automáticamente los archivos de configuración del agente (personality, rules, caveman) — la carga debe ser explícita en phase-common o en el Context Load de cada skill | patch-2026-04-16-01-ensure-personality-load | Agregado personality.md a phase-common, rules+personality a las 4 utility skills sin phase-common, y carga condicional de caveman/SKILL.md cuando config define communication.compression |
| L-W-02 | Las retros pierden valor si el workflow solo recomienda dividir scope o verificar evidencia. Los guardrails de continuidad entre sesiones deben quedar operativos en las skills, con cortes materializados en proposal/specs y evidencia antes de `state.md`. | patch-2026-04-22-01-workflow-retro-guardrails | Reforzadas `sdd-propose`, `sdd-spec`, `sdd-tasks`, `sdd-apply` y `sdd-archive`, y luego centralizadas en `_shared/phase-common.md` para que nuevas skills hereden la checklist operativa |
| L-W-03 | El análisis de impacto cruzado pierde valor cuando se reparte entre propuesta, specs y tareas sin una fuente de verdad única. Un `impact-map.md` con referencias tipadas y verificación de cobertura evita drift y omisiones silenciosas. | spec-2026-04-22-03-workflow-cross-domain-traceability | Se incorporó `impact-map.md` al workflow con triggers de uso, templates, guardrails de deduplicación y checks de verify/archive para reconciliar proposal/spec/design/tasks |

### Negocio

| ID | Lección | Origen | Acción tomada |
|----|---------|--------|---------------|

### Tooling

| ID | Lección | Origen | Acción tomada |
|----|---------|--------|---------------|

---

## Estadísticas

| Métrica | Valor |
|---------|-------|
| Total bugs registrados | 1 |
| Bugs -> cambio de flujo | 0 |
| Lecciones registradas | 3 |
| Mejoras aplicadas desde retros | 3 |