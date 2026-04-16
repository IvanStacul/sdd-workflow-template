# Known Issues y Lecciones Aprendidas

> Actualizado durante el archive de cada change.
> No borrar entradas; es un registro acumulativo.

---

## Bugs

### Activos

_Ninguno registrado._

### Resueltos

_Ninguno registrado._

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
| Total bugs registrados | 0 |
| Bugs -> cambio de flujo | 0 |
| Lecciones registradas | 0 |
| Mejoras aplicadas desde retros | 0 |