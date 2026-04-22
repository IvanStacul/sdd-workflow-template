# Retro - spec-2026-04-22-03-workflow-cross-domain-traceability

## Que salió bien

- Cambio quedó implementado de punta a punta sobre `.agents/`, docs públicas y ejemplos estáticos sin romper regla forward-only.
- `verify` detectó hueco real de trazabilidad: propio change había introducido `impact-map.md` como artefacto obligatorio pero no lo había materializado todavía.
- Corrección fue chica y auditada: creación de `impact-map.md`, persistencia de clasificación en `proposal.md` y rerun exitoso de `verify`.

## Que salió mal

- Primer cierre de `apply` fue prematuro: tareas y `state.md` quedaron completas antes de validar presencia del artefacto principal del mismo change.
- No hubo evidencia runtime porque repo no tiene `testing.test_command`, `testing.typecheck_command` ni `testing.coverage_command` configurados.
- `design.md` quedó con pregunta abierta residual aunque implementación ya resolvió template híbrido.

## Que aprendimos

### Bugs encontrados

| ID | Bug | Causa raíz | Prevención |
|----|-----|------------|------------|
| BUG-001 | El change implementó wiring de `impact-map.md` pero omitió crear su propio archivo antes de primer `verify` | Se cerró `apply` por cambios en skills/docs sin comprobar que nuevo artefacto obligatorio también existiera en change activo | Cuando un change introduce artefacto obligatorio del workflow, ese mismo change debe adoptarlo y validarlo en disco antes de marcar batch como completo |

### Lecciones

| ID | Lección | Tipo | Acción sugerida |
|----|---------|------|-----------------|
| L-RETRO-01 | `verify` agrega valor real cuando contrasta artefactos esperados contra disco y no solo contra wiring global del workflow | Flujo | Mantener chequeos de cobertura cruzada como bloqueo explícito en `verify-report.md` |
| L-RETRO-02 | Template híbrido de `impact-map.md` ya quedó validado por uso real; conviene tratar pregunta abierta de `design.md` como resuelta al consolidar archive | Arquitectura | Cerrar esa pregunta en el cierre del change y usar retro como referencia de la decisión efectiva |

## Mejoras al flujo

| Propuesta | Skill/Archivo afectado | Prioridad | Estado |
|-----------|------------------------|-----------|--------|
| Ninguna adicional. `verify` ya detectó hueco y cambio principal del workflow quedó absorbido durante apply | - | Baja | descartada |

## Decisiones a preservar

- D-01: `impact-map.md` vive como artefacto separado y fuente de verdad del análisis cruzado.
- D-02: referencias del mapa usan `target`, `target_type`, `relation`, `status`, `reason` y `tags` con deduplicación por `target` + `relation`.
- D-03: la práctica se clasifica como `obligatorio`, `recomendado` u `opcional` según transversalidad y riesgo.
- D-04: capability nueva se consolida como `002-cross-reference-analysis`.
- D-05: change requiere `design.md` por impacto cross-cutting en múltiples fases del workflow.
- D-06: `verify` exige cobertura por dominio o contrato in-scope y `archive` propaga hallazgos generales respetando forward-only.