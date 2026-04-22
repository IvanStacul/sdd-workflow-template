# Patch - guardrails de workflow desde retros

## Motivacion
Varias retros de otro repo mostraron el mismo patron: el workflow detectaba problemas de scope, drift y evidencia, pero muchas veces los dejaba como recomendacion blanda. Eso obliga a depender de memoria conversacional entre sesiones y hace que los mismos errores reaparezcan.

## Cambio
Se refuerzan las skills del flujo para que:

- los changes grandes no queden solo marcados para dividir, sino que la division quede materializada en proposal/specs desde la fase correcta
- `sdd-tasks` pida contratos explicitos y validacion minima en slices riesgosos
- `sdd-apply` confirme evidencia antes de actualizar `state.md` y no deje drift silencioso entre spec y codigo
- `sdd-archive` compare decisiones vs delta specs antes del merge final

## Archivos

| Archivo | Accion | Detalle |
|---------|--------|---------|
| `.agents/skills/sdd-propose/SKILL.md` | Modificado | Vuelve operativa la division de changes grandes y exige dejar slices concretos |
| `.agents/skills/sdd-spec/SKILL.md` | Modificado | Materializa la division en specs separadas en vez de dejarla solo narrada |
| `.agents/skills/sdd-tasks/SKILL.md` | Modificado | Refuerza split real, contratos entre capas y validacion minima por riesgo |
| `.agents/skills/sdd-apply/SKILL.md` | Modificado | Exige evidencia antes de `state.md`, evita drift silencioso y reversions sin edge case |
| `.agents/skills/sdd-archive/SKILL.md` | Modificado | Obliga a reconciliar decisiones y delta specs antes del sync |
| `docs/known-issues.md` | Modificado | Registra la leccion de workflow absorbida por este patch |
| `docs/workflow-changelog.md` | Modificado | Registra la mejora aplicada al workflow |

## Spec afectada
Ninguna

## Decisiones
| # | Decision | Tipo | Justificacion |
|---|----------|------|---------------|
| D-01 | Implementar estas mejoras como patch del workflow, no como change completo | Scope (diferido) | Son guardrails acotados sobre skills existentes; no agregan modulo nuevo ni cambian la arquitectura del template |
| D-02 | Materializar la division de scope en proposal/specs, no en el orquestador | Decision de diseño | Resuelve el problema de continuidad entre sesiones con cambio minimo y sin redisenar comandos publicos |

## Verificacion
- [x] Revisar diff de las skills para confirmar que los nuevos guardrails quedaron operativos y no solo descriptivos
- [x] Verificar que `docs/workflow-changelog.md` y `docs/known-issues.md` reflejen la mejora aplicada
- [x] Archivar el patch en `openspec/changes/archive/patch-2026-04-22-01-workflow-retro-guardrails/`