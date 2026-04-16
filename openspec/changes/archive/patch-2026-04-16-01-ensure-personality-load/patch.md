# Patch - Garantizar carga de personality.md, rules.md y caveman en todas las skills

## Motivación

Cuando un usuario invoca directamente un comando de fase (`/sdd:apply`, `/sdd:verify`, etc.) o una utilidad (`/sdd:domain-brief`, `/sdd:onboard`, etc.), el agente carga la skill correspondiente pero no necesariamente carga `personality.md` ni `rules.md`. Esto resulta en respuestas sin el tono, idioma ni filosofía de comunicación definidos para el proyecto.

El problema tiene tres niveles:
1. `_shared/phase-common.md` cargaba `rules.md` pero NO `personality.md` — afecta a todas las fases SDD.
2. Las utility skills (domain-brief, system-overview, sdd-onboard, visual-companion) no usan `phase-common.md` y no cargaban ninguno de los dos archivos.
3. `personality.md` referencia la skill `caveman` semánticamente pero ninguna skill cargaba `caveman/SKILL.md` — el agente ve los niveles de compresión configurados pero no sabe las reglas operativas de cada nivel.

## Cambio

### `_shared/phase-common.md`
- Agregado `.agents/personality.md` como item 3 en la carga obligatoria (sección B).
- Agregada carga condicional de `caveman/SKILL.md` cuando config define `communication.compression`.
- Renumerados items 4-7 (antes 3-6).

### Utility skills sin phase-common
- `domain-brief/SKILL.md`: agregados `rules.md`, `personality.md` y carga condicional de `caveman/SKILL.md` al Context Load.
- `system-overview/SKILL.md`: agregados `rules.md`, `personality.md` y carga condicional de `caveman/SKILL.md` al Context Load.
- `sdd-onboard/SKILL.md`: agregados `rules.md`, `personality.md` y carga condicional de `caveman/SKILL.md` al Context Load.
- `visual-companion/SKILL.md`: agregada sección Context Load con `rules.md`, `personality.md` y carga condicional de `caveman/SKILL.md`.

## Archivos

| Archivo | Acción | Detalle |
|---------|--------|---------|
| `.agents/skills/_shared/phase-common.md` | Modificado | Agregado `personality.md` como item 3, carga condicional de caveman, renumerados restantes |
| `.agents/skills/domain-brief/SKILL.md` | Modificado | Agregados rules + personality + caveman condicional al Context Load |
| `.agents/skills/system-overview/SKILL.md` | Modificado | Agregados rules + personality + caveman condicional al Context Load |
| `.agents/skills/sdd-onboard/SKILL.md` | Modificado | Agregados rules + personality + caveman condicional al Context Load |
| `.agents/skills/visual-companion/SKILL.md` | Modificado | Agregada sección Context Load con rules + personality + caveman condicional |

## Spec afectada
Ninguna (cambio de infraestructura del workflow).

## Decisiones
| # | Decisión | Tipo | Justificación |
|---|----------|------|---------------|
| D-01 | Agregar personality a phase-common en vez de a cada skill individual | Decisión de diseño | phase-common ya es el punto centralizado de carga obligatoria para las fases SDD; agregar ahí evita duplicación y cubre todas las fases de una vez |
| D-02 | Agregar rules + personality directamente a las utility skills | Decisión de diseño | Las utilities no usan phase-common por diseño (no son fases del change), así que la carga debe ser explícita en cada una |
| D-03 | Carga condicional de caveman/SKILL.md cuando existe communication.compression en config | Decisión de diseño | personality.md referencia los niveles de caveman semánticamente pero no fuerza la lectura; sin las reglas operativas el agente no sabe qué significa cada nivel. La condición evita carga innecesaria en proyectos sin compresión configurada |

## Verificación
- [x] `phase-common.md` lista `personality.md` como item 3 obligatorio
- [x] `phase-common.md` incluye carga condicional de `caveman/SKILL.md`
- [x] `domain-brief/SKILL.md` incluye rules.md, personality.md y caveman condicional en Context Load
- [x] `system-overview/SKILL.md` incluye rules.md, personality.md y caveman condicional en Context Load
- [x] `sdd-onboard/SKILL.md` incluye rules.md, personality.md y caveman condicional en Context Load
- [x] `visual-companion/SKILL.md` incluye sección Context Load con rules.md, personality.md y caveman condicional
- [x] Ninguna skill queda sin acceso a personality.md cuando se invoca directamente
- [x] La carga de caveman es condicional: solo cuando config define communication.compression
